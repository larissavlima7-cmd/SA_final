import 'package:book_nook/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  //carregamento dos widgets ao inicializar
  WidgetsFlutterBinding.ensureInitialized();
  //conectar a aplicação ao firebase
  await Firebase.initializeApp();
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,//tira o banner do debug
    home: AuthScreen(),));
}