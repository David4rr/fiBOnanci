import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'bloc/finance/finance_bloc.dart';
import 'bloc/finance/finance_event.dart';
import 'data/database/app_database.dart';
import 'data/repositories/finance_repository.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/widgets/common/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
      child: MaterialApp(
        title: 'fiBOnanci',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.canvasBg,
          colorScheme: const ColorScheme.dark().copyWith(
            primary: AppColors.neoChartreuse,
            surface: AppColors.canvasCardSurface,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          return IPhoneViewportContainer(child: child);
        },
        home: MainShell(db: database),
      ),
    );
  }
}
