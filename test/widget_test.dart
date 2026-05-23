import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cartas/main.dart';

void main() {
  testWidgets('App initialisation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CartasApp());

    // Vérifie que l'app se lance sans erreur
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}