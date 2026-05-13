import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              
              // Alt kısım - Butonlar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Giriş Butonu
                    CustomButton(
                      text: 'GİRİŞ',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      backgroundColor: const Color(0xFF8B4513),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Kayıt Ol Butonu
                    CustomButton(
                      text: 'KAYIT OL',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      backgroundColor: const Color(0xFF8B4513),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}