class Usuario {
  final String uid;
  final String nome;
  final String email;
  final List<String> orcamentos;
  final DateTime dataCriacao;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.orcamentos,
    required this.dataCriacao,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      orcamentos: List<String>.from(map['orcamentos'] ?? []),
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'orcamentos': orcamentos,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
    };
  }

  Usuario copyWith({
    String? uid,
    String? nome,
    String? email,
    List<String>? orcamentos,
    DateTime? dataCriacao,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      orcamentos: orcamentos ?? this.orcamentos,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}