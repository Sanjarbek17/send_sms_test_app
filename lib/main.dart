import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:direct_sms/direct_sms.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var directSms = DirectSms();
  List numbers = [];
  List sendNumbers = [];
  String label = "No file selected";
  int counter = 0;

  @override
  void initState() {
    super.initState();
  }

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
  }

  @override
  Widget build(BuildContext context) {
    // var phoneController = TextEditingController();
    var messageController = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              sendNumbers = [];
            });
          },
          child: const Text('clear'),
        ),
        appBar: AppBar(
          title: const Text('Message sender app'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  // a button to pick a file
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.white,
                        // foregroundColor: const Color.fromARGB(255, 146, 146, 146),
                        minimumSize: const Size(40, 60),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color.fromARGB(255, 150, 149, 149), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // pick a file
                        FilePickerResult? result = await FilePicker.platform.pickFiles();

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          var map = jsonDecode(file.readAsStringSync());
                          // change the label
                          setState(() {
                            numbers = map;
                            label = result.files.single.name;
                          });
                        } else {
                          // User canceled the picker
                        }
                      },
                      child: const Text("Pick a file"),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: TextField(
                      enabled: false,
                      // controller: phoneController,
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text(label),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                // make input decoration bigger
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Message",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (numbers.isNotEmpty) {
                    for (var number in numbers) {
                      try {
                        _sendSms(message: messageController.text, number: number["phone"].trim());
                        setState(() {
                          sendNumbers.add(number);
                          counter++;
                        });
                      } catch (e) {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: Text("$e"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      }
                    }
                    // ignore: use_build_context_synchronously
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Message"),
                          content: Text("Message sended to $counter users"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    counter = 0;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"))
                          ],
                        );
                      },
                    );
                  } else {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text("Please select a file"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"))
                            ],
                          );
                        });
                  }
                },
                child: Text(counter == 0 ? "Send" : "Sended $counter"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sendNumbers.length,
                  itemBuilder: (context, index) {
                    if (sendNumbers.isNotEmpty) {
                      return Text("${('${index + 1}:').padRight(4)} ${sendNumbers[index % sendNumbers.length]['name']}");
                    }
                    return null;
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
