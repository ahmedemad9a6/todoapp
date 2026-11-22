import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/core/theme/app_theme.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/data/hive_task_repository_imp.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  const String tasksBoxName = "tasks_box";
  final tasksBox = await Hive.openBox(tasksBoxName);

  try {
    await NotificationService().init();
    await NotificationService().requestPermissions();
  } catch (_) {}

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(420, 820),
      minimumSize: Size(360, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final TaskRepository taskRepository = HiveTaskRepositoryImp(
    taskBox: tasksBox,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => TaskCubit(repository: taskRepository)..loadTasks(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const double outerRadius = 32.0;
    const double innerRadius = 24.0;

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeCubit>().state,
      builder: (context, child) {
        return Container(
          color: const Color(0xFF18181B),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF111115),
              borderRadius: BorderRadius.circular(outerRadius),
              border: Border.all(
                color: const Color(0xFF3A3A46),
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: SplashPage(),
    );
  }
}