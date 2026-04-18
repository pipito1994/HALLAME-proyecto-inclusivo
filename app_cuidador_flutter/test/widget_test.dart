// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:app_cuidador_flutter/main.dart';

void main() {
  testWidgets('HallameApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HallameApp());

    // Verificamos que la pantalla principal cargó correctamente 
    // buscando el texto de saludo.
    expect(find.text('Hola, Cuidador'), findsOneWidget);
  });
}
