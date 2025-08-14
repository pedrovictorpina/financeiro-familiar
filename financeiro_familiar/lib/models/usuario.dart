class Usuario {
  final String uid;
  final String nome;
  final String email;
  final List<String> orcamentos;
  final DateTime dataCriacao;
  final int reminderDays; // 1 a 5 dias antes do vencimento

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.orcamentos,
    required this.dataCriacao,
    this.reminderDays = 3,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      orcamentos: List<String>.from(map['orcamentos'] ?? []),
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] ?? 0),
      reminderDays: (map['reminderDays'] ?? 3) is int
          ? (map['reminderDays'] ?? 3)
          : int.tryParse(map['reminderDays']?.toString() ?? '3') ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'orcamentos': orcamentos,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
      'reminderDays': reminderDays,
    };
  }

  Usuario copyWith({
    String? uid,
    String? nome,
    String? email,
    List<String>? orcamentos,
    DateTime? dataCriacao,
    int? reminderDays,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      orcamentos: orcamentos ?? this.orcamentos,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}
