enum TipoTransacao { receita, despesa, transferencia }

class Transacao {
  final String id;
  final TipoTransacao tipo;
  final double valor;
  final DateTime data;
  final String descricao;
  final String categoriaId;
  final String contaId;
  final bool recorrente;
  final String criadoPor;
  final DateTime timestamp;
  final String? contaDestinoId; // Para transferências

  Transacao({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.data,
    required this.descricao,
    required this.categoriaId,
    required this.contaId,
    required this.recorrente,
    required this.criadoPor,
    required this.timestamp,
    this.contaDestinoId,
  });

  factory Transacao.fromMap(Map<String, dynamic> map, String id) {
    return Transacao(
      id: id,
      tipo: TipoTransacao.values.firstWhere(
        (e) => e.toString().split('.').last == map['tipo'],
        orElse: () => TipoTransacao.despesa,
      ),
      valor: (map['valor'] ?? 0.0).toDouble(),
      data: DateTime.fromMillisecondsSinceEpoch(map['data'] ?? 0),
      descricao: map['descricao'] ?? '',
      categoriaId: map['categoriaId'] ?? '',
      contaId: map['contaId'] ?? '',
      recorrente: map['recorrente'] ?? false,
      criadoPor: map['criadoPor'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      contaDestinoId: map['contaDestinoId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo.toString().split('.').last,
      'valor': valor,
      'data': data.millisecondsSinceEpoch,
      'descricao': descricao,
      'categoriaId': categoriaId,
      'contaId': contaId,
      'recorrente': recorrente,
      'criadoPor': criadoPor,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (contaDestinoId != null) 'contaDestinoId': contaDestinoId,
    };
  }

  Transacao copyWith({
    String? id,
    TipoTransacao? tipo,
    double? valor,
    DateTime? data,
    String? descricao,
    String? categoriaId,
    String? contaId,
    bool? recorrente,
    String? criadoPor,
    DateTime? timestamp,
    String? contaDestinoId,
  }) {
    return Transacao(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      contaId: contaId ?? this.contaId,
      recorrente: recorrente ?? this.recorrente,
      criadoPor: criadoPor ?? this.criadoPor,
      timestamp: timestamp ?? this.timestamp,
      contaDestinoId: contaDestinoId ?? this.contaDestinoId,
    );
  }
}
