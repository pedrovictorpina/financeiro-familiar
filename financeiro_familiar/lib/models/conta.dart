import 'package:flutter/material.dart';

enum TipoConta { banco, carteira, poupanca, investimento }

class Conta {
  final String id;
  final String nome;
  final TipoConta tipo;
  final double saldoAtual;
  final double saldoPrevisto;
  final Color cor;
  final String? banco; // Chave do banco para identificação

  Conta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.saldoAtual,
    required this.saldoPrevisto,
    required this.cor,
    this.banco,
  });

  factory Conta.fromMap(Map<String, dynamic> map, String id) {
    return Conta(
      id: id,
      nome: map['nome'] ?? '',
      tipo: TipoConta.values.firstWhere(
        (e) => e.toString().split('.').last == map['tipo'],
        orElse: () => TipoConta.banco,
      ),
      saldoAtual: (map['saldoAtual'] ?? 0.0).toDouble(),
      saldoPrevisto: (map['saldoPrevisto'] ?? 0.0).toDouble(),
      cor: map['cor'] != null && map['cor'] is String
          ? Color(int.parse(map['cor'].replaceFirst('#', '0xFF')))
          : Color(map['cor'] ?? 0xFF4CAF50),
      banco: map['banco'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo.toString().split('.').last,
      'saldoAtual': saldoAtual,
      'saldoPrevisto': saldoPrevisto,
      'cor': cor.toARGB32(),
      'banco': banco,
    };
  }

  Conta copyWith({
    String? id,
    String? nome,
    TipoConta? tipo,
    double? saldoAtual,
    double? saldoPrevisto,
    Color? cor,
    String? banco,
  }) {
    return Conta(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      saldoAtual: saldoAtual ?? this.saldoAtual,
      saldoPrevisto: saldoPrevisto ?? this.saldoPrevisto,
      cor: cor ?? this.cor,
      banco: banco ?? this.banco,
    );
  }

  String get tipoNome {
    switch (tipo) {
      case TipoConta.banco:
        return 'Banco';
      case TipoConta.carteira:
        return 'Carteira';
      case TipoConta.poupanca:
        return 'Poupança';
      case TipoConta.investimento:
        return 'Investimento';
    }
  }
}