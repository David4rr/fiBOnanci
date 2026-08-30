import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/edit_profile_modal.dart';
import 'package:fibonanci_app/presentation/screens/dashboard_screen.dart';
import 'package:fibonanci_app/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('Profile Database & Repository CRUD Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Seeds default profile with username David on database creation', () async {
      final profiles = await repo.getProfiles();
      expect(profiles, isNotEmpty);
      final defaultProfile = profiles.first;
      expect(defaultProfile.username, 'David');
      expect(defaultProfile.fullName, 'David Arrozaqi');
      expect(defaultProfile.currency, 'IDR');
      expect(defaultProfile.isActive, isTrue);
      expect(defaultProfile.isDeleted, isFalse);
    });

    test('Creates a new profile with general data and avatar', () async {
      await repo.addProfile(
        username: 'Sarah',
        fullName: 'Sarah Jenkins',
        email: 'sarah@example.com',
        phone: '+62 811-2233-4455',
        avatarPath: 'preset:avatar_4',
        occupation: 'UI/UX Designer',
        bio: 'Designing financial clarity',
        currency: 'USD',
        monthlyIncomeTarget: 25000000.0,
        setActive: true,
      );

      final profiles = await repo.getProfiles();
      expect(profiles.length, 2);

      final sarah = profiles.firstWhere((p) => p.username == 'Sarah');
      expect(sarah.fullName, 'Sarah Jenkins');
      expect(sarah.email, 'sarah@example.com');
      expect(sarah.phone, '+62 811-2233-4455');
      expect(sarah.avatarPath, 'preset:avatar_4');
      expect(sarah.occupation, 'UI/UX Designer');
      expect(sarah.bio, 'Designing financial clarity');
      expect(sarah.currency, 'USD');
      expect(sarah.monthlyIncomeTarget, 25000000.0);
      expect(sarah.isActive, isTrue);

      // David should now be deactivated
      final david = profiles.firstWhere((p) => p.username == 'David');
      expect(david.isActive, isFalse);
    });

    test('Updates profile general data, username and photo', () async {
      final initialProfiles = await repo.getProfiles();
      final current = initialProfiles.first;

      await repo.updateProfile(
        profileId: current.id,
        username: 'DavidArr',
        fullName: 'David Arrozaqi, S.Kom',
        email: 'david.arr@fibonanci.app',
        phone: '+62 819-9988-7766',
        avatarPath: 'preset:avatar_3',
        occupation: 'Lead Engineer',
        bio: 'Minimalist & Offline First',
        currency: 'IDR',
        monthlyIncomeTarget: 30000000.0,
      );

      final updated = await repo.getProfiles();
      final p = updated.firstWhere((p) => p.id == current.id);
      expect(p.username, 'DavidArr');
      expect(p.fullName, 'David Arrozaqi, S.Kom');
      expect(p.email, 'david.arr@fibonanci.app');
      expect(p.phone, '+62 819-9988-7766');
      expect(p.avatarPath, 'preset:avatar_3');
      expect(p.occupation, 'Lead Engineer');
      expect(p.bio, 'Minimalist & Offline First');
      expect(p.monthlyIncomeTarget, 30000000.0);
    });

    test('Deletes profile and switches active profile gracefully', () async {
      // Add second profile
      await repo.addProfile(
        username: 'Bisnis',
        fullName: 'Bisnis David',
        setActive: true,
      );

      var profiles = await repo.getProfiles();
      expect(profiles.length, 2);

      final bisnis = profiles.firstWhere((p) => p.username == 'Bisnis');
      expect(bisnis.isActive, isTrue);

      // Delete active profile 'Bisnis'
      await repo.deleteProfile(bisnis.id);

      profiles = await repo.getProfiles();
      expect(profiles.length, 1);
      expect(profiles.first.username, 'David');
      expect(profiles.first.isActive, isTrue); // David automatically reactivated
    });
  });

  group('Profile BLoC Reactive State Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('LoadFinanceData emits state with active profile and fallback', () async {
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFinanceData());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<FinanceState>((s) =>
              s.status == FinanceStatus.success &&
              s.profiles.isNotEmpty &&
              s.profile.username == 'David'),
        ),
      );
    });

    test('AddProfileEvent and UpdateProfileEvent reactively update BLoC state', () async {
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFinanceData());
      await bloc.stream.firstWhere((s) => s.status == FinanceStatus.success);

      // Add new profile
      bloc.add(const AddProfileEvent(
        username: 'Alice',
        fullName: 'Alice Johnson',
        occupation: 'Data Scientist',
        setActive: true,
      ));

      await bloc.stream.firstWhere((s) => s.profile.username == 'Alice');
      expect(bloc.state.profile.fullName, 'Alice Johnson');
      expect(bloc.state.profile.occupation, 'Data Scientist');

      // Update profile
      bloc.add(UpdateProfileEvent(
        profileId: bloc.state.profile.id,
        username: 'AliceJ',
        fullName: 'Alice Johnson, Ph.D',
        occupation: 'AI Researcher',
      ));

      await bloc.stream.firstWhere((s) => s.profile.username == 'AliceJ');
      expect(bloc.state.profile.fullName, 'Alice Johnson, Ph.D');
      expect(bloc.state.profile.occupation, 'AI Researcher');
    });
  });

  group('Dashboard & Profile UI Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Dashboard DOES NOT show 35/100 or KRITIS status badge, shows clean greeting & ProfileAvatar', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Greeting with profile username
      expect(find.text('Hello David'), findsOneWidget);
      expect(find.text('Selamat datang kembali!'), findsOneWidget);

      // ABSOLUTELY NO 35/100 or KRITIS status badge on dashboard!
      expect(find.textContaining('35/100'), findsNothing);
      expect(find.textContaining('/100'), findsNothing);
      expect(find.textContaining('KRITIS'), findsNothing);

      // ProfileAvatar widget is rendered
      expect(find.byType(ProfileAvatar), findsOneWidget);
    });

    testWidgets('Tapping ProfileAvatar opens ProfileModal with complete general data', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on avatar
      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();

      // Verify ProfileModal is opened
      expect(find.text('Profil Pengguna'), findsOneWidget);
      expect(find.text('David Arrozaqi'), findsNWidgets(2));
      expect(find.text('@David'), findsNWidgets(2));
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('+ Profil Baru'), findsOneWidget);
      expect(find.text('DATA UMUM & DETAIL AKUN'), findsOneWidget);
      expect(find.text('Software Engineer'), findsNWidgets(2));
    });

    testWidgets('EditProfileModal validates inputs and allows updating profile', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => EditProfileModal.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap open
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Profil Baru'), findsOneWidget);
      expect(find.text('Foto Profil'), findsOneWidget);

      // Attempt to submit empty form
      await tester.ensureVisible(find.text('Buat Profil Baru'));
      await tester.tap(find.text('Buat Profil Baru'));
      await tester.pumpAndSettle();

      // Validation errors
      expect(find.text('Username wajib diisi'), findsOneWidget);
      expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);

      // Enter valid data using exact field positions
      await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
      await tester.enterText(find.byType(TextFormField).at(1), 'Budi Santoso');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Buat Profil Baru'));
      await tester.tap(find.text('Buat Profil Baru'));
      await tester.pumpAndSettle();

      // Modal closed
      expect(find.text('Tambah Profil Baru'), findsNothing);
    });

    testWidgets('EditProfileModal provides Pilih dari Galeri, Ambil Kamera, and image source picker options', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: ctx,
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const EditProfileModal(),
                    ),
                  );
                },
                child: const Text('Buka Modal'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Modal'));
      await tester.pumpAndSettle();
      expect(find.text('Foto Profil'), findsOneWidget);
      expect(find.text('ATAU PILIH PERSONA AVATAR'), findsNothing);
      expect(find.text('Ketuk untuk pilih dari galeri atau kamera'), findsOneWidget);

      // Tap on avatar camera badge/gesture to open source selector dialog
      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();

      // Now inside the photo source dialog
      expect(find.text('Pilih Sumber Foto'), findsOneWidget);
      expect(find.text('Galeri Foto'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
    });
  });
}
