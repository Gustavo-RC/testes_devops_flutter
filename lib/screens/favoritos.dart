import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testes_devops/models/favoritos.dart';

class FavoritosPage extends StatelessWidget {
  static String routeName = '/favoritos_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: Consumer<Favoritos>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.itens.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => FavoritoItemTile(value.itens[index]),
        ),
      ),
    );
  }
}

class FavoritoItemTile extends StatelessWidget {
  final int itemNo;

  const FavoritoItemTile(
      this.itemNo,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[itemNo % Colors.primaries.length],
        ),
        title: Text(
          'Item $itemNo',
          key: Key('favoritos_text_$itemNo'),
        ),
        trailing: IconButton(
          key: Key('remover_icon_$itemNo'),
          icon: Icon(Icons.close),
          onPressed: () {
            Provider.of<Favoritos>(context, listen: false).remover(itemNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removido dos favoritos.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}