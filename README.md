# Automação de Testes

## 1. Introdução

O Flutter é um kit de ferramentas do Google para criar apps nativos para dispositivos móveis, web e computadores com uma única base de código.

O que você aprenderá?
- Como criar testes usando o framework de testes de widgets;
- Como criar um teste de integração para testar a IU e o desempenho do app usando o pacote integration_test;
- Como testar classes de dados (provedores) com a ajuda de testes de unidade.

O que você criará?

Você começará criando um aplicativo simples com uma lista de itens. O app é compatível com as seguintes operações:
- Adicionar itens aos favoritos;
- Visualizar a lista de favoritos;
- Remover itens da lista de favoritos.

Depois que o app estiver pronto, você criará os seguintes testes:
- Testes de unidade para validar as operações de inclusão e remoção;
- Testes de widgets para as página inicial e de favoritos;
- Testes de IU e desempenho para o app todo usando testes de integração.

## 2. Configurar o ambiente do Flutter

Você precisa de dois softwares: o SDK do Flutter e um editor.
É possível usar qualquer um dos seguintes dispositivos:
- Um dispositivo físico (Android ou iOS) conectado ao computador e configurado para o modo de desenvolvedor;
- O iOS Simulator (requer a instalação de ferramentas do Xcode);
- O Android Emulator (requer configuração no Android Studio).

## 3. Primeiros passos

Criar um novo app do Flutter e atualizar as dependências.

O foco é testar um app para dispositivos móveis. Você criará rapidamente o app que será testado, usando arquivos de origem que podem ser copiados e colados. O restante tem o objetivo de ensinar diferentes tipos de testes.

Crie um app de modelo simples usando as instruções abaixo. Nomeie o projeto como <b>testes_devops</b>, em vez de myapp. Você modificará esse app inicial para criar o final.

No ambiente de desenvolvimento integrado ou no editor, abra o arquivo <b>pubspec.yaml</b>, adicione as seguintes dependências e salve o arquivo.

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

Clique no botão <b>Pub get</b> no ambiente de desenvolvimento integrado ou, na linha de comando, execute <b>flutter pub get</b> na parte superior do projeto.
Caso isso gere um erro, confira se o recuo no bloco <b>dependencies</b> está exatamente igual ao mostrado acima usando espaços, e não a tecla Tab. Os arquivos YAML são sensíveis a espaços em branco.

## 4. Criar o app

Em seguida, você criará o app para testá-lo, este contém os seguintes arquivos:
- <b>lib/main.dart</b>: Arquivo principal em que o app é iniciado.
- <b>lib/screens/home.dart</b>: Cria uma lista de itens.
- <b>lib/screens/favoritos.dart</b>: Cria o layout da lista de favoritos.
- <b>lib/models/favoritos.dart</b>: Cria a classe de modelo para a lista de favoritos.

Substituir o conteúdo do <b>lib/main.dart</b> pelo seguinte código:

```dart
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

Crie um novo diretório chamado <b>screens</b> no lib. Dentro dele crie um novo arquivo chamado <b>home.dart</b> e adicione o seguinte código:

```dart
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

No diretório <b>lib/screens</b>, crie outro arquivo chamado <b>favoritos.dart</b> e adicione o seguinte código:

```dart
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

Crie um novo diretório chamado <b>models</b>. Dentro dele crie um novo arquivo chamado <b>favoritos.dart</b> e adicione o seguinte código:

```dart
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

O app está concluído, mas ainda não foi testado. Execute o app clicando no ícone <b>Run</b> no editor. Isso pode demorar um pouco quando o app é executado pela primeira vez. Ele ficará mais rápido nas etapas posteriores.

O app exibe uma lista de itens. Toque no ícone em formato de coração em qualquer linha para preencher o coração e adicionar o item à lista de favoritos. O botão <b>Favoritos</b> na <b>AppBar</b> leva a uma segunda tela que contém a lista de favoritos.

Agora o app está pronto para ser testado. Você dará início aos testes na próxima etapa.

## 5. Testes de unidade do provedor

Comece fazendo um teste de unidade do modelo favoritos. O que é esse teste? Um teste de unidade verifica se cada unidade individual do software, que geralmente é uma função, executa a tarefa pretendida de modo correto.

Todos os arquivos de teste de um app do Flutter, exceto os testes de integração, são colocados no diretório test.

- Observação: essas instruções usam a linha de comando para executar os testes. No entanto, também é possível usar as opções oferecidas pelo VS Code e pelo Android Studio para executar testes de unidade e de widget no app.

Antes de iniciar o teste, exclua o arquivo <b>widget_test.dart</b>. Você adicionará seus próprios arquivos de teste.

Criar um novo arquivo de teste

Primeiro, você testará o método <b>adicionar()</b> no modelo <b>Favoritos</b> para verificar se um novo item foi adicionado à lista e se ela reflete essa mudança. Por convenção, a estrutura de diretórios no diretório <b>test</b> imita a do diretório <b>lib</b> e os arquivos Dart têm o mesmo nome, mas com o sulfixo <i>_test</i>.

