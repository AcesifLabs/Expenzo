import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/utils/navigation_utils.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/bloc/category_event.dart';
import 'features/categories/presentation/pages/category_list_page.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/bloc/expense_event.dart';
import 'features/expenses/presentation/pages/expense_list_page.dart';
import 'features/expenses/presentation/pages/expense_form_page.dart';
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
                Icon(
                  PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
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
            PhosphorIcons.wallet(PhosphorIconsStyle.regular),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        shape: const CircleBorder(),
        child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, PhosphorIcons.invoice(PhosphorIconsStyle.regular), 'Expenses'),
            _buildNavItem(1, PhosphorIcons.tag(PhosphorIconsStyle.regular), 'Categories'),
            const SizedBox(width: 40),
            _buildNavItem(2, PhosphorIcons.listMagnifyingGlass(PhosphorIconsStyle.regular), 'Scan'),
            _buildNavItem(3, PhosphorIcons.faders(PhosphorIconsStyle.regular), 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
      onPressed: () => setState(() => _currentIndex = index),
      tooltip: label,
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: di.getIt<ExpenseBloc>()),
            BlocProvider.value(value: di.getIt<CategoryBloc>()),
          ],
          child: ExpenseFormPage(expense: null),
        ),
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
