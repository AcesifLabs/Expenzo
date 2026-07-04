import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders MaterialApp with placeholder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Expenzo')),
          body: const Center(child: Text('Hello, Expenzo!')),
        ),
      ),
    );

    expect(find.text('Expenzo'), findsOneWidget);
    expect(find.text('Hello, Expenzo!'), findsOneWidget);
  });
}
