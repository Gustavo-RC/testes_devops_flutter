import 'package:flutter_test/flutter_test.dart';
import 'package:testes_devops/models/favoritos.dart';

void main() {
  group('Testes de funcionalidades', () {
    var favoritos = Favoritos();

    test('Um novo item foi adicionado', () {
      var number = 35;
      favoritos.adicionar(number);
      expect(favoritos.itens.contains(number), true);
    });
    test('Um item foi removido', () {
      var number = 45;
      favoritos.adicionar(number);
      expect(favoritos.itens.contains(number), true);
      favoritos.remover(number);
      expect(favoritos.itens.contains(number), false);
    });
  });
}
