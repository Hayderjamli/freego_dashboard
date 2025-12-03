import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/login_page.dart';
import 'package:mobile_app_dashboard/signup_page.dart';
import 'main.dart'; // Using AppPalette from main

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppPalette.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background circles
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (_controller.value * 50),
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppPalette.electricBlue.withOpacity(0.15),
                              AppPalette.electricBlue.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150 + (_controller.value * 80),
                      left: -120,
                      child: Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppPalette.sportGreen.withOpacity(0.12),
                              AppPalette.sportGreen.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const AnimatedFreeGoLogo(size: 60),
                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (bounds) => AppPalette.leafGradient.createShader(bounds),
                      child: Text(
                        'WELCOME TO FREEGO',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Smart Agriculture Monitoring',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppPalette.electricBlue,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Monitor temperature, humidity, and greenhouse conditions with real-time analytics for optimal crop growth.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppPalette.textSecondary,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 56),
                    _AnimatedButton(
                      label: 'SIGN IN',
                      gradient: AppPalette.sportGradient,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _AnimatedButton(
                      label: 'CREATE ACCOUNT',
                      gradient: AppPalette.energyGradient,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final LinearGradient gradient;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: widget.outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2.5,
                    color: AppPalette.electricBlue,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.electricBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.electricBlue.withOpacity(0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.outlined ? AppPalette.electricBlue : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
