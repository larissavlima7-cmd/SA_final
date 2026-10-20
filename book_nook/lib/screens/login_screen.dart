import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    // Definindo a cor principal do app
    const Color primaryColor = Color(0xFF6C63FF); 

    return Scaffold(
      backgroundColor: Colors.white, // Fundo limpo
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone da logo
                const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: primaryColor,
                ),
                const SizedBox(height: 24),
                
                // Título
                const Text(
                  "Book Nook",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtítulo
                const Text(
                  "Bem-vindo de volta! Sentimos sua falta.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Campo de E-mail elegante
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo de Senha elegante
                TextField(
                  controller: _senha,
                  obscureText: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                
                // Botão "Esqueceu a senha?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Ação para recuperar senha
                    },
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botão de Login com sombra e cantos arredondados
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 32),
                
                // Rodapé para criar conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Não tem uma conta? ",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    GestureDetector(
                      onPressed: () {
                        // Navegar para tela de registro
                      },
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}