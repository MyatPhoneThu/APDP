import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/password_text_form_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isCreateAccountInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4D4DC6),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/money1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter your full name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'user@gmail.com',
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter your email.';
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                          .hasMatch(value!)) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  PasswordTextFormField(
                    labelText: 'Password',
                    passwordEditingController: _passwordController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter your password.';
                      } else if (value!.length < 8) {
                        return 'Password must be at least 8 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  PasswordTextFormField(
                    labelText: 'Confirm Password',
                    
                    passwordEditingController: _confirmPasswordController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Enter confirm password.';
                      } else if (value!.length < 8) {
                        return 'Password must be at least 8 characters.';
                      } else if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isCreateAccountInProgress == true
                        ? null
                        : () {
                            if (_formKey.currentState!.validate() == true) {
                              createUser(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ).then((value) {
                                if (value == true) {
                                  log('-------------');
                                  _formKey.currentState!.reset();
                                  _nameController.clear();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _confirmPasswordController.clear();
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4DC6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4D4DC6),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    _isCreateAccountInProgress = true;
    if (mounted) {
      setState(() {});
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isCreateAccountInProgress = false;

      if (mounted) {
        setState(() {});
      }
      showToastMessage('Account created successfully.');
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();
      showToastMessage('Account activation URL has been sent to your email.');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('weak-password') == true) {
        showToastMessage(
          'The password provided is too weak.',
          color: Colors.red,
        );
      } else if (e.code.contains('email-already-in-use') == true) {
        showToastMessage(
          'An account already exists for that email.',
          color: Colors.red,
        );
      }
    } catch (e) {
      log(e.toString());
      showToastMessage(
        e.toString(),
        color: Colors.red,
      );
    }

    _isCreateAccountInProgress = false;
    if (mounted) {
      setState(() {});
    }
    return false;
  }

  void showToastMessage(String content, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
      ),
    );
  }
}
