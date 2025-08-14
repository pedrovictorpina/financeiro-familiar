class Planejamento {
  final String id;
  final String categoriaId;
  final double limite;
  final String mes; // formato: "2024-01"
  final double gastoAtual;

  Planejamento({
    required this.id,
    required this.categoriaId,
    required this.limite,
    required this.mes,
    this.gastoAtual = 0.0,
  });

  factory Planejamento.fromMap(Map<String, dynamic> map, String id) {
    return Planejamento(
      id: id,
      categoriaId: map['categoriaId'] ?? '',
      limite: (map['limite'] ?? 0.0).toDouble(),
      mes: map['mes'] ?? '',
      gastoAtual: (map['gastoAtual'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoriaId': categoriaId,
      'limite': limite,
      'mes': mes,
      'gastoAtual': gastoAtual,
    };
  }

  Planejamento copyWith({
    String? id,
    String? categoriaId,
    double? limite,
    String? mes,
    double? gastoAtual,
  }) {
    return Planejamento(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      limite: limite ?? this.limite,
      mes: mes ?? this.mes,
      gastoAtual: gastoAtual ?? this.gastoAtual,
    );
  }

  double get percentualGasto {
    if (limite <= 0) return 0;
    return (gastoAtual / limite) * 100;
  }

  double get saldoRestante => limite - gastoAtual;

  bool get isLimiteExcedido => gastoAtual > limite;

  bool get isProximoDoLimite => percentualGasto >= 80;

  StatusPlanejamento get status {
    if (isLimiteExcedido) return StatusPlanejamento.excedido;
    if (isProximoDoLimite) return StatusPlanejamento.atencao;
    return StatusPlanejamento.normal;
  }
}

enum StatusPlanejamento { normal, atencao, excedido }
