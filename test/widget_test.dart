import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_number_guessing_game/main.dart';

void main() {
  testWidgets('Full Game Flow with Upfront Secret Number: Pick number, guess, win, replay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SystemNumberGuessingApp());
    await tester.pumpAndSettle();

    // Verify Title and Difficulty Cards
    expect(find.text('System Number Guessing Game'), findsOneWidget);
    expect(find.text('Select Difficulty Level'), findsOneWidget);

    // Tap on Easy card (range 1-20)
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // The secret number bottom sheet opens
    expect(find.text('Select Your Number'), findsOneWidget);
    expect(find.textContaining('START WITH NUMBER'), findsOneWidget);

    // Tap START WITH NUMBER (starts round with number e.g. 10)
    await tester.tap(find.textContaining('START WITH NUMBER'));
    await tester.pumpAndSettle();

    // Secret number banner is visible
    expect(find.text('Your Secret Number: '), findsOneWidget);
    expect(find.text('Guess #1'), findsOneWidget);
    expect(find.text('TOO LOW'), findsOneWidget);
    expect(find.text('TOO HIGH'), findsOneWidget);
    expect(find.text('CORRECT! That is my number'), findsOneWidget);

    // First midpoint guess is 10
    expect(find.text('10'), findsWidgets);

    // Secret is 15, first guess is 10 -> Tap TOO LOW
    await tester.tap(find.text('TOO LOW'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Guess is now 15
    expect(find.text('15'), findsWidgets);

    // Tap CORRECT
    await tester.tap(find.text('CORRECT! That is my number'));
    await tester.pumpAndSettle();

    // Victory card displayed
    expect(find.text('Aha! I Found It! 🎉'), findsOneWidget);
    expect(find.text('PLAY AGAIN — CHOOSE A NEW NUMBER'), findsOneWidget);

    // Replay: tap PLAY AGAIN — CHOOSE A NEW NUMBER
    await tester.tap(find.text('PLAY AGAIN — CHOOSE A NEW NUMBER'));
    await tester.pumpAndSettle();

    // Dialog opens to select new number
    expect(find.textContaining('Select Secret Number'), findsOneWidget);
    expect(find.text('Set & Restart'), findsOneWidget);

    await tester.tap(find.text('Set & Restart'));
    await tester.pumpAndSettle();

    // Fresh round initialized
    expect(find.text('Guess #1'), findsOneWidget);
  });

  testWidgets('Classic Mind Mode: Think mentally without revealing secret',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SystemNumberGuessingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // Tap 'Or keep number secret in my head (Classic Mode)'
    await tester.tap(find.textContaining('Or keep number secret in my head'));
    await tester.pumpAndSettle();

    // Secret banner indicates secret in mind
    expect(find.textContaining('Think of a number'), findsOneWidget);
    expect(find.text('Pick Number'), findsOneWidget);
    expect(find.text('Guess #1'), findsOneWidget);
  });

  testWidgets('Zero Overflow Verification on 360dp mobile viewport',
      (WidgetTester tester) async {
    // 360 x 800 dp
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SystemNumberGuessingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('START WITH NUMBER'));
    await tester.pumpAndSettle();

    // Verify all components rendered without throwing overflow exception
    expect(find.text('Your Secret Number: '), findsOneWidget);
    expect(find.text('AI AUTO-STEP'), findsOneWidget);
    expect(find.text('TOO LOW'), findsOneWidget);
    expect(find.text('TOO HIGH'), findsOneWidget);
    expect(find.text('CORRECT! That is my number'), findsOneWidget);
  });

  testWidgets('Contradiction handling works correctly during gameplay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SystemNumberGuessingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // Start in classic mind mode so user inputs raw feedback
    await tester.tap(find.textContaining('Or keep number secret in my head'));
    await tester.pumpAndSettle();

    // Drive range to max [20, 20]
    final tooLowFinder = find.text('TOO LOW');
    await tester.ensureVisible(tooLowFinder);
    await tester.tap(tooLowFinder); // 15
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.ensureVisible(tooLowFinder);
    await tester.tap(tooLowFinder); // 18
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.ensureVisible(tooLowFinder);
    await tester.tap(tooLowFinder); // 19
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.ensureVisible(tooLowFinder);
    await tester.tap(tooLowFinder); // 20
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('20'), findsWidgets);

    // Impossible feedback: tapping TOO LOW when at maximum 20
    await tester.ensureVisible(tooLowFinder);
    await tester.tap(tooLowFinder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Contradiction Detected!'), findsOneWidget);
    expect(find.text('RECOVER'), findsOneWidget);

    // Recover
    await tester.tap(find.text('RECOVER'));
    await tester.pumpAndSettle();

    expect(find.text('Contradiction Detected!'), findsNothing);
    expect(find.text('CORRECT! That is my number'), findsOneWidget);
  });
}
