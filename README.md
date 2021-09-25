# Automação de Testes

## 1. Introdução

O Flutter é um kit de ferramentas do Google para criar apps nativos para dispositivos móveis, Web e computadores com uma única base de código.

O que você aprenderá?
- Como criar testes usando o framework de testes de widgets.
- Como criar um teste de integração para testar a IU e o desempenho do app usando o pacote integration_test.
- Como testar classes de dados (provedores) com a ajuda de testes de unidade.

O que você criará?

Você começará criando um aplicativo simples com uma lista de itens. O app é compatível com as seguintes operações:
- Adicionar itens aos favoritos
- Visualizar a lista de favoritos
- Remover itens da lista de favoritos

Depois que o app estiver pronto, você criará os seguintes testes:
- Testes de unidade para validar as operações de inclusão e remoção
- Testes de widgets para as página inicial e de favoritos
- Testes de IU e desempenho para o app todo usando testes de integração

## 2. Configurar o ambiente do Flutter

Você precisa de dois softwares: o SDK do Flutter e um editor.
É possível usar qualquer um dos seguintes dispositivos:
- Um dispositivo físico (Android ou iOS) conectado ao computador e configurado para o modo de desenvolvedor.
- O iOS Simulator (requer a instalação de ferramentas do Xcode).
- O Android Emulator (requer configuração no Android Studio).

## 3. Primeiros passos

Criar um novo app do Flutter e atualizar as dependências.

O foco é testar um app do Flutter para dispositivos móveis. Você criará rapidamente o app que será testado, usando arquivos de origem que podem ser copiados e colados. O restante tem o objetivo de ensinar diferentes tipos de testes.

Crie um app de modelo simples do Flutter usando as instruções em Primeiros passos com seu primeiro app do Flutter. Nomeie o projeto como testes_devops, em vez de myapp. Você modificará esse app inicial para criar o final.

No ambiente de desenvolvimento integrado ou no editor, abra o arquivo pubspec.yaml. Adicione as seguintes dependências e salve o arquivo.
pubspec.yaml

```yml
name: testes_devops
description: Testes de software para a matéria de devops.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.3
  provider: ^6.0.0

dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
  test: any

flutter:
  uses-material-design: true
```

Clique no botão Pub get no ambiente de desenvolvimento integrado ou, na linha de comando, execute flutter pub get na parte superior do projeto.
Caso isso gere um erro, confira se o recuo no bloco dependencies está exatamente igual ao mostrado acima usando espaços, e não a tecla Tab. Os arquivos YAML são sensíveis a espaços em branco.

## 4. Criar o app

Em seguida, você criará o app para testá-lo. O app contém os seguintes arquivos:
- lib/main.dart: arquivo principal em que o app é iniciado.
- lib/screens/home.dart: cria uma lista de itens.
- lib/screens/favoritos.dart: cria o layout da lista de favoritos.
- lib/models/favoritos.dart: cria a classe de modelo para a lista de favoritos.

Substituir o conteúdo do lib/main.dart

Substitua o conteúdo do lib/main.dart pelo seguinte código:

```dart
lib/main.dart
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
```

Adicionar a página inicial ao lib/screens/home.dart
Crie um novo diretório, screens, no lib e nele crie um novo arquivo chamado home.dart. No lib/screens/home.dart, adicione o seguinte código:

