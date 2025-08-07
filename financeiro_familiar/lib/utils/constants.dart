import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppConstants {
  // Cores predefinidas para categorias e contas
  static const List<Color> availableColors = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Grey
    Color(0xFF607D8B), // Blue Grey
  ];

  // Ícones para categorias de receita
  static const Map<String, IconData> receitaIcons = {
    'salary': Icons.work,
    'business': Icons.business,
    'investment': Icons.trending_up,
    'gift': Icons.card_giftcard,
    'bonus': Icons.star,
    'freelance': Icons.laptop,
    'rental': Icons.home,
    'dividend': Icons.account_balance,
    'refund': Icons.refresh,
    'other_income': Icons.attach_money,
  };

  // Ícones para categorias de despesa
  static const Map<String, IconData> despesaIcons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'housing': Icons.home,
    'utilities': Icons.electrical_services,
    'healthcare': Icons.local_hospital,
    'education': Icons.school,
    'entertainment': Icons.movie,
    'shopping': Icons.shopping_bag,
    'travel': Icons.flight,
    'insurance': Icons.security,
    'phone': Icons.phone,
    'internet': Icons.wifi,
    'gym': Icons.fitness_center,
    'beauty': Icons.face,
    'pet': Icons.pets,
    'charity': Icons.volunteer_activism,
    'tax': Icons.receipt_long,
    'other_expense': Icons.more_horiz,
  };

  // Ícones para tipos de conta
  static const Map<String, IconData> contaIcons = {
    'bank': Icons.account_balance,
    'wallet': Icons.account_balance_wallet,
    'savings': Icons.savings,
    'investment': Icons.trending_up,
    'credit_card': Icons.credit_card,
    'cash': Icons.money,
  };

  // Ícones para metas
  static const Map<String, IconData> metaIcons = {
    'emergency': Icons.security,
    'vacation': Icons.beach_access,
    'car': Icons.directions_car,
    'house': Icons.home,
    'education': Icons.school,
    'wedding': Icons.favorite,
    'retirement': Icons.elderly,
    'electronics': Icons.devices,
    'health': Icons.favorite,
    'business': Icons.business,
    'other': Icons.flag,
  };

  // Bandeiras de cartão de crédito
  static const Map<String, String> cartaoBandeiras = {
    'visa': 'Visa',
    'mastercard': 'Mastercard',
    'elo': 'Elo',
    'american_express': 'American Express',
    'hipercard': 'Hipercard',
    'diners': 'Diners Club',
    'discover': 'Discover',
    'other': 'Outro',
  };

  // Tipos de transação recorrente
  static const Map<String, String> tiposRecorrencia = {
    'daily': 'Diário',
    'weekly': 'Semanal',
    'monthly': 'Mensal',
    'quarterly': 'Trimestral',
    'yearly': 'Anual',
  };

  // Configurações padrão
  static const String defaultCurrency = 'BRL';
  static const String defaultLocale = 'pt_BR';
  
  // Limites da aplicação
  static const int maxCategorias = 50;
  static const int maxContas = 20;
  static const int maxCartoes = 10;
  static const int maxMetas = 20;
  static const int maxUsuariosPorOrcamento = 5;
  
  // Configurações de cache
  static const Duration cacheTimeout = Duration(minutes: 30);
  
  // Configurações de sincronização
  static const Duration syncInterval = Duration(minutes: 5);
  
  // Mensagens padrão
  static const String noDataMessage = 'Nenhum dado encontrado';
  static const String loadingMessage = 'Carregando...';
  static const String errorMessage = 'Ocorreu um erro. Tente novamente.';
  static const String successMessage = 'Operação realizada com sucesso!';
  
  // Validações
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;
  
  // Formatação
  static const int currencyDecimalPlaces = 2;
  static const int percentageDecimalPlaces = 1;
  
  // URLs e links
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'suporte@financeirofamiliar.com';
  
  // Configurações do Firebase
  static const String firestoreTimeout = '30s';
  
  // Configurações de notificação
  static const String notificationChannelId = 'financeiro_familiar';
  static const String notificationChannelName = 'Financeiro Familiar';
  
  // Chaves para SharedPreferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstRun = 'first_run';
  static const String keyLastSync = 'last_sync';
  static const String keySelectedBudget = 'selected_budget';
  
  // Configurações de gráficos
  static const double chartAnimationDuration = 1.5;
  static const int maxChartDataPoints = 12;
  
  // Configurações de dashboard
  static const int maxDashboardCards = 8;
  
  // Métodos utilitários
  static Color getColorByIndex(int index) {
    return availableColors[index % availableColors.length];
  }
  
  static IconData getReceitaIcon(String key) {
    return receitaIcons[key] ?? Icons.attach_money;
  }
  
  static IconData getDespesaIcon(String key) {
    return despesaIcons[key] ?? Icons.more_horiz;
  }
  
  static IconData getContaIcon(String key) {
    return contaIcons[key] ?? Icons.account_balance_wallet;
  }
  
  static IconData getMetaIcon(String key) {
    return metaIcons[key] ?? Icons.flag;
  }
  
  static String getBandeiraCartao(String key) {
    return cartaoBandeiras[key] ?? 'Outro';
  }
  
  static String getTipoRecorrencia(String key) {
    return tiposRecorrencia[key] ?? 'Mensal';
  }
  
  // Validadores
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
  
  static bool isValidCurrency(double value) {
    return value >= 0 && value <= 999999999.99;
  }
  
  static bool isValidPercentage(double value) {
    return value >= 0 && value <= 100;
  }
}

// Enums para tipos específicos
enum DashboardCardType {
  saldoGeral,
  receitasMes,
  despesasMes,
  saldoMes,
  contasPrincipais,
  metasProgresso,
  gastosCategoria,
  planejamentoMensal,
}

enum ChartType {
  pizza,
  barra,
  linha,
  area,
}

enum PeriodType {
  semana,
  mes,
  trimestre,
  semestre,
  ano,
}

enum TransactionFilter {
  todos,
  receitas,
  despesas,
  transferencias,
}