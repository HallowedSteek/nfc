import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';


class MyAppNFC extends StatefulWidget {
  const MyAppNFC({super.key});

  @override
  State<StatefulWidget> createState() => MyAppNFCState();
}

class MyAppNFCState extends State<MyAppNFC> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('NfcManager Plugin Example')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(border: Border.all()),
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<dynamic>(
                        valueListenable: result,
                        builder: (context, value, _) =>
                            Text('${value ?? ''}'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: GridView.count(
                    padding: EdgeInsets.all(4),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      ElevatedButton(
                          child: Text('Tag Read'), onPressed: _tagRead),
                      ElevatedButton(
                          child: Text('Ndef Write'),
                          onPressed: _ndefWrite),
                      ElevatedButton(
                          child: Text('Ndef Write Lock'),
                          onPressed: _ndefWriteLock),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _tagRead() async {
    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndefTag = Ndef.from(tag);
          setState(() {
            result.value = tag.data.toString();
          });
          final ndefRecord = NdefRecord.createText(result.value);
          var ndefMessage = ndefTag?.cachedMessage!;
          final languageCodeAndContentBytes =
          ndefRecord.payload.skip(1).toList();
          //Note that the language code can be encoded in ASCI, if you need it be carfully with the endoding
          final languageCodeAndContentText =
          utf8.decode(languageCodeAndContentBytes);
          //Cutting of the language code
          final payload = languageCodeAndContentText.substring(2);
          //Parsing the content to int
          _handleNFCData(ndefMessage.toString());
          await NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      print(e);
    }
    NfcManager.instance.stopSession();
  }

   void _handleNFCData(String ndefMessage) {
     String Message = ndefMessage;
     print("Succesfull");
     setState(() {
       if (Message == 'artbyte') {
         //Afisare meniu buton corect
         showDialog(
           context: this.context,
           builder: (BuildContext context) {
             return AlertDialog(
               title: Text('Tag ul este bun'),
               content: Text('Acum poti continua'),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.pop(context);
                   },
                   child: Text('OK'),
                 ),
               ],
             );
           },
         );
       }
    else {

        // Do something else if the specific data is not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Oho'),
              content: Text('Tagul nu este bun'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
    }});
}


  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);

      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      NdefMessage message = NdefMessage([
        NdefRecord.createText('polA ME'),
      ]);


      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}