```dart
lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testes_devops/models/favoritos.dart';
import 'package:testes_devops/screens/favoritos.dart';

class HomePage extends StatelessWidget {
  static String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testes Devops'),
        actions: <Widget>[
          TextButton.icon(
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, FavoritosPage.routeName);
            },
            icon: Icon(Icons.favorite_border),
            label: Text('Favoritos'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 100,
        cacheExtent: 20.0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) => ItemTile(index),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final int itemNo;

  const ItemTile(
      this.itemNo,
      );

  @override
  Widget build(BuildContext context) {
    var favoritosList = Provider.of<Favoritos>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[itemNo % Colors.primaries.length],
        ),
        title: Text(
          'Item $itemNo',
          key: Key('text_$itemNo'),
        ),
        trailing: IconButton(
          key: Key('icon_$itemNo'),
          icon: favoritosList.itens.contains(itemNo)
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          onPressed: () {
            !favoritosList.itens.contains(itemNo)
                ? favoritosList.adicionar(itemNo)
                : favoritosList.remover(itemNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(favoritosList.itens.contains(itemNo)
                    ? 'Adicionado aos favoritos.'
                    : 'Removido dos favoritos.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

Adicionar a página de favoritos ao lib/screens/favoritos.dart
No diretório lib/screens, crie outro arquivo chamado favoritos.dart. Nesse arquivo, adicione o seguinte código:

```dart
lib/screens/favoritos.dart
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
```

Por fim, criar o modelo Favoritos no lib/models/favoritos.dart
Crie um novo diretório models e nele crie um novo arquivo chamado favoritos.dart. Nesse arquivo, adicione o seguinte código:

```dart
lib/models/favoritos.dart
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
```

O app está concluído, mas ainda não foi testado.
Execute o app clicando no ícone Run no editor. Isso pode demorar um pouco quando o app é executado pela primeira vez. Ele ficará mais rápido nas etapas posteriores.
 
O app exibe uma lista de itens. Toque no ícone em formato de coração em qualquer linha para preencher o coração e adicionar o item à lista de favoritos. O botão Favorites na AppBar leva a uma segunda tela que contém a lista de favoritos.
Agora o app está pronto para ser testado. Você dará início aos testes na próxima etapa.

## 5. Testes de unidade do provedor

Comece fazendo um teste de unidade do modelo favoritos. O que é esse teste? Um teste de unidade verifica se cada unidade individual do software, que geralmente é uma função, executa a tarefa pretendida de modo correto.

Todos os arquivos de teste de um app do Flutter, exceto os testes de integração, são colocados no diretório test.

Observação: essas instruções usam a linha de comando para executar os testes. No entanto, também é possível usar as opções oferecidas pelo VS Code e pelo Android Studio para executar testes de unidade e de widget no app.

Remover o test/widget_test.dart

Antes de iniciar o teste, exclua o arquivo widget_test.dart. Você adicionará seus próprios arquivos de teste.

Criar um novo arquivo de teste

Primeiro, você testará o método adicionar() no modelo Favoritos para verificar se um novo item foi adicionado à lista e se ela reflete essa mudança. Por convenção, a estrutura de diretórios no diretório test imita a do diretório lib e os arquivos Dart têm o mesmo nome, mas com o anexo _test.

Crie um diretório models no test. Nesse novo diretório, crie um arquivo favoritos_test.dart com o seguinte conteúdo:

```dart
test/models/favoritos_test.dart
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
```

O framework de testes do Flutter permite vincular testes semelhantes, que são relacionados entre si, em um grupo. Podem existir vários grupos em um único arquivo de teste destinados a testar partes diferentes do arquivo correspondente no diretório /lib.
O método test() usa dois parâmetros de posicionamento: a description do teste e o callback em que o teste é criado.
Executar o teste
Se o app estiver em execução no emulador ou dispositivo, feche-o antes de continuar.
Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:
$ flutter test test/models/favorites_test.dart
Se tudo funcionar, você verá uma mensagem parecida com a seguinte:
00:06 +2: All tests passed!
Dica: é possível fazer todos os testes no diretório test de uma só vez. Basta executar:
$ flutter test

## 6. Teste de widget

Nesta etapa, você fará testes de widget. Os testes de widget são exclusivos do Flutter. Com eles, é possível testar individualmente cada widget escolhido. Nesta etapa, as telas HomePage e FavoritosPage serão testadas separadamente.
O teste de widget usa a função testWidget(), e não a test(). Ele também usa dois parâmetros: a description, e o callback. No entanto, aqui o callback usa um WidgetTester como argumento.
Os testes de widget usam a TestFlutterWidgetsBinding, uma classe que oferece os mesmos recursos que os widgets teriam em um app em execução (como informações sobre o tamanho da tela, a capacidade de programar animações, entre outras), mas sem o app real. Em vez disso, um ambiente virtual é usado para executar e medir o widget e, depois, testar os resultados. Aqui, o pumpWidget inicia o processo instruindo o framework a ativar e medir um widget específico, da mesma forma que seria feito em um aplicativo completo.
O framework de teste de widget fornece finders para encontrar widgets, como text(), byType() e byIcon(), além de matchers para analisar os resultados.
Comece testando o widget HomePage.
Criar um novo arquivo de teste
O primeiro teste verifica se a rolagem da HomePage funciona corretamente.
Crie um novo arquivo no diretório test e nomeie-o como home_test.dart. Adicione o seguinte código no arquivo criado:

```dart
test/home_test.dart
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
```

A função createHomeScreen() é usada para criar um app que carrega o widget a ser testado em um MaterialApp, envolvido em um ChangeNotifierProvider. O widget da página inicial precisa que os dois estejam presentes acima dele na árvore de widgets, para que ele consiga herdar e ter acesso aos dados fornecidos por eles. Essa função é transmitida como um parâmetro para a função pumpWidget().
Executar o teste
É possível executar testes de widget da mesma forma que os testes de unidade, mas usando um dispositivo ou emulador que permita assistir o teste. Isso também possibilita usar a recarga dinâmica.
Conecte o dispositivo ou inicie o emulador.
Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:
$ flutter run test/home_test.dart
Se tudo funcionar, você verá uma resposta parecida com a seguinte:
Using hardware rendering with device Android SDK built for x86. If you notice graphics artifacts, consider enabling software rendering with
"--enable-software-rendering".
Launching test/home_test.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...                             15.4s
✓  Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app.apk...                508ms
W/FlutterActivityAndFragmentDelegate( 3116): A splash screen was provided to Flutter, but this is deprecated. See flutter.dev/go/android-splash-migration for migration steps.
I/flutter ( 3116): 00:00 +0: Testes de widget da página home Testando scroll
Syncing files to device Android SDK built for x86...               129ms
 
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
 
💪 Running with sound null safety 💪
 
An Observatory debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:40629/5uMlUZ_AkaA=/
Activating Dart DevTools...                                      1,565ms
I/flutter ( 3116): 00:03 +1: Testes de widget da página home Teste do ListView
I/flutter ( 3116): 00:03 +2: Testes de widget da página home Teste de scroll
The Flutter DevTools debugger and profiler on Android SDK built for x86 is available at:
http://127.0.0.1:9100?uri=http://127.0.0.1:40629/5uMlUZ_AkaA=/
I/flutter ( 3116): 00:04 +3: Teste de ícone
I/flutter ( 3116): 00:09 +4: All tests passed!
Faça mudanças no arquivo de teste e digite Shift + R para fazer uma recarga dinâmica do app. 
Use o mesmo processo para testar a FavoritosPage com o código a seguir. Siga as mesmas etapas e execute o teste.

```dart
test/favorites_test.dart
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
```

## 7. Como testar o desempenho e a IU do app com testes de integração
Os testes de integração são usados para testar a forma como as partes individuais de um app funcionam em conjunto. O pacote integration_test é usado para fazer testes de integração no Flutter. Essa é a versão do Flutter do Selenium WebDrive (Web), Protrator (Angular), Espresso (Android) ou Earl Gray (iOS). O pacote usa o flutter_driver internamente para conduzir o teste em um dispositivo.
Instrumentar o app
Para criar um teste de integração, primeiro é necessário instrumentar o app. Isso significa configurá-lo para que o driver possa acessar a GUI e as funções para criar e executar um teste automatizado. Os testes de integração são colocados em um diretório chamado integration_test. Nesta etapa, você adicionará os seguintes arquivos para criar o teste de integração:
integration_test/driver.dart: instrumenta o app.
integration_test/app_test.dart: executa os testes no app.
Crie um diretório chamado integration_test no diretório raiz do projeto. Nesse diretório, crie um arquivo driver.dart e adicione o código a seguir:

```dart
integration_test/driver.dart
import 'package:integration_test/integration_test_driver.dart';
 
Future<void> main() => integrationDriver();
Esse código ativa o driver do teste de integração e aguarda a execução do teste. 
Criar o teste
Crie um novo arquivo e nomeie-o como app_test.dart.
integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testes_devops/main.dart';
 
void main() {
  group('Testes de performance', () {
    testWidgets('Teste de scroll', (tester) async {
      await tester.pumpWidget(TestesDevops());
 
      final listFinder = find.byType(ListView);
      await tester.fling(listFinder, Offset(0, -500), 10000);
      await tester.pumpAndSettle();
 
      await tester.fling(listFinder, Offset(0, 500), 10000);
      await tester.pumpAndSettle();
    });
    testWidgets('Testes dos favoritos', (tester) async {
      await tester.pumpWidget(TestesDevops());
 
      final iconKeys = [
        'icon_0',
        'icon_1',
        'icon_2',
        'icon_3',
      ];
 
      for (var icon in iconKeys) {
        await tester.tap(find.byKey(ValueKey(icon)));
        await tester.pumpAndSettle(Duration(seconds: 1));
 
        expect(find.text('Adicionado aos favoritos.'), findsOneWidget);
      }
 
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
 
      final removeIconKeys = [
        'remover_icon_0',
        'remover_icon_1',
        'remover_icon_2',
        'remover_icon_3',
      ];
 
      for (final iconKey in removeIconKeys) {
        await tester.tap(find.byKey(ValueKey(iconKey)));
        await tester.pumpAndSettle(Duration(seconds: 1));
 
        expect(find.text('Removido dos favoritos.'), findsOneWidget);
      }
    });
  });
}
```

Executar o teste
Conecte o dispositivo ou inicie o emulador.
Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:
$ flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart
Se tudo funcionar, você verá uma resposta parecida com a seguinte:
Running "flutter pub get" in testes_devops...                      686ms
Running Gradle task 'assembleDebug'...                              5.6s
✓  Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app.apk...                597ms
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:44349/FyMWgSPTj14=/
VMServiceFlutterDriver: Isolate found with number: 1477414812874439
VMServiceFlutterDriver: Isolate is paused at start.
VMServiceFlutterDriver: Attempting to resume isolate
I/flutter ( 3467): 00:00 +0: Testes de performance Teste de scroll
VMServiceFlutterDriver: Flutter Driver extension is taking a long time to become available. Ensure your test app (often "lib/main.dart") imports "package:flutter_driver/driver_extension.dart" and calls enableFlutterDriverExtension() as the first call in main().
I/flutter ( 3467): 00:06 +1: Testes de performance Testes dos favoritos
I/flutter ( 3467): 00:30 +2: All tests passed!

## 8. Parabéns!

Você aprendeu:
- Como testar widgets usando o framework de testes de widgets.
- Como testar a IU do app usando testes de integração.
- Como testar o desempenho do app usando testes de integração.
- Como testar provedores com a ajuda dos testes de unidade

## 9. Referências!
- https://codelabs.developers.google.com/codelabs/flutter-app-testing?hl=pt-br#0
- https://flutter.dev/docs/testing
- https://flutter.dev/docs/cookbook/testing/integration/scrolling
- https://flutter.dev/docs/perf/rendering/ui-performance
