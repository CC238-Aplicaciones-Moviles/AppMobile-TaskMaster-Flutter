import 'package:flutter/material.dart';
import 'package:taskmaster_flutter/view/calendar/Calendar.dart';
import 'package:taskmaster_flutter/view/notification/Notifications.dart';
import 'package:taskmaster_flutter/view/profile/Profile.dart';
import 'package:taskmaster_flutter/view/project/Project.dart';
import 'package:taskmaster_flutter/view/task/Task.dart';

import '../../sharedPreferences/TaskmasterPrefs.dart';

class MainBottomNavScreen extends StatefulWidget {
  final TaskmasterPrefs prefs;

  const MainBottomNavScreen({super.key, required this.prefs});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Project(),
      const Task(),
      const Calendar(),
      const Notifications(),
      Profile(prefs: widget.prefs),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: colorScheme.secondaryContainer,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
