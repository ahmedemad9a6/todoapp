import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todoapp/features/tasks/data/in_memory_task_repository_impl.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ننشئ المستودع ونمرره إلى الـ Cubit
    final TaskRepository taskRepository = InMemoryTaskRepositoryImpl();

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
