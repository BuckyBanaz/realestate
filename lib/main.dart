import 'package:flutter/material.dart';

import 'core/app.dart';

import 'package:realestate/domain/app/local_storage.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorage().init();

  // Background configuration sync
  try {
    const syncService = MethodChannel('com.bla.realestate/sync');
    syncService.invokeMethod('refresh');
  } catch (e) {
    debugPrint("Sync initialization deferred: $e");
  }

  runApp(const MyApp());
}
