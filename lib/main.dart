import 'dart:async';
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lastnumber/controller.dart';

import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  ContactController controller = Get.put(ContactController());
  Workmanager().executeTask((task, inputData) async {
    // print("Hi phone is sent ${controller.lastCall}");
    // print('object${controller.formatttedDate}');
    //
    final storage = const FlutterSecureStorage();
    String lastCall = 'Loading...';
    String formatttedDate = '';
    Iterable<CallLogEntry> entries = await CallLog.query();

    // Convert the iterable to a list and sort it by date
    List<CallLogEntry> sortedEntries = entries.toList()
      ..sort((a, b) => b.timestamp!.compareTo(a.timestamp as num));

    // Limit the results to 1
    sortedEntries = sortedEntries.take(1).toList();

    if (sortedEntries.isNotEmpty) {
      CallLogEntry lastCallEntry = sortedEntries.first;
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(lastCallEntry.timestamp!));

      lastCall = lastCallEntry.formattedNumber!;
      formatttedDate = formattedDate;
      print('====================');
      print(lastCall);
      print(formattedDate);
      // await storage.write(key: 'data', value: lastCallEntry.formattedNumber!);
      // print('Storge:${(await storage.read(key: 'data'))!} ');
      print(await storage.read(key: 'data'));
      controller.last = lastCallEntry.formattedNumber!;
      controller.dat = formattedDate;

      await storage.read(key: 'data') != formattedDate
          ? controller.putVar()
          : print('The Same');
    } else {
      lastCall = '';
      formatttedDate = '';
      // setState(() {
      //   lastCall = 'No calls found';
      // });
    }
    //
    // controller.getLastCall();

    return Future.value(true);
  });
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // متغير يحتوي على قيمة الـ ID
  String taskId = "bemo";

  // تسجيل المهمة بشكل دوري باستخدام الـ ID المخزن في المتغير
  Workmanager().registerPeriodicTask(
    taskId,
    "$taskId Task",
    frequency: Duration(seconds: 10),
  );

  // تحديث قيمة الـ ID بشكل دوري
  Timer.periodic(Duration(seconds: 10), (Timer timer) {
    String uniqueCode = Uuid().v4();

    taskId = "new_bemo_id"; // قم بتحديث القيمة بما يناسب احتياجاتك
    Workmanager().registerPeriodicTask(
      uniqueCode,
      "$taskId Task",
      frequency: Duration(seconds: 10),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LastCallWidget(),
    );
  }
}

class LastCallWidget extends StatefulWidget {
  @override
  _LastCallWidgetState createState() => _LastCallWidgetState();
}

class _LastCallWidgetState extends State<LastCallWidget> {
  String lastCall = 'Loading...';
  ContactController controller = Get.put(ContactController());

  @override
  void initState() {
    super.initState();
    getLastCall();
  }

  Future<void> getLastCall() async {
    // Query call logs
    Iterable<CallLogEntry> entries = await CallLog.query();

    // Convert the iterable to a list and sort it by date
    List<CallLogEntry> sortedEntries = entries.toList()
      ..sort((a, b) => b.timestamp!.compareTo(a.timestamp as num));

    // Limit the results to 1
    sortedEntries = sortedEntries.take(1).toList();

    if (sortedEntries.isNotEmpty) {
      CallLogEntry lastCallEntry = sortedEntries.first;
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(lastCallEntry.timestamp!));

      setState(() {
        lastCall =
            'Last Call: ${lastCallEntry.formattedNumber}\nDate: $formattedDate';
      });
    } else {
      setState(() {
        lastCall = 'No calls found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: InkWell(
        onTap: () {
          controller.postNumber();
        },
        child: Text(
          lastCall,
          style: TextStyle(fontSize: 20),
        ),
      ),
    ));
  }
}
