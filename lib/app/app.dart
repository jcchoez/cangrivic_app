
// Importa el paquete de Flutter que contiene los widgets de Material Design.
import 'package:cangrivic/app/view/splash/splash_page.dart';
import 'package:flutter/material.dart';
// Importa la vista principal (home) de la aplicación desde la carpeta app/view.


/// Widget sin estado (StatelessWidget), ideal cuando el contenido del widget
/// no cambia después de ser construido.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Método obligatorio que construye la interfaz del widget.
  @override
  Widget build(BuildContext context) {
    const primary =         Color(0xFF40B7AD);
    const textColor =       Color(0xFF4A4A4A);
    const backgroundColor = Color(0xFFF5F5F5);

    // Retorna un MaterialApp, el widget base para cualquier app Flutter con diseño Material.
    return MaterialApp(
      // Título de la aplicación, visible en algunas plataformas.
      title: 'Flutter Demo',
      //Quitar etiqueta debug
      debugShowCheckedModeBanner: false,

      // Tema global de la aplicación: define colores, estilos, etc.
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          scaffoldBackgroundColor: backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'Poppins',
            bodyColor: textColor,
            displayColor: textColor,
          ),
          //Todso los modales tengas un fondo tranparente
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                //double.infinity todo el ancho q pueda
                  minimumSize: Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )
              )
          )
      ),
      // Página principal de la aplicación, definida en home.dart
      home:  SplashPage(),
    );

  }
}