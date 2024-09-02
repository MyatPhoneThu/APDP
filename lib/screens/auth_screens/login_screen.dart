import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/auth.dart';
import '../../widgets/password_text_form_field.dart';
import '../task_screen/task_list.dart';
import './registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isLoginInProgress;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _isLoginInProgress = false;
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Galaxy Ray',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4D4DC6),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'user@gmail.com',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                PasswordTextFormField(
                  labelText: 'Password',
                  passwordEditingController: _passwordController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter password.';
                    } else if (value!.length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _isLoginInProgress == true
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() == true) {
                            loginUser(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4DC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  child: Visibility(
                    visible: _isLoginInProgress,
                    replacement: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white, // Adjust text color
                      ),
                    ),
                    child: const CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (cntxt) => const RegistrationScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4D4DC6),
                      ),
                      child: const Text(
                        'Create Account',
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoginInProgress = true;
    if (mounted) {
      setState(() {});
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoginInProgress = false;
      if (mounted) {
        setState(() {});
      }
      log(userCredential.user.toString());
      if (userCredential.user?.emailVerified == false) {
        showToastMessage('Please verify your account.',
            color: Colors.red, actionLabel: 'SEND', action: () async {
          await userCredential.user?.sendEmailVerification();
          showToastMessage(
            'Verification URL is sent to your email.',
            color: Colors.green,
          );
        });
      } else if (userCredential.user?.emailVerified == true) {
        log('login success');
        final UserModel user = UserModel(
          userEmail: email,
          userId: userCredential.user!.uid,
        );
        await UserAuth().saveUserAuth(user);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (cntxt) => const TaskScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('user-not-found') == true ||
          e.code.contains('wrong-password') == true) {
        showToastMessage('E-mail or Password is incorrect!', color: Colors.red);
      }
    } catch (e) {
      showToastMessage(e.toString(), color: Colors.red);
    }

    _isLoginInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  void showToastMessage(String content,
      {Color color = Colors.green, VoidCallback? action, String? actionLabel}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                onPressed: () {
                  if (action != null) {
                    action();
                  }
                },
                label: actionLabel,
                textColor: Colors.white,
                backgroundColor: Colors.black38,
              ),
      ),
    );
  }
}
