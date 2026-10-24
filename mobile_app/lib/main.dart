import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
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
      theme: AppTheme.lightTheme,
      home: const TaskManagerHome(),
    );
  }
}

class TaskManagerHome extends ConsumerStatefulWidget {
  // TODO: Remove "Test API" button in Task 4.
  const TaskManagerHome({super.key});

  @override
  ConsumerState<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends ConsumerState<TaskManagerHome> {
  bool _isLoading = false;

  Future<void> _testApi() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/health');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Health: ${response.data}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Task Manager'),
            const SizedBox(height: 16),
            // TODO: Remove "Test API" button in Task 4.
            ElevatedButton(
              onPressed: _isLoading ? null : _testApi,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test API'),
            ),
          ],
        ),
      ),
    );
  }
}
