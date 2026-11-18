import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/core/theme/app_theme.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/data/hive_task_repository_imp.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/splash_page.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  const String tasksBoxName = "tasks_box";
  final tasksBox = await Hive.openBox(tasksBoxName);

  try {
    await NotificationService().init();
    await NotificationService().requestPermissions();
  } catch (_) {}

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
    return MaterialApp(
      title: 'تطبيق المهام',
      debugShowCheckedModeBanner: false, // إخفاء شريط الديباج المزعج في الزاوية

            locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية (أساسي)
        Locale('en', 'US'), // الإنجليزية (اختياري)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

            theme: AppTheme.lightTheme, // ثيم الوضع النهاري
      darkTheme: AppTheme.darkTheme, // ثيم الوضع الليلي
      themeMode: context.watch<ThemeCubit>().state,

      home: const SplashPage(),
    );
  }
}
