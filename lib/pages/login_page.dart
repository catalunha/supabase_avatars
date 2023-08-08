import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSignUp = false;
  bool _isSignIn = false;
  bool _isVerifingCode = false;
  bool _redirecting = false;
  bool _sendCode = false;
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final TextEditingController _codeController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signUp() async {
    try {
      setState(() {
        _isSignUp = true;
      });
      // await supabase.auth.signInWithOtp(
      //   email: _emailController.text.trim(),
      //   emailRedirectTo:
      //       kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      // );
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Check your email for a login code!')),
      //   );
      //   // _emailController.clear();
      //   // _passwordController.clear();
      //   _sendCode = true;
      // }
    } on AuthException catch (error) {
      print('$error');
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSignUp = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    try {
      setState(() {
        _isVerifingCode = true;
      });

      await supabase.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: _codeController.text.trim(),
        type: OtpType.email,
      );
      _sendCode = false;
      _emailController.clear();
      _passwordController.clear();
      _codeController.clear();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifingCode = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    try {
      setState(() {
        _isSignIn = true;
      });
      // await supabase.auth.signInWithOtp(
      //   email: _emailController.text.trim(),
      //   emailRedirectTo:
      //       kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      // );
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Check your email for a login code!')),
      //   );
      //   // _emailController.clear();
      //   // _passwordController.clear();
      //   _sendCode = true;
      // }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSignIn = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Sign in via code with your email below'),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isSignIn ? null : _signIn,
            child: Text(_isSignIn ? 'Loading' : 'Login'),
          ),
          Visibility(
            visible: !_isSignUp && !_isSignIn,
            child: ElevatedButton(
              onPressed: _isSignUp ? null : _signUp,
              child: Text(_isSignUp ? 'Loading' : 'Register'),
            ),
          ),
          Visibility(
            visible: _sendCode,
            child: TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
          ),
          Visibility(
            visible: _sendCode,
            child: ElevatedButton(
              onPressed: _isVerifingCode ? null : _verifyCode,
              child: Text(_isVerifingCode ? 'Verifing' : 'Verify code'),
            ),
          ),
        ],
      ),
    );
  }
}
