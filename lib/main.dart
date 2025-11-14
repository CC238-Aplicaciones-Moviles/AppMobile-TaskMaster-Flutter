import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmaster_flutter/bloc/Calendar/CalendarBloc.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import 'package:taskmaster_flutter/view/Login.dart';
import 'package:taskmaster_flutter/view/Register.dart';
import 'package:taskmaster_flutter/view/navigation/MainBottomNavScreen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'AppTheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar los locales de intl
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
      providers: [BlocProvider(create: (context) => CalendarBloc())],
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