Crie um diretório chamado <b>models</b> no test. Nesse novo diretório, crie o arquivo <b>favoritos_test.dart</b> com o seguinte conteúdo:

```dart
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

O framework de testes do Flutter permite vincular testes semelhantes, que são relacionados entre si, em um grupo. Podem existir vários grupos em um único arquivo de teste destinados a testar partes diferentes do arquivo correspondente no diretório <b>/lib</b>.

O método <b>test()</b> usa dois parâmetros de posicionamento: a description do teste e o callback em que o teste é criado.

#### Executar o teste

Se o app estiver em execução no emulador ou dispositivo, feche-o antes de continuar.

Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:

```shell
$ flutter test test/models/favoritos_test.dart
```

Se tudo funcionar, você verá uma mensagem parecida com a seguinte:

```shell
00:06 +2: All tests passed!
```

Dica: é possível fazer todos os testes no diretório test de uma só vez. Basta executar:

```shell
$ flutter test
```

## 6. Teste de widget

Nesta etapa, você fará testes de widget. Os testes de widget são exclusivos do Flutter. Com eles, é possível testar individualmente cada widget escolhido. Nesta etapa, as telas <b>HomePage</b> e <b>FavoritosPage</b> serão testadas separadamente.

O teste de widget usa a função <b>testWidget()</b>, e não a <b>test()</b>. Ele também usa dois parâmetros: a <b>description</b>, e o <b>callback</b>. No entanto, aqui o callback usa um <b>WidgetTester</b> como argumento.

Os testes de widget usam a <b>TestFlutterWidgetsBinding</b>, uma classe que oferece os mesmos recursos que os widgets teriam em um app em execução (como informações sobre o tamanho da tela, a capacidade de programar animações, entre outras), mas sem o app real. Em vez disso, um ambiente virtual é usado para executar e medir o widget e, depois, testar os resultados. Aqui, o <b>pumpWidget</b> inicia o processo instruindo o framework a ativar e medir um widget específico, da mesma forma que seria feito em um aplicativo completo.

O framework de teste de widget fornece finders para encontrar widgets, como <b>text()</b>, <b>byType()</b> e <b>byIcon()</b>, além de matchers para analisar os resultados.

#### Comece testando o widget HomePage

Criar um novo arquivo de teste. O primeiro teste verifica se a rolagem da <b>HomePage</b> funciona corretamente.
Crie um novo arquivo no diretório <b>test</b> e nomeie-o como <b>home_test.dart</b>. Adicione o seguinte código no arquivo criado:

```dart
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

A função <b>createHomeScreen()</b> é usada para criar um app que carrega o widget a ser testado em um <b>MaterialApp</b>, envolvido em um <b>ChangeNotifierProvider</b>. O widget da página inicial precisa que os dois estejam presentes acima dele na árvore de widgets, para que ele consiga herdar e ter acesso aos dados fornecidos por eles. Essa função é transmitida como um parâmetro para a função <b>pumpWidget()</b>.

#### Executar o teste

É possível executar testes de widget da mesma forma que os testes de unidade, mas usando um dispositivo ou emulador que permita assistir o teste. Isso também possibilita usar a recarga dinâmica.

Conecte o dispositivo ou inicie o emulador.

Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:

```shell
$ flutter run test/home_test.dart
```

Se tudo funcionar, você verá uma resposta parecida com a seguinte:

```shell
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
```

Faça mudanças no arquivo de teste e digite <b>Shift + R</b> para fazer uma recarga dinâmica do app. 
Use o mesmo processo para testar a <b>FavoritosPage</b> com o código a seguir. Siga as mesmas etapas (criando o arquivo <b>test/favoritos_test.dart</b> e incluindo o código abaixo) e execute o teste.

```dart
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

#### Instrumentar o app

Para criar um teste de integração, primeiro é necessário instrumentar o app. Isso significa configurá-lo para que o driver possa acessar a GUI e as funções para criar e executar um teste automatizado. Os testes de integração são colocados em um diretório chamado integration_test. Nesta etapa, você adicionará os seguintes arquivos para criar o teste de integração:
- <b>integration_test/driver.dart</b>: instrumenta o app.
- <b>integration_test/app_test.dart</b>: executa os testes no app.

Crie um diretório chamado <b>integration_test</b> no diretório raiz do projeto. Nesse diretório, crie um arquivo <b>driver.dart</b> e adicione o código a seguir:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```
  
Esse código ativa o driver do teste de integração e aguarda a execução do teste. 

#### Criar o teste

Crie um novo arquivo e nomeie-o como <b>app_test.dart</b>.

```dart
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

#### Executar o teste

Conecte o dispositivo ou inicie o emulador.

Na linha de comando, navegue até o diretório raiz do projeto e digite o seguinte comando:

```shell
$ flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart
```

Se tudo funcionar, você verá uma resposta parecida com a seguinte:

```shell
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
```

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
