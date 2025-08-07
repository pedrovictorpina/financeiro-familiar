class Orcamento {
  final String id;
  final String nome;
  final String criadorUid;
  final List<String> usuariosVinculados;
  final String mesAtual;
  final DateTime dataCriacao;

  Orcamento({
    required this.id,
    required this.nome,
    required this.criadorUid,
    required this.usuariosVinculados,
    required this.mesAtual,
    required this.dataCriacao,
  });

  factory Orcamento.fromMap(Map<String, dynamic> map, String id) {
    return Orcamento(
      id: id,
      nome: map['nome'] ?? '',
      criadorUid: map['criadorUid'] ?? '',
      usuariosVinculados: List<String>.from(map['usuariosVinculados'] ?? []),
      mesAtual: map['mesAtual'] ?? '',
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'criadorUid': criadorUid,
      'usuariosVinculados': usuariosVinculados,
      'mesAtual': mesAtual,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
    };
  }

  Orcamento copyWith({
    String? id,
    String? nome,
    String? criadorUid,
    List<String>? usuariosVinculados,
    String? mesAtual,
    DateTime? dataCriacao,
  }) {
    return Orcamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadorUid: criadorUid ?? this.criadorUid,
      usuariosVinculados: usuariosVinculados ?? this.usuariosVinculados,
      mesAtual: mesAtual ?? this.mesAtual,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  bool isUserAuthorized(String uid) {
    return criadorUid == uid || usuariosVinculados.contains(uid);
  }
}