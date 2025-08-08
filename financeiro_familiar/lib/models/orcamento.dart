class Orcamento {
  final String id;
  final String nome;
  final String criadorUid;
  final List<String> usuariosVinculados;
  final String mesAtual;
  final DateTime dataCriacao;
  double valorLimite;

  Orcamento({
    required this.id,
    required this.nome,
    required this.criadorUid,
    required this.usuariosVinculados,
    required this.mesAtual,
    required this.dataCriacao,
    this.valorLimite = 0.0,
  });

  factory Orcamento.fromMap(Map<String, dynamic> map, String id) {
    return Orcamento(
      id: id,
      nome: map['nome'] ?? '',
      criadorUid: map['criadorUid'] ?? '',
      usuariosVinculados: List<String>.from(map['usuariosVinculados'] ?? []),
      mesAtual: map['mesAtual'] ?? '',
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] ?? 0),
      valorLimite: (map['valorLimite'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'criadorUid': criadorUid,
      'usuariosVinculados': usuariosVinculados,
      'mesAtual': mesAtual,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
      'valorLimite': valorLimite,
    };
  }

  Orcamento copyWith({
    String? id,
    String? nome,
    String? criadorUid,
    List<String>? usuariosVinculados,
    String? mesAtual,
    DateTime? dataCriacao,
    double? valorLimite,
  }) {
    return Orcamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadorUid: criadorUid ?? this.criadorUid,
      usuariosVinculados: usuariosVinculados ?? this.usuariosVinculados,
      mesAtual: mesAtual ?? this.mesAtual,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      valorLimite: valorLimite ?? this.valorLimite,
    );
  }

  bool isUserAuthorized(String uid) {
    return criadorUid == uid || usuariosVinculados.contains(uid);
  }
}