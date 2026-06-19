import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hives_provider.dart';
import 'providers/events_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/hives_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/reminders_screen.dart';

void main() {
  runApp(const HiveLogApp());
}

class HiveLogApp extends StatelessWidget {
  const HiveLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HivesProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        title: 'Hive Log',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD9952F)),
          scaffoldBackgroundColor: const Color(0xFFFBF3E2),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFBF3E2),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Color(0xFF3A2A18),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Color(0xFF3A2A18)),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFFFBF3E2),
            indicatorColor: const Color(0xFFD9952F).withOpacity(0.18),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HivesScreen(),
    CalendarScreen(),
    RemindersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.hive_outlined),
            selectedIcon: Icon(Icons.hive),
            label: 'Hives',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
        ],
      ),
    );
  }
}