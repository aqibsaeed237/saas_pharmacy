import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/image_cache_config.dart';
import 'core/utils/theme_manager.dart';
import 'core/utils/locale_manager.dart';
import 'presentation/authentication/bloc/auth_bloc.dart';
import 'presentation/authentication/bloc/auth_event.dart';
import 'presentation/widgets/exit_confirmation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure image cache
  ImageCacheConfig.configure();
  
  // Load translations
  await AppLocalizations.loadTranslations();
  
  // Initialize dependency injection
  await init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeManager _themeManager;
  late final LocaleManager _localeManager;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _themeManager = getIt<ThemeManager>();
    _localeManager = getIt<LocaleManager>();
    _initializeManagers();
    // Listen to changes for instant updates
    _themeManager.addListener(_onThemeChanged);
    _localeManager.addListener(_onLocaleChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initializeManagers() async {
    await _themeManager.loadTheme();
    await _localeManager.loadLocale();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    _localeManager.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthStatusChecked()),
        ),
      ],
      child: ExitConfirmation(
        child: ListenableBuilder(
          listenable: Listenable.merge([_themeManager, _localeManager]),
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Pharmacy POS',
              debugShowCheckedModeBanner: false,
              theme: _themeManager.getCurrentTheme(context),
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeManager.themeMode,
              locale: _localeManager.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}

