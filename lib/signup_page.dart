import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/auth_service.dart';
import 'package:mobile_app_dashboard/main.dart'; // For HomePage

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppPalette.energyGradient.createShader(bounds),
          child: const Text(
            'CREATE ACCOUNT',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppPalette.electricBlue),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppPalette.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const AnimatedFreeGoLogo(size: 50),
                    const SizedBox(height: 40.0),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppPalette.purpleGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppPalette.electricBlue.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.richPurple.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TextFormField(
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: AppPalette.textMuted),
                              filled: true,
                              fillColor: AppPalette.cardDark.withOpacity(0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppPalette.electricBlue, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.email_rounded, color: AppPalette.electricBlue),
                            ),
                            validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: AppPalette.textMuted),
                              filled: true,
                              fillColor: AppPalette.cardDark.withOpacity(0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppPalette.sportGreen, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.lock_rounded, color: AppPalette.sportGreen),
                            ),
                            validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                          const SizedBox(height: 28.0),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppPalette.energyGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppPalette.vibrantOrange.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                                  if (result == null) {
                                    setState(() => error = 'Please supply a valid email');
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomePage()),
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppPalette.neonPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppPalette.neonPink.withOpacity(0.5)),
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: AppPalette.neonPink,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
