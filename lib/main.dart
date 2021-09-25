import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:provider/provider.dart';
import 'package:testes_devops/models/favoritos.dart';
import 'package:testes_devops/screens/favoritos.dart';
import 'package:testes_devops/screens/home.dart';

void main() {
  enableFlutterDriverExtension();
  runApp(TestesDevops());
}

class TestesDevops extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Favoritos>(
      create: (context) => Favoritos(),
      child: MaterialApp(
        title: 'Testes Devops',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          HomePage.routeName: (context) => HomePage(),
          FavoritosPage.routeName: (context) => FavoritosPage(),
        },
        initialRoute: HomePage.routeName,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
