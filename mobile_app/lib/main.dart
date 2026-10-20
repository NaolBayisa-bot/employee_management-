import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/network/api_exception.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.darkTheme,
      home: const TaskManagerHome(),
    );
  }
}

/// Placeholder home screen for Task 2.
///
/// The "Test API" button exercises the Dio client + cleartext network path
/// against the dev backend's `GET /health` endpoint. It is TEMPORARY and is
/// removed in Task 4 once the real auth flow is wired in.
class TaskManagerHome extends ConsumerWidget {
  const TaskManagerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testApi(context, ref),
          child: const Text('Test API'),
        ),
      ),
    );
  }

  /// TEMPORARY — remove in Task 4.
  Future<void> _testApi(BuildContext context, WidgetRef ref) async {
    final dio = ref.read(dioProvider);
    String status = 'Something went wrong';
    try {
      final response = await dio.get('/health');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final s = data['status'] as String?;
        status = (s != null && s.trim().isNotEmpty) ? s : 'OK';
      } else if (data != null) {
        status = data.toString();
      } else {
        status = 'OK';
      }
    } on DioException catch (e) {
      final exception = e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Something went wrong');
      status = exception.message;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(status)));
  }
}

