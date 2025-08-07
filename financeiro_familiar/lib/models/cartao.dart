import 'package:flutter/material.dart';

class Cartao {
  final String id;
  final String nome;
  final double limite;
  final double faturaAtual;
  final int fechamentoDia;
  final int vencimentoDia;
  final String? bandeira;
  final Color cor;
  final List<Map<String, dynamic>> faturasMensais;

  Cartao({
    required this.id,
    required this.nome,
    required this.limite,
    required this.faturaAtual,
    required this.fechamentoDia,
    required this.vencimentoDia,
    this.bandeira,
    required this.cor,
    this.faturasMensais = const [],
  });

  factory Cartao.fromMap(Map<String, dynamic> map, String id) {
    print('DEBUG: fromMap - dados recebidos: $map');
    final faturasMensais = List<Map<String, dynamic>>.from(map['faturasMensais'] ?? []);
    print('DEBUG: fromMap - faturasMensais processadas: $faturasMensais');
    return Cartao(
      id: id,
      nome: map['nome'] ?? '',
      limite: (map['limite'] ?? 0.0).toDouble(),
      faturaAtual: (map['faturaAtual'] ?? 0.0).toDouble(),
      fechamentoDia: map['fechamentoDia'] ?? 1,
      vencimentoDia: map['vencimentoDia'] ?? 10,
      bandeira: map['bandeira'],
      cor: _stringToColor(map['cor']),
      faturasMensais: faturasMensais,
    );
  }

  Map<String, dynamic> toMap() {
    print('DEBUG: toMap - faturasMensais: $faturasMensais');
    final map = {
      'nome': nome,
      'limite': limite,
      'faturaAtual': faturaAtual,
      'fechamentoDia': fechamentoDia,
      'vencimentoDia': vencimentoDia,
      if (bandeira != null) 'bandeira': bandeira,
      'cor': _colorToString(cor),
      'faturasMensais': faturasMensais,
    };
    print('DEBUG: toMap - resultado: $map');
    return map;
  }

  Cartao copyWith({
    String? id,
    String? nome,
    double? limite,
    double? faturaAtual,
    int? fechamentoDia,
    int? vencimentoDia,
    String? bandeira,
    Color? cor,
    List<Map<String, dynamic>>? faturasMensais,
  }) {
    return Cartao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      limite: limite ?? this.limite,
      faturaAtual: faturaAtual ?? this.faturaAtual,
      fechamentoDia: fechamentoDia ?? this.fechamentoDia,
      vencimentoDia: vencimentoDia ?? this.vencimentoDia,
      bandeira: bandeira ?? this.bandeira,
      cor: cor ?? this.cor,
      faturasMensais: faturasMensais ?? this.faturasMensais,
    );
  }

  double get faturaAtualCalculada {
    // Soma todas as faturas mensais para representar o total gasto no cartão
    return faturasMensais.fold(0.0, (sum, fatura) => sum + (fatura['valor']?.toDouble() ?? 0.0));
  }
  
  double get limiteDisponivel => limite - faturaAtualCalculada;
  
  double get percentualUtilizado => limite > 0 ? (faturaAtualCalculada / limite) * 100 : 0;
  
  double get totalFaturasMensais {
    return faturasMensais.fold(0.0, (sum, fatura) => sum + (fatura['valor']?.toDouble() ?? 0.0));
  }

  DateTime get proximoFechamento {
    final now = DateTime.now();
    var fechamento = DateTime(now.year, now.month, fechamentoDia);
    
    if (fechamento.isBefore(now)) {
      fechamento = DateTime(now.year, now.month + 1, fechamentoDia);
    }
    
    return fechamento;
  }

  DateTime get proximoVencimento {
    final now = DateTime.now();
    var vencimento = DateTime(now.year, now.month, vencimentoDia);
    
    if (vencimento.isBefore(now)) {
      vencimento = DateTime(now.year, now.month + 1, vencimentoDia);
    }
    
    return vencimento;
  }

  static Color _stringToColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return const Color(0xFF8B5CF6); // Cor padrão
    }
    
    try {
      // Remove o '#' se presente e converte para int
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // Adiciona alpha se não presente
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF8B5CF6); // Cor padrão em caso de erro
    }
  }

  static String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}