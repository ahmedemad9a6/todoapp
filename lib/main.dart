import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:todoapp/features/tasks/data/hive_task_repository_imp.dart';

import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  const String tasksBoxName = "tasks_box";
  final tasksBox = await Hive.openBox(tasksBoxName);

  WidgetsFlutterBinding.ensureInitialized();
  final TaskRepository taskRepository = HiveTaskRepositoryImp(
    taskBox: tasksBox,
  );
  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    // ننشئ المستودع ونمرره إلى الـ Cubit

    return RepositoryProvider.value(
      value: taskRepository,
      child: BlocProvider(
        create: (context) => TaskCubit(repository: taskRepository)..loadTasks(),
        child: MaterialApp(
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

          // ثيم Material 3
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3F51B5), // لون نيلي أنيق
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3F51B5),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: ThemeMode.system,

          home: const TasksPage(),
        ),
      ),
    );
  }
}
