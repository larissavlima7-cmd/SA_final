import 'package:book_nook/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //atributos
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();


  Future<void> _singin() async{
    try{
      //tenta a conexão com email e senha
      await _auth.signInWithEmailAndPassword(email: _email.text, password: _senha.text);
    } on FirebaseAuthException catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha de Autenticação: ${e.message}"),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Nook - Login',style: TextStyle(fontSize:24),),backgroundColor: const Color.fromARGB(255, 238, 105, 149),),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: const Color.fromARGB(255, 238, 105, 149),
            ),
            const SizedBox(height: 40,),
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none), filled: true),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _senha,
              decoration: InputDecoration(labelText: 'Senha',  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none), filled: true),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: _singin, child: Text('Login'),),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Não tem uma conta? Registre-se'),
            ),
          ],
        ),
      ),
    );
  }
  
}