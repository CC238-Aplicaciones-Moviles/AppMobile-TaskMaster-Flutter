import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmaster_flutter/bloc/Projects/ProjectsBloc.dart';
import 'package:taskmaster_flutter/bloc/users/UsersBloc.dart';
import 'package:taskmaster_flutter/bloc/Calendar/CalendarBloc.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import 'package:taskmaster_flutter/view/Login.dart';
import 'package:taskmaster_flutter/view/Register.dart';
import 'package:taskmaster_flutter/view/navigation/MainBottomNavScreen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'AppTheme.dart';

import 'bloc/Tasks/TasksBloc.dart';
import 'bloc/notifications/NotificationBloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await initializeDateFormatting('es_ES', null);

  final prefs = await TaskmasterPrefs().init();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final TaskmasterPrefs? prefs;
  const MyApp({super.key, this.prefs});

  @override
  Widget build(BuildContext context) {
    final effectivePrefs = prefs ?? TaskmasterPrefs();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsBloc>(
          create: (_) => ProjectsBloc(),
        ),
        BlocProvider<UsersBloc>(
          create: (_) => UsersBloc(),
        ),
        BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TaskMaster',
        theme: AppTheme.light,
        initialRoute: '/login',
        routes: {
          '/login': (_) => Login(prefs: effectivePrefs),
          '/register': (_) => Register(prefs: effectivePrefs),
          '/home': (_) => MainBottomNavScreen(prefs: effectivePrefs),
        },
      ),
    );
  }
}