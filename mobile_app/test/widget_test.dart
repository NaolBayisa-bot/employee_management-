import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/main.dart';

void main() {
  test('AppConfig apiBaseUrl is configured', () {
    expect(AppConfig.apiBaseUrl, isNotEmpty);
    expect(AppConfig.apiBaseUrl, contains('://'));
  });

  testWidgets('home screen shows the Task Manager title text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Task Manager'), findsWidgets);
  });
}
