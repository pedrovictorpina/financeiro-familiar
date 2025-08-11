import 'package:flutter/material.dart';

/// Extensões para cores que se adaptam automaticamente ao tema
extension ThemeColors on BuildContext {
  // Cores de fundo
  Color get primaryBackground => Theme.of(this).colorScheme.surface;
  Color get secondaryBackground => Theme.of(this).colorScheme.surfaceVariant;
  Color get cardBackground => Theme.of(this).cardColor;
  
  // Cores de texto
  Color get primaryText => Theme.of(this).colorScheme.onSurface;
  Color get secondaryText => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get mutedText => Theme.of(this).colorScheme.onSurface.withOpacity(0.6);
  
  // Cores de estado
  Color get successColor => const Color(0xFF4CAF50);
  Color get errorColor => Theme.of(this).colorScheme.error;
  Color get warningColor => const Color(0xFFFF9800);
  Color get infoColor => Theme.of(this).colorScheme.primary;
  
  // Cores específicas do app
  Color get receitaColor => const Color(0xFF4CAF50);
  Color get despesaColor => const Color(0xFFF44336);
  Color get transferenceColor => Theme.of(this).colorScheme.primary;
  
  // Cores de overlay
  Color get overlayColor => Theme.of(this).colorScheme.onSurface.withOpacity(0.1);
  Color get dividerColor => Theme.of(this).dividerColor;
  
  // Cores de container
  Color get containerColor => Theme.of(this).brightness == Brightness.dark 
      ? const Color(0xFF2A2A2A) 
      : const Color(0xFFF5F5F5);
      
  Color get containerColorSecondary => Theme.of(this).brightness == Brightness.dark 
      ? const Color(0xFF3A3A3A) 
      : const Color(0xFFE0E0E0);
      
  // Cores de destaque
  Color get accentColor => const Color(0xFF8B5CF6);
  Color get accentColorLight => const Color(0xFF8B5CF6).withOpacity(0.2);
  
  // Cores de dropdown
  Color get dropdownColor => Theme.of(this).brightness == Brightness.dark 
      ? const Color(0xFF2A2A2A) 
      : Colors.white;
      
  // Cores de borda
  Color get borderColor => Theme.of(this).brightness == Brightness.dark 
      ? Colors.grey.withOpacity(0.3) 
      : Colors.grey.withOpacity(0.5);
      
  // Cores de ícones
  Color get iconColor => Theme.of(this).iconTheme.color ?? Theme.of(this).colorScheme.onSurface;
  Color get iconColorMuted => Theme.of(this).colorScheme.onSurface.withOpacity(0.6);
}

/// Cores específicas para diferentes tipos de transação
class TransactionColors {
  static const Color receita = Color(0xFF4CAF50);
  static const Color despesa = Color(0xFFF44336);
  static const Color transferencia = Color(0xFF2196F3);
  
  static Color getReceitaBackground(BuildContext context) {
    return receita.withOpacity(context.brightness == Brightness.dark ? 0.2 : 0.1);
  }
  
  static Color getDespesaBackground(BuildContext context) {
    return despesa.withOpacity(context.brightness == Brightness.dark ? 0.2 : 0.1);
  }
  
  static Color getTransferenciaBackground(BuildContext context) {
    return transferencia.withOpacity(context.brightness == Brightness.dark ? 0.2 : 0.1);
  }
}

/// Cores para categorias que se adaptam ao tema
class CategoryColors {
  static const List<Color> colors = [
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Yellow
    Color(0xFFFF6B35), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF6B7280), // Gray
  ];
  
  static Color getBackgroundColor(Color color, BuildContext context) {
    return color.withOpacity(context.brightness == Brightness.dark ? 0.2 : 0.1);
  }
  
  static Color getBorderColor(Color color, BuildContext context) {
    return color.withOpacity(context.brightness == Brightness.dark ? 0.3 : 0.5);
  }
}

/// Extensão para facilitar o acesso ao brightness
extension BrightnessExtension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
  bool get isDarkMode => brightness == Brightness.dark;
  bool get isLightMode => brightness == Brightness.light;
}