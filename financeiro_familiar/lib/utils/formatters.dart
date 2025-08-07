import 'package:intl/intl.dart';

class Formatters {
  // Formatador de moeda brasileira
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\u0024',
    decimalDigits: 2,
  );

  // Formatador de data brasileira
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
  
  // Formatador de data e hora
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  
  // Formatador de mês/ano
  static final DateFormat _monthYearFormatter = DateFormat('MM/yyyy', 'pt_BR');
  
  // Formatador de mês por extenso
  static final DateFormat _monthNameFormatter = DateFormat('MMMM yyyy', 'pt_BR');
  
  // Formatador de dia da semana
  static final DateFormat _weekdayFormatter = DateFormat('EEEE', 'pt_BR');

  /// Formata um valor monetário para o padrão brasileiro
  static String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  /// Formata uma data para o padrão brasileiro (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Formata uma data e hora para o padrão brasileiro (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Formata mês/ano (MM/yyyy)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Formata mês por extenso (Janeiro 2024)
  static String formatMonthName(DateTime date) {
    final formatted = _monthNameFormatter.format(date);
    return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  /// Formata dia da semana
  static String formatWeekday(DateTime date) {
    final formatted = _weekdayFormatter.format(date);
    return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  /// Converte string de data (dd/MM/yyyy) para DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Converte string de moeda para double
  static double? parseCurrency(String currencyString) {
    try {
      // Remove símbolos e espaços
      String cleanString = currencyString
          .replaceAll('R\u0024', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Formata porcentagem
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  /// Formata número com separadores de milhares
  static String formatNumber(double value, {int decimalPlaces = 0}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', 'pt_BR');
    return formatter.format(value);
  }

  /// Retorna a diferença em dias entre duas datas
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Retorna o primeiro dia do mês
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Retorna o último dia do mês
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Retorna o mês anterior
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  /// Retorna o próximo mês
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  /// Verifica se duas datas são do mesmo mês
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Verifica se a data é hoje
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Verifica se a data é ontem
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  /// Retorna uma descrição relativa da data (hoje, ontem, etc.)
  static String getRelativeDateDescription(DateTime date) {
    if (isToday(date)) {
      return 'Hoje';
    } else if (isYesterday(date)) {
      return 'Ontem';
    } else {
      final daysDifference = daysBetween(date, DateTime.now());
      if (daysDifference > 0 && daysDifference <= 7) {
        return 'Há $daysDifference ${daysDifference == 1 ? 'dia' : 'dias'}';
      } else {
        return formatDate(date);
      }
    }
  }

  /// Formata valor com sinal (+ ou -)
  static String formatCurrencyWithSign(double value) {
    final formatted = formatCurrency(value.abs());
    return value >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Abrevia números grandes (1K, 1M, etc.)
  static String abbreviateNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  /// Capitaliza a primeira letra de cada palavra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Remove acentos de uma string
  static String removeAccents(String text) {
    const withAccents = 'àáâãäåæçèéêëìíîïñòóôõöøùúûüýÿ';
    const withoutAccents = 'aaaaaaeceeeeiiiinoooooouuuuyy';
    
    String result = text.toLowerCase();
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }
}