import 'package:draggable_date_scrollbar/draggable_date_scrollbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Date Scrollbar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late ScrollController controller;
  bool isReversed = false;
  static int itemCount = 85;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return DraggableDateScrollbar.circle(
              backgroundColor: Theme.of(context).primaryColor,
              arrowColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              alwaysVisibleScrollThumb: true,
              controller: controller,
              heightScrollThumb: 60,
              isReversed: isReversed,
              onReversed: () => setState(() => isReversed = !isReversed),
              // TODO: Replace this double offset by a DateTime metadataDate when we'll have metadata on pictures?
              labelDateBuilder: (offset) {
                final DateTime currentDate = controller.hasClients
                    ? offset >= 0 && offset < 3000
                        ? DateTime(2022, 05, 03)
                        : offset >= 3000 && offset < 6000
                            ? DateTime(2021, 02, 26)
                            : DateTime(2015, 11, 14)
                    : DateTime(1900, 1, 1);
                return currentDate;
              },
              labelConstraints:
                  const BoxConstraints.tightFor(width: 150.0, height: 80.0),
              child: GridView.builder(
                controller: controller,
                itemCount: itemCount,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(10),
                  child:
                      Image.network('https://picsum.photos/250?image=$index'),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
