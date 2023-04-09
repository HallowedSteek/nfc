import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


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

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // if-ul acesta verific a daca tag ul nfc contine codul unic artbyte
      //  momentan acesta este in format string, dar cand vom crea functiile pentru cripatre si decriptare, .contains() va
      //  va contine variabila petru criptare si decriptare.
      NfcManager.instance.stopSession();
      final ndefTag = Ndef.from(tag);
      final ndefRecord = NdefRecord.createText(tag.data.toString());
      final ndefMessage = NdefMessage([ndefRecord]);
      final wellKnownRecord = ndefMessage.records.first;
        final date = wellKnownRecord.payload.toList();
        //Note that the language code can be encoded in ASCI, if you need it be carfully with the endoding
        final payload = utf8.decode(date);
        String mesaj = payload.toString();
      //Cutting of the language code
      //   String payload = String.fromCharCodes(ndefRecord.payload);
      if(mesaj.contains('artbyte')) {
        result.value='Tagus este bun! Poti Continua';
      }
      else
        {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Oho'),
                content: Text('Tagul nu este bun.Dar poti achizitiona unul!!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: InkWell(
                        child:  Text('Open Browser'),
                      onTap: () async {
                        const url = 'https://www.youtube.com/@artbyte5198';
                        if(await canLaunch(url)){
                          await launch(url);
                        }else {
                          throw 'Could not launch $url';
                        }
                        }
                    ),
                  ),
                ],
              );
            },
          );
        }
    });
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
        NdefRecord.createText('artbyte'),
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
