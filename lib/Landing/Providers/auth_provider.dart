// ignore_for_file: unused_result

import 'package:bowsandties/Landing/My_Orders.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final rememberMeProvider = StateProvider<bool>((ref) => false);
final registernameProvider = StateProvider<String>((ref) => '');

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> signInWithEmail(BuildContext context) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);
    final name = ref.read(registernameProvider);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email.trim());
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'email': email.trim(),
        'name': name,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.of(context).pop();
      context.go('/HomePage');
    } catch (e) {
      print('Login failed: $e');
      CustomMessenger(
        context: context,
        message: "Login failed",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      showLoadingDialog(context);
      final googleSignIn = GoogleSignIn(
        clientId:
            '844750189631-dd0gcaqh4jgdi4q3g7as8n9h4eiurtvr.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.of(context).pop();
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', googleUser.email);
      await prefs.setString('name', googleUser.displayName ?? '');
      await prefs.setString('photoUrl', googleUser.photoUrl ?? '');
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(googleUser.email);
      final docSnapshot = await userDoc.get();

      final Map<String, dynamic> updateData = {
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'latestLogin': FieldValue.serverTimestamp(),
      };

      if (!docSnapshot.exists ||
          !docSnapshot.data()!.containsKey('lastLogin')) {
        updateData['lastLogin'] = FieldValue.serverTimestamp();
      }

      await userDoc.set(updateData, SetOptions(merge: true));

      Navigator.of(context).pop();
      context.go('/Home');
      ref.refresh(ordersProvider);
    } catch (e) {
      print('Google login error: $e');
      CustomMessenger(
        context: context,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        message: 'Google login error',
      ).show();
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    final email = ref.read(emailProvider);

    if (email.trim().isEmpty) {
      CustomMessenger(
        context: context,
        message: 'Email is empty',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      CustomMessenger(
        context: context,
        message: 'OTP sent to email',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      ).show();
    } catch (e) {
      CustomMessenger(
        context: context,
        message: 'Failed to send OTP Check Your Email & Password',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
    }
  }
}
