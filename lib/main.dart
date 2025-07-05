import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Bidet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _incrementCounter() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      // oh-no
      throw Exception('Something went wrong');
    }

    // timeout only works on Android, while the latter two messages are only for iOS
    var tag = await FlutterNfcKit.poll(
      timeout: Duration(seconds: 10),
      iosMultipleTagMessage: "Multiple tags found!",
      iosAlertMessage: "Scan your tag",
    );

    print(jsonEncode(tag));
    if (tag.type == NFCTagType.iso7816) {
      var result = await FlutterNfcKit.transceive(
        "00B0950000",
        timeout: Duration(seconds: 5),
      ); // timeout is still Android-only, persist until next change
      print(result);
    }
    // iOS only: set alert message on-the-fly
    // this will persist until finish()
    await FlutterNfcKit.setIosAlertMessage("hi there!");

    // read NDEF records if available
    if (tag.ndefAvailable == true) {
      /// decoded NDEF records (see [ndef.NDEFRecord] for details)
      /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
      for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
        print(record.toString());
      }

      /// raw NDEF records (data in hex string)
      /// `{identifier: "", payload: "00010203", type: "0001", typeNameFormat: "nfcWellKnown"}`
      for (var record in await FlutterNfcKit.readNDEFRawRecords(
        cached: false,
      )) {
        print(jsonEncode(record).toString());
      }
    }

    // write NDEF records if applicable
    //    if (tag.ndefWritable == true) {
    // decoded NDEF records
    //    await FlutterNfcKit.writeNDEFRecords([new ndef.UriRecord.fromUriString("https://github.com/nfcim/flutter_nfc_kit")]);
    // raw NDEF records
    //    await FlutterNfcKit.writeNDEFRawRecords([new NDEFRawRecord("00", "0001", "0002", "0003", ndef.TypeNameFormat.unknown)]);
    //    }

    // read / write block / page / sector level data
    // see documentation for platform-specific supportability
    if (tag.type == NFCTagType.iso15693) {
      await FlutterNfcKit.writeBlock(
        1, // index
        [0xde, 0xad, 0xbe, 0xff], // data
        iso15693Flags:
            Iso15693RequestFlags(), // optional flags for ISO 15693
        iso15693ExtendedMode: false, // use extended mode for ISO 15693
      );
    }

    if (tag.type == NFCTagType.mifare_classic) {
      await FlutterNfcKit.authenticateSector(0, keyA: "FFFFFFFFFFFF");
      var data = await FlutterNfcKit.readSector(0); // read one sector, or
      var data2 = await FlutterNfcKit.readBlock(0); // read one block
    }

    // Call finish() only once
    await FlutterNfcKit.finish();
    // iOS only: show alert/error message on finish
    await FlutterNfcKit.finish(iosAlertMessage: "Success");
    // or
    await FlutterNfcKit.finish(iosErrorMessage: "Failed");

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
