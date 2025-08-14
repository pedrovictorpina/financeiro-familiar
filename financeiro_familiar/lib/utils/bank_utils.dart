import 'package:flutter/material.dart';

class BankUtils {
  static const Map<String, BankInfo> banksInfo = {
    'itau': BankInfo(
      name: 'Itaú',
      color: Color(0xFFEC7000),
      icon: Icons.account_balance,
    ),
    'bradesco': BankInfo(
      name: 'Bradesco',
      color: Color(0xFFCC092F),
      icon: Icons.account_balance,
    ),
    'santander': BankInfo(
      name: 'Santander',
      color: Color(0xFFEC0000),
      icon: Icons.account_balance,
    ),
    'bb': BankInfo(
      name: 'Banco do Brasil',
      color: Color(0xFFFED100),
      icon: Icons.account_balance,
    ),
    'caixa': BankInfo(
      name: 'Caixa Econômica',
      color: Color(0xFF0066B3),
      icon: Icons.account_balance,
    ),
    'nubank': BankInfo(
      name: 'Nubank',
      color: Color(0xFF8A05BE),
      icon: Icons.credit_card,
    ),
    'inter': BankInfo(
      name: 'Inter',
      color: Color(0xFFFF7A00),
      icon: Icons.account_balance,
    ),
    'c6': BankInfo(
      name: 'C6 Bank',
      color: Color(0xFF000000),
      icon: Icons.credit_card,
    ),
    'next': BankInfo(
      name: 'Next',
      color: Color(0xFF00D4AA),
      icon: Icons.credit_card,
    ),
    'original': BankInfo(
      name: 'Original',
      color: Color(0xFF00A859),
      icon: Icons.account_balance,
    ),
    'picpay': BankInfo(
      name: 'PicPay',
      color: Color(0xFF21C25E),
      icon: Icons.payment,
    ),
    'mercadopago': BankInfo(
      name: 'Mercado Pago',
      color: Color(0xFF009EE3),
      icon: Icons.payment,
    ),
    'carteira': BankInfo(
      name: 'Carteira',
      color: Color(0xFF4CAF50),
      icon: Icons.account_balance_wallet,
    ),
    'poupanca': BankInfo(
      name: 'Poupança',
      color: Color(0xFF2196F3),
      icon: Icons.savings,
    ),
    'investimento': BankInfo(
      name: 'Investimento',
      color: Color(0xFF9C27B0),
      icon: Icons.trending_up,
    ),
    'outro': BankInfo(
      name: 'Outro',
      color: Color(0xFF607D8B),
      icon: Icons.account_balance,
    ),
  };

  static BankInfo getBankInfo(String bankKey) {
    return banksInfo[bankKey.toLowerCase()] ?? banksInfo['outro']!;
  }

  static List<String> getBankKeys() {
    return banksInfo.keys.toList();
  }

  static List<BankInfo> getAllBanks() {
    return banksInfo.values.toList();
  }

  static String getBankKeyByName(String name) {
    for (final entry in banksInfo.entries) {
      if (entry.value.name.toLowerCase() == name.toLowerCase()) {
        return entry.key;
      }
    }
    return 'outro';
  }
}

class BankInfo {
  final String name;
  final Color color;
  final IconData icon;

  const BankInfo({required this.name, required this.color, required this.icon});
}
