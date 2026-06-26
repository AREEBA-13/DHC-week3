import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_3/main.dart';

void main() {
  testWidgets('FlowState app builds and shows home elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the title logo is displayed
    expect(find.text('FlowState'), findsOneWidget);

    // Verify progress card elements
    expect(find.text('Your Progress'), findsOneWidget);

    // Verify category chips are present
    expect(find.text('All'), findsWidgets);
    expect(find.text('Work'), findsWidgets);

    // Verify floating action button is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FlowState navigation to add task screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap the floating action button to add a task
    await tester.tap(find.byType(FloatingActionButton));
    // Wait for route transition
    await tester.pumpAndSettle();

    // Verify we are on the New Task screen
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text("What's on your mind?"), findsOneWidget);

    // Find the back button and navigate back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we are back on the Home screen
    expect(find.text('FlowState'), findsOneWidget);
  });
}
