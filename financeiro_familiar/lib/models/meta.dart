class Meta {
  final String id;
  final String nome;
  final double valorMeta;
  final double valorAtual;
  final DateTime prazo;
  final String? descricao;
  final String? icone;
  final String? cor;

  Meta({
    required this.id,
    required this.nome,
    required this.valorMeta,
    required this.valorAtual,
    required this.prazo,
    this.descricao,
    this.icone,
    this.cor,
  });

  factory Meta.fromMap(Map<String, dynamic> map, String id) {
    return Meta(
      id: id,
      nome: map['nome'] ?? '',
      valorMeta: (map['valorMeta'] ?? 0.0).toDouble(),
      valorAtual: (map['valorAtual'] ?? 0.0).toDouble(),
      prazo: DateTime.fromMillisecondsSinceEpoch(map['prazo'] ?? 0),
      descricao: map['descricao'],
      icone: map['icone'],
      cor: map['cor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'valorMeta': valorMeta,
      'valorAtual': valorAtual,
      'prazo': prazo.millisecondsSinceEpoch,
      if (descricao != null) 'descricao': descricao,
      if (icone != null) 'icone': icone,
      if (cor != null) 'cor': cor,
    };
  }

  Meta copyWith({
    String? id,
    String? nome,
    double? valorMeta,
    double? valorAtual,
    DateTime? prazo,
    String? descricao,
    String? icone,
    String? cor,
  }) {
    return Meta(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorMeta: valorMeta ?? this.valorMeta,
      valorAtual: valorAtual ?? this.valorAtual,
      prazo: prazo ?? this.prazo,
      descricao: descricao ?? this.descricao,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
    );
  }

  double get percentualConcluido {
    if (valorMeta <= 0) return 0;
    return (valorAtual / valorMeta) * 100;
  }

  double get valorRestante => valorMeta - valorAtual;

  bool get isCompleta => valorAtual >= valorMeta;

  int get diasRestantes {
    final now = DateTime.now();
    return prazo.difference(now).inDays;
  }

  bool get isPrazoVencido => DateTime.now().isAfter(prazo);

  double get valorMensalNecessario {
    if (isPrazoVencido || diasRestantes <= 0) return valorRestante;
    final mesesRestantes = diasRestantes / 30;
    return mesesRestantes > 0 ? valorRestante / mesesRestantes : valorRestante;
  }
}
