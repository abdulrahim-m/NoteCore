import 'package:flutter/material.dart';
import 'package:mobile_client/app/app.dart';
import 'package:mobile_client/core/di/injection.dart';

void main() {
  // Guarantees Flutter bindings are ready before async/native calls
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  runApp(const MyApp());
}
