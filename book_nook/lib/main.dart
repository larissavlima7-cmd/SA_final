import 'package:book_nook/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main(List<String> args) async {
  //Carregamento dos Widgets  ao inicializar
  WidgetsFlutterBinding.ensureInitialized();
  //Conectar a aplicação ao firebase
  await Firebase.initializeApp();
  runApp(MaterialApp(home: AuthScreen(),));
}