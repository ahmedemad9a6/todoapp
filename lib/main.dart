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
      size: Size(410, 860),
      center: true,
      skipTaskbar: false,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
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
        return IPhoneFrame(child: child ?? const SizedBox.shrink());
      },
      home: SplashPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// إطار الآيفون
// ---------------------------------------------------------------------------
class IPhoneFrame extends StatelessWidget {
  final Widget child;
  const IPhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // على الموبايل الحقيقي لا نعرض الإطار
    final isDesktop =
        Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    if (!isDesktop) return child;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(10), // سمك البيزل
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(56),
        border: Border.all(color: const Color(0xFF2A2A2E), width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(46),
        child: Stack(
          children: [
            // الشاشة (مع إزاحة حتى ما يتغطى المحتوى بالـ Dynamic Island)
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 54, bottom: 24),
              ),
              child: child,
            ),

            // Dynamic Island + منطقة سحب النافذة
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DragToMoveArea(
                child: SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 11),
                      width: 110,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // مؤشر الـ Home تحت
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 120,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0x59000000),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}