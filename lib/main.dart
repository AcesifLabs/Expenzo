import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
import 'shared/presentation/pages/scan_page.dart';
import 'shared/presentation/widgets/lazy_indexed_stack.dart';
import 'shared/presentation/widgets/app_icons.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenzoApp());
}

class ExpenzoApp extends StatelessWidget {
  const ExpenzoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenzo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AppLoader(),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      await Firebase.initializeApp();
      await di.initCriticalDependencies();

      if (mounted) {
        setState(() => _initialized = true);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        di.initFeatureDependencies();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return _buildSplash(context);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.getIt<AuthBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => di.getIt<CategoryBloc>()),
        BlocProvider<ExpenseBloc>(create: (_) => di.getIt<ExpenseBloc>()),
        BlocProvider<SmsScannerBloc>(create: (_) => di.getIt<SmsScannerBloc>()),
      ],
      child: const _InitialDataLoader(),
    );
  }

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: _SplashIcon(),
      ),
    );
  }
}

class _SplashIcon extends StatefulWidget {
  const _SplashIcon();

  @override
  State<_SplashIcon> createState() => _SplashIconState();
}

class _SplashIconState extends State<_SplashIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.wallet,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Expenzo',
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialDataLoader extends StatefulWidget {
  const _InitialDataLoader();

  @override
  State<_InitialDataLoader> createState() => _InitialDataLoaderState();
}

class _InitialDataLoaderState extends State<_InitialDataLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
        context.read<CategoryBloc>().add(const LoadCategories());
        context.read<ExpenseBloc>().add(const LoadExpenses());
      }
    });
  }

  @override
  Widget build(BuildContext context) => const AppShell();
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
      body: LazyIndexedStack(
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
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? LucideIcons.receipt : LucideIcons.receipt),
            activeIcon: const Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1 ? LucideIcons.tag : LucideIcons.tag),
            activeIcon: const Icon(Icons.sell),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 2 ? LucideIcons.scan : LucideIcons.scan),
            activeIcon: const Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 3 ? LucideIcons.settings : LucideIcons.settings),
            activeIcon: const Icon(Icons.settings),
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
