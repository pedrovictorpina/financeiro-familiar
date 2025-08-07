class Cartao {
  final String id;
  final String nome;
  final double limite;
  final double faturaAtual;
  final int fechamentoDia;
  final int vencimentoDia;
  final String? bandeira;
  final String? cor;

  Cartao({
    required this.id,
    required this.nome,
    required this.limite,
    required this.faturaAtual,
    required this.fechamentoDia,
    required this.vencimentoDia,
    this.bandeira,
    this.cor,
  });

  factory Cartao.fromMap(Map<String, dynamic> map, String id) {
    return Cartao(
      id: id,
      nome: map['nome'] ?? '',
      limite: (map['limite'] ?? 0.0).toDouble(),
      faturaAtual: (map['faturaAtual'] ?? 0.0).toDouble(),
      fechamentoDia: map['fechamentoDia'] ?? 1,
      vencimentoDia: map['vencimentoDia'] ?? 10,
      bandeira: map['bandeira'],
      cor: map['cor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'limite': limite,
      'faturaAtual': faturaAtual,
      'fechamentoDia': fechamentoDia,
      'vencimentoDia': vencimentoDia,
      if (bandeira != null) 'bandeira': bandeira,
      if (cor != null) 'cor': cor,
    };
  }

  Cartao copyWith({
    String? id,
    String? nome,
    double? limite,
    double? faturaAtual,
    int? fechamentoDia,
    int? vencimentoDia,
    String? bandeira,
    String? cor,
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
    );
  }

  double get limiteDisponivel => limite - faturaAtual;
  
  double get percentualUtilizado => limite > 0 ? (faturaAtual / limite) * 100 : 0;

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
}