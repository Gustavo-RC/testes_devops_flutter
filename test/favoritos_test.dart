import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:testes_devops/models/favoritos.dart';
import 'package:testes_devops/screens/favoritos.dart';

Favoritos favoritosList = Favoritos();

Widget createFavoritosScreen() => ChangeNotifierProvider<Favoritos>(
  create: (context) {
    return favoritosList;
  },
  child: MaterialApp(
    home: FavoritosPage(),
  ),
);

void adicionarItens() {
  for (var i = 0; i < 10; i += 2) {
    favoritosList.adicionar(i);
  }
}

void main() {
  group('Testes de widget da página favoritos', () {
    testWidgets('Teste ListView', (tester) async {
      await tester.pumpWidget(createFavoritosScreen());
      adicionarItens();
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}