import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/welcome_page.dart';
import 'firebase_options.dart';

class AppPalette {
  const AppPalette._();

  // Sporty vibrant colors
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color deepPurple = Color(0xFF1A1B3D);
  static const Color richPurple = Color(0xFF2E3192);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color vibrantOrange = Color(0xFFFF6B35);
  static const Color energyYellow = Color(0xFFFFBE0B);
  static const Color sportGreen = Color(0xFF06FFA5);
  static const Color cardDark = Color(0xFF1C1E3B);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B9D4);
  static const Color textMuted = Color(0xFF7B7D9D);

  static final LinearGradient backgroundGradient = const LinearGradient(
    colors: [darkBg, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient energyGradient = const LinearGradient(
    colors: [neonPink, vibrantOrange, energyYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient sportGradient = const LinearGradient(
    colors: [electricBlue, sportGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient purpleGradient = const LinearGradient(
    colors: [richPurple, Color(0xFF5E3FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient cardGradient = LinearGradient(
    colors: [cardDark.withOpacity(0.8), cardDark.withOpacity(0.4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeGo Sports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.electricBlue,
          brightness: Brightness.dark,
        ).copyWith(
          background: AppPalette.darkBg,
          surface: AppPalette.cardDark,
          primary: AppPalette.electricBlue,
          secondary: AppPalette.sportGreen,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: AppPalette.darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            backgroundColor: AppPalette.electricBlue,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: AppPalette.electricBlue.withOpacity(0.5),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        textTheme: ThemeData(
          brightness: Brightness.dark,
        ).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final DashboardData data = DashboardData.sample();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppPalette.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            OverviewPage(data: data),
            DashboardPage(data: data),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppPalette.cardDark.withOpacity(0.95),
                AppPalette.deepPurple.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppPalette.electricBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                activeIcon: Icon(Icons.dashboard),
                label: 'DASHBOARD',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'ANALYTICS',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppPalette.electricBlue,
            unselectedItemColor: AppPalette.textMuted,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ... Continue with rest of the file
// Due to length, I'll include the key redesigned components in the next message
