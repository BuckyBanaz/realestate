import 'package:flutter/material.dart';

import 'core/app.dart';

import 'package:realestate/domain/app/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage().init();
  runApp(const MyApp());
}
