import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:testes_devops/models/favoritos.dart';
import 'package:testes_devops/screens/home.dart';

Widget createHomeScreen() => ChangeNotifierProvider<Favoritos>(
  create: (context) => Favoritos(),
  child: MaterialApp(
    home: HomePage(),
  ),
);

void main() {

  group('Testes de widget da página home', () {
    testWidgets('Testando scroll', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.text('Item 0'), findsOneWidget);
      await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });
  });

  group('Testes de widget da página home', () {

    testWidgets('Teste do ListView', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Teste de scroll', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.text('Item 0'), findsOneWidget);
      await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });
  });
  testWidgets('Teste de ícone', (tester) async {
    await tester.pumpWidget(createHomeScreen());
    expect(find.byIcon(Icons.favorite), findsNothing);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.text('Adicionado aos favoritos.'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsWidgets);
    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.text('Removido dos favoritos.'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });
}

