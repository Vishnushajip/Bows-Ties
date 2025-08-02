import 'package:bowsandties/Login/Provider/adminloginControllerProvider.dart';
import 'package:bowsandties/Login/reusable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AgentLoginPageState createState() => _AgentLoginPageState();
}

class _AgentLoginPageState extends ConsumerState<AdminLoginPage> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(adminloginControllerProvider);
    final notifier = ref.read(adminloginControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width < 600
                  ? double.infinity
                  : 400,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/Screenshot 2025-06-05 161647.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Admin Login",
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ReusableTextField(
                    hint: "Enter your username",
                    label: "Enter your username",
                    controller: usernameController,
                  ),
                  const SizedBox(height: 16),
                  ReusableTextField(
                    text: true,
                    label: 'Password',
                    hint: "Password",
                    controller: passwordController,
                  ),
                  const SizedBox(height: 24),
                  controller.isLoading
                      ? LoadingAnimationWidget.threeArchedCircle(
                          color: const Color.fromARGB(255, 17, 70, 114),
                          size: 25,
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                17,
                                70,
                                114,
                              ),
                            ),
                            onPressed: () async {
                              final success = await notifier.login(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );
                              WidgetsBinding.instance.addPostFrameCallback((
                                _,
                              ) async {
                                if (!mounted) return;
                                if (success && context.mounted) {
                                  context.goNamed('DashBoard');
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('role', 'admin');
                                } else if (controller.error != null &&
                                    controller.error!.isNotEmpty) {
                                  Fluttertoast.showToast(
                                    msg: controller.error!,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              });
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.nunito(color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
