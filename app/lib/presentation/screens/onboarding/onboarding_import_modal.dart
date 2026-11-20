import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/security/backup_cipher.dart';
import '../../../core/storage/profile_preferences_storage.dart';
import '../../modals/settings/settings_backup_helper.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'onboarding_import_form_view.dart';
import 'onboarding_import_password_view.dart';
import 'onboarding_import_progress.dart';

class OnboardingImportModal extends StatefulWidget {
  final VoidCallback onImportSuccess;
  final String? initialJson;
  const OnboardingImportModal({super.key, required this.onImportSuccess, this.initialJson});

  static Future<void> show(BuildContext context, {required VoidCallback onImportSuccess, String? initialJson}) {
    final bloc = context.read<FinanceBloc>();
    return showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(value: bloc, child: OnboardingImportModal(onImportSuccess: onImportSuccess, initialJson: initialJson)),
    );
  }

  @override
  State<OnboardingImportModal> createState() => _OnboardingImportModalState();
}

class _OnboardingImportModalState extends State<OnboardingImportModal> {
  List<File> _foundFiles = [];
  bool _isSearching = true;
  String? _errorMessage;
  bool _isImporting = false;
  int _importStep = 1;
  bool _isImportSuccess = false;
  Map<String, dynamic>? _summaryData;
  Timer? _autoAdvanceTimer;
  Map<String, dynamic>? _pendingEncryptedPayload;
  bool _needsPassword = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    SettingsBackupHelper.scanBackupFiles().then((f) {
      if (mounted) setState(() { _foundFiles = f; _isSearching = false; });
    }).catchError((_) {
      if (mounted) setState(() => _isSearching = false);
    });
    if (widget.initialJson != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreJson(widget.initialJson!));
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickJsonFile() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json', 'fib']);
      if (files.isNotEmpty) {
        final path = files.first.path;
        final raw = path != null ? await File(path).readAsString() : utf8.decode(await files.first.readAsBytes());
        await _restoreJson(raw);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('MissingPluginException')
            ? 'Harap restart penuh aplikasi (Stop & Run) untuk memuat plugin native.'
            : 'Gagal membaca berkas: $e';
        setState(() => _errorMessage = msg);
      }
    }
  }

  Future<void> _restoreJson(String rawJson) async {
    setState(() { _errorMessage = null; _needsPassword = false; });
    try {
      final decoded = jsonDecode(rawJson.trim());
      if (decoded is! Map<String, dynamic>) {
        setState(() => _errorMessage = 'Format file JSON tidak sesuai.');
        return;
      }
      if (BackupCipher.isEncryptedPayload(decoded)) {
        setState(() { _pendingEncryptedPayload = decoded; _needsPassword = true; _passwordError = null; });
        return;
      }
      await _processRestoration(decoded);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Gagal memproses JSON: $e');
    }
  }

  void _decryptAndRestore(String password) async {
    final payload = _pendingEncryptedPayload;
    if (payload == null) return;
    try {
      final decrypted = BackupCipher.decrypt(payload, password);
      if (mounted) setState(() { _needsPassword = false; _pendingEncryptedPayload = null; _passwordError = null; });
      await _processRestoration(decrypted);
    } on InvalidBackupPasswordException catch (e) {
      if (mounted) setState(() => _passwordError = e.message);
    } catch (e) {
      if (mounted) setState(() => _passwordError = 'Gagal membuka berkas: $e');
    }
  }

  Future<void> _processRestoration(Map<String, dynamic> data) async {
    if (!['profiles', 'wallets', 'transactions', 'profile'].any(data.containsKey)) {
      setState(() => _errorMessage = 'Data cadangan tidak valid (tidak ada rekening/transaksi).');
      return;
    }
    setState(() { _isImporting = true; _importStep = 1; _isImportSuccess = false; });
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final stepDelay = isTest ? const Duration(milliseconds: 10) : const Duration(milliseconds: 320);

    _summaryData = {
      'walletsCount': (data['wallets'] as List?)?.length ?? (data['walletsCount'] as int?) ?? 0,
      'transactionsCount': (data['transactions'] as List?)?.length ?? (data['transactionsCount'] as int?) ?? 0,
      'subscriptionsCount': (data['subscriptions'] as List?)?.length ?? (data['subscriptionsCount'] as int?) ?? 0,
      'username': (data['profile'] as Map?)?['username'] ?? 'User',
    };

    await Future.delayed(stepDelay);
    if (!mounted) return;
    setState(() => _importStep = 2);
    final bloc = context.read<FinanceBloc>();
    await bloc.repository.restoreJsonBackup(data);
    bloc.add(const LoadFinanceData());
    await ProfilePreferencesStorage.setOnboardingCompleted(true);

    await Future.delayed(stepDelay);
    if (!mounted) return;
    setState(() { _importStep = 3; _isImportSuccess = true; });
    final finishDelay = isTest ? const Duration(milliseconds: 20) : const Duration(milliseconds: 1200);
    _autoAdvanceTimer = Timer(finishDelay, () {
      if (mounted && _isImportSuccess) _finishImport();
    });
  }

  void _finishImport() {
    _autoAdvanceTimer?.cancel();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Cadangan data berhasil dipulihkan! Selamat datang.'),
      backgroundColor: AppColors.neoMint,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    widget.onImportSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetScaffold(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: _needsPassword
              ? OnboardingImportPasswordView(
                  errorMessage: _passwordError,
                  onPasswordSubmitted: _decryptAndRestore,
                  onCancel: () => setState(() { _needsPassword = false; _pendingEncryptedPayload = null; _passwordError = null; }),
                )
              : _isImporting
                  ? OnboardingImportProgress(
                      step: _importStep,
                      isSuccess: _isImportSuccess,
                      errorMessage: _errorMessage,
                      summary: _summaryData,
                      onContinue: _finishImport,
                      onRetry: () => setState(() { _isImporting = false; _errorMessage = null; }),
                    )
                  : OnboardingImportFormView(
                      foundFiles: _foundFiles,
                      isSearching: _isSearching,
                      errorMessage: _errorMessage,
                      onPickFile: _pickJsonFile,
                      onFileSelected: _restoreJson,
                    ),
        ),
      ),
    );
  }
}
