// ignore_for_file: avoid_print

import 'package:draggable_date_scrollbar/draggable_date_scrollbar.dart';
import 'package:draggable_date_scrollbar/utils.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        brightness: Brightness.dark,
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
  List<DateTime> listDates = [];
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

  printExifOf(List<int> fileBytes) async {
    final data = await readExifFromBytes(fileBytes);

    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    }
    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    for (final entry in data.entries) {
      print("${entry.key}: ${entry.value}");
    }
  }

  Future<Widget> _getImages(int index) async {
    final imageNetwork =
        Image.network('https://picsum.photos/250?image=$index');
    http.Response response =
        await http.get(Uri.parse('https://picsum.photos/250?image=$index'));
    // printExifOf(response.bodyBytes);
    final data = await readExifFromBytes(response.bodyBytes);
    if (data.isEmpty) {
      print("No EXIF information found");
      listDates.add(RandomDate.withRange(2008, 2022).random());
      return imageNetwork;
    }

    final datetime = data['EXIF DateTimeOriginal']?.toString();
    if (datetime == null) {
      print("datetime information not found");
      listDates.add(RandomDate.withRange(2008, 2022).random());
      return imageNetwork;
    }

    print("datetime = $datetime");
    listDates.add(DateTime.tryParse(datetime) ?? DateTime(1900, 1, 1));
    return imageNetwork;
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
              // TODO: Replace this double offset by a DateTime metadataDate when we'll have metadata on pictures? We have [listDates] in the meanwhile
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
                  child: FutureBuilder(
                    future: _getImages(index),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data as Image;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
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
