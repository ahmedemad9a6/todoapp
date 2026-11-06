import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:todoapp/core/theme/app_theme.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/data/hive_task_repository_imp.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

void main() async {
  // 1. ضمان تهيئة خدمات فلاتر الأساسية
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Hive وفتح الصندوق
  await Hive.initFlutter();
  const String tasksBoxName = "tasks_box";
  final tasksBox = await Hive.openBox(tasksBoxName);

  // 3. إنشاء المستودع بحقن الصندوق
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
      debugShowCheckedModeBanner: false,

      // إعداد اتجاه اللغة العربية من اليمين إلى اليسار (RTL)
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // تطبيق نظام الثيم ومتابعة تغيرات ThemeCubit للوضع الليلي والنهاري
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeCubit>().state,

      home: const TasksPage(),
    );
  }
}
