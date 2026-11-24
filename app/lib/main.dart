import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'bloc/finance/finance_bloc.dart';
import 'bloc/finance/finance_event.dart';
import 'core/notifications/in_app_notification_storage.dart';
import 'core/storage/profile_preferences_storage.dart';
import 'data/database/app_database.dart';
import 'data/repositories/finance_repository.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_circle_reveal.dart';
import 'presentation/widgets/common/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await ProfilePreferencesStorage.load();
  await InAppNotificationStorage.init();

  final database = AppDatabase();
  final repository = DriftFinanceRepository(database);

  runApp(FiBOnanciApp(
    database: database,
    repository: repository,
  ));
}

class FiBOnanciApp extends StatelessWidget {
  final AppDatabase database;
  final FinanceRepository repository;

  const FiBOnanciApp({
    super.key,
    required this.database,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceBloc>(
      create: (context) => FinanceBloc(repository: repository)..add(const LoadFinanceData()),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'fiBOnanci',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            themeAnimationDuration: Duration.zero,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              final platformBrightness = MediaQuery.platformBrightnessOf(context);
              final effectiveBrightness = themeMode == ThemeMode.system
                  ? platformBrightness
                  : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
              AppColors.updateBrightness(effectiveBrightness);
              return ThemeCircleReveal(
                child: IPhoneViewportContainer(child: child),
              );
            },
            home: FibonanciSplashGate(child: MainShell(db: database)),
          );
        },
      ),
    );
  }
}
