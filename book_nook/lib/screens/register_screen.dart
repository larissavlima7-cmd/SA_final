import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _senhaConfirmacao = TextEditingController(); // Novo controlador

  Future<void> _register() async {
    //vai confirmar se as senhas são iguais antes de tentar criar a conta
    if (_senha.text != _senhaConfirmacao.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem. Tente novamente.")),
      );
      return;
    }

    // se as senhas forem iguais, segue com o registo
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _email.text,
        password: _senha.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha no Registro: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Nook - Registar usuário', style: TextStyle(fontSize: 24)),
        backgroundColor: const Color.fromARGB(255, 238, 105, 149),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Adicionado para evitar erro de tela pequena com o teclado
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 80,
                color: Color.fromARGB(255, 238, 105, 149),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _senha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 14),
              
              TextField(
                controller: _senhaConfirmacao,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Criar Conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}