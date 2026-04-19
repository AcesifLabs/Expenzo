import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/bloc/category_event.dart';
import 'features/categories/presentation/pages/category_list_page.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/bloc/expense_event.dart';
import 'features/expenses/presentation/pages/expense_list_page.dart';
import 'features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'features/email_parser/presentation/bloc/email_scanner_bloc.dart';
import 'shared/presentation/pages/scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.initDependencies();
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      // ignore: avoid_print
      print(message);
    };
  }
  runApp(const ExpenzoApp());
}

class ExpenzoApp extends StatelessWidget {
  const ExpenzoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.getIt<AuthBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => di.getIt<CategoryBloc>()),
        BlocProvider<ExpenseBloc>(create: (_) => di.getIt<ExpenseBloc>()),
        BlocProvider<SmsScannerBloc>(create: (_) => di.getIt<SmsScannerBloc>()),
        BlocProvider<EmailScannerBloc>(
          create: (_) => di.getIt<EmailScannerBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Expenzo',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AppLoader(),
      ),
    );
  }
}

/// Splash screen that loads initial data off the main thread
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _initialized = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer BLoC loads to after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerInitialLoads();
    });
    // Show loading spinner after a short delay if data isn't ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _showLoading) {
        setState(() {});
      }
    });
  }

  Future<void> _triggerInitialLoads() async {
    if (_initialized) return;
    _initialized = true;

    // Fire auth check
    context.read<AuthBloc>().add(const AuthCheckRequested());
    // Fire data loads in parallel after frame renders
    context.read<CategoryBloc>().add(const LoadCategories());
    context.read<ExpenseBloc>().add(const LoadExpenses());

    // Small delay before hiding loading screen
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _showLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Expenzo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return const AppShell();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ExpenseListPage(),
          CategoryListPage(),
          ScanPage(),
          SettingsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Scan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings - Coming soon')),
    );
  }
}
