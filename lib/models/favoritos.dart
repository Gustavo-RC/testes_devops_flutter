import 'package:flutter/material.dart';

class Favoritos extends ChangeNotifier {
  final List<int> _itensFavoritos = [];

  List<int> get itens => _itensFavoritos;

  void adicionar(int itemNo) {
    _itensFavoritos.add(itemNo);
    notifyListeners();
  }

  void remover(int itemNo) {
    _itensFavoritos.remove(itemNo);
    notifyListeners();
  }
}