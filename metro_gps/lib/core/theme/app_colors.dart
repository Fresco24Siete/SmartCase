import 'package:flutter/material.dart';

/// Paleta de colores minimalista y sistemática para SmartCase (Metro GPS).
/// Inspirada en interfaces limpias, modernas y de alta legibilidad para entornos clínicos e IoT.
abstract class AppColors {
  // Fondos y Superficies
  static const background = Color(0xFFF8FAFC);     // Slate 50
  static const surface = Color(0xFFFFFFFF);        // Blanco puro
  static const surfaceSubtle = Color(0xFFF1F5F9);  // Slate 100
  static const surfaceHover = Color(0xFFE2E8F0);   // Slate 200

  // Bordes y Divisores
  static const border = Color(0xFFE2E8F0);         // Slate 200 (1px)
  static const borderSubtle = Color(0xFFF1F5F9);   // Slate 100
  static const borderFocus = Color(0xFF0F172A);    // Slate 900

  // Tipografía
  static const textPrimary = Color(0xFF0F172A);    // Slate 900 (Contraste principal)
  static const textSecondary = Color(0xFF475569);  // Slate 600 (Secundario/etiquetas)
  static const textMuted = Color(0xFF94A3B8);      // Slate 400 (Placeholders/desactivados)
  static const textInverse = Color(0xFFFFFFFF);    // Texto sobre fondos oscuros

  // Acentos de Marca / Funcionales
  static const primary = Color(0xFF0F172A);        // Slate 900 (Elegancia minimalista)
  static const primaryAccent = Color(0xFF2563EB);  // Azul ultramar sutil para acciones y enlaces
  static const primarySubtle = Color(0xFFEFF6FF);  // Azul 50 (fondos de selección)
  static const primaryLight = Color(0xFFEFF6FF);   // Alias para primarySubtle

  static const secondary = Color(0xFF0D9488);      // Teal médico nórdico
  static const secondarySubtle = Color(0xFFF0FDFA);// Teal 50

  // Estados Semánticos
  static const success = Color(0xFF10B981);        // Verde esmeralda (Completado / En rango)
  static const successSubtle = Color(0xFFECFDF5);  // Verde 50
  static const successBg = Color(0xFFECFDF5);      // Alias para successSubtle

  static const warning = Color(0xFFF59E0B);        // Ámbar (Alerta de sensor / Precaución)
  static const warningSubtle = Color(0xFFFFFBEB);  // Ámbar 50
  static const warningBg = Color(0xFFFFFBEB);      // Alias para warningSubtle

  static const error = Color(0xFFEF4444);          // Rojo carmesí (Peligro / Desconexión)
  static const errorSubtle = Color(0xFFFEF2F2);    // Rojo 50
  static const errorBg = Color(0xFFFEF2F2);        // Alias para errorSubtle
  static const danger = Color(0xFFEF4444);         // Alias para error
  static const dangerBg = Color(0xFFFEF2F2);       // Alias para errorSubtle

  static const info = Color(0xFF0284C7);           // Sky 600 (Información)
  static const infoSubtle = Color(0xFFF0F9FF);     // Sky 50
}
