import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatador de entrada para valores monetários brasileiros
/// Formata automaticamente conforme o usuário digita
class CurrencyInputFormatter extends TextInputFormatter {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se o texto está vazio, retorna vazio
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove todos os caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Se não há dígitos, retorna vazio
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte para centavos (para tratamento de decimais)
    int cents = int.parse(digitsOnly);

    // Converte de volta para reais (divide por 100)
    double value = cents / 100.0;

    // Formata o valor
    String formatted = _currencyFormatter.format(value);

    // Calcula a nova posição do cursor
    int cursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Converte o texto formatado para double
  static double? parseValue(String formattedText) {
    if (formattedText.isEmpty) return null;

    // Remove formatação e converte para double
    String cleanText = formattedText
        .replaceAll('.', '') // Remove separadores de milhares
        .replaceAll(',', '.'); // Troca vírgula por ponto decimal

    return double.tryParse(cleanText);
  }

  /// Formata um valor double para o formato de entrada
  static String formatValue(double value) {
    if (value == 0) return '';
    return _currencyFormatter.format(value);
  }
}
