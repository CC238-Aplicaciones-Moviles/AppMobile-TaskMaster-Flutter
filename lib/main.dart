import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import 'package:taskmaster_flutter/view/Login.dart';
import 'package:taskmaster_flutter/view/Register.dart';
import 'package:taskmaster_flutter/view/navigation/MainBottomNavScreen.dart';
import 'AppTheme.dart';
import 'bloc/Projects/ProjectsBloc.dart';
import 'bloc/Tasks/TasksBloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          create: (context) => ProjectsBloc(),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TaskMaster',
        theme: AppTheme.light,
        initialRoute: '/login',
        routes: {
          '/login':    (_) => Login(prefs: effectivePrefs),
          '/register': (_) => Register(prefs: effectivePrefs),
          '/home':     (_) => MainBottomNavScreen(prefs: effectivePrefs),
        },
      ),
    );
  }
}
