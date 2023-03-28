import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class MyNfcReader extends StatefulWidget {
  @override
  _MyNfcReaderState createState() => _MyNfcReaderState();
}

class _MyNfcReaderState extends State<MyNfcReader> {
  String nfcContent = "";

  Future<void> readNfcTag() async {
    try {
      NfcData nfcData = await FlutterNfcReader.read();
      setState(() {
        nfcContent = nfcData.content;
      });
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cititor NFC"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Scanați tag-ul NFC pentru a citi datele",
            ),
            SizedBox(height: 20),
            Text(
              nfcContent,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: readNfcTag,
        tooltip: 'Cititor NFC',
        child: Icon(Icons.nfc),
      ),
    );
  }
}
