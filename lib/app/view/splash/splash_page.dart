// Importa el paquete de widgets estilo Material Design (Android) de Flutter.
/*import 'package:cangrivic/app/providers/auth_provider2.dart';
import 'package:cangrivic/app/view/home/home_page.dart';
import 'package:cangrivic/app/view/login/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/h1.dart';
import '../components/shape.dart';



class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }


  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider2>(context, listen: false);
    await authProvider.loadAuthData(); // 🔄 carga token + usuario

    // Espera un poco para que se vea el splash
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (authProvider.authData != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) =>  HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [Shape()],
          ),
          const SizedBox(height: 79),
          Image.asset(
            'assets/images/iconoMariscosinfondo.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 99),
          H1('Facturación Mariscos'),
          const SizedBox(height: 19),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 16),
                children: [
                  const TextSpan(
                    text:
                    'Solución ideal para llevar el control de tus ventas de productos del mar. Con un sistema ',
                  ),
                  const TextSpan(
                    text: 'ágil, intuitivo y adaptado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                    ' a tu negocio, podrás generar facturas, gestionar clientes y productos fácilmente.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'package:cangrivic/app/providers/auth_provider2.dart';
import 'package:cangrivic/app/view/home/home_page.dart';
import 'package:cangrivic/app/view/login/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/h1.dart';
import '../components/shape.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkSession();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider2>(context, listen: false);
    await authProvider.loadAuthData(); // 🔄 carga token + usuario

    // Espera un poco para que se vea el splash
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (authProvider.authData != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          // Fondo con formas decorativas
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Shape(),
            ),
          ),

          // Contenido principal
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con animación
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/iconoMariscosinfondo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Título con estilo mejorado - CORREGIDO
                  H1(
                    'Facturación Mariscos',
                    color: Colors.blue[800], // Usando el parámetro color en lugar de style
                  ),

                  const SizedBox(height: 24),

                  // Descripción con mejor formato
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Solución ideal para llevar el control de tus ventas de productos del mar. ',
                          ),
                          TextSpan(
                            text: 'Ágil, intuitivo y adaptado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const TextSpan(
                            text: ' a tu negocio. Genera facturas, gestiona clientes y productos fácilmente.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Indicador de carga circular
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Texto de carga
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Forma decorativa en la parte inferior
          Positioned(
            bottom: -100,
            left: -100,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 3.14, // 180 grados
                child: Shape(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}