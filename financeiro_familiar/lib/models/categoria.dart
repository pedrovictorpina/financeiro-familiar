import 'package:flutter/material.dart';

enum TipoCategoria { receita, despesa }

class Categoria {
  final String id;
  final String nome;
  final TipoCategoria tipo;
  final Color cor;
  final IconData icone;

  Categoria({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cor,
    required this.icone,
  });

  factory Categoria.fromMap(Map<String, dynamic> map, String id) {
    return Categoria(
      id: id,
      nome: map['nome'] ?? '',
      tipo: TipoCategoria.values.firstWhere(
        (e) => e.toString().split('.').last == map['tipo'],
        orElse: () => TipoCategoria.despesa,
      ),
      cor: Color(map['cor'] ?? 0xFF2196F3),
      icone: IconData(map['icone'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo.toString().split('.').last,
      'cor': cor.value,
      'icone': icone.codePoint,
    };
  }

  Categoria copyWith({
    String? id,
    String? nome,
    TipoCategoria? tipo,
    Color? cor,
    IconData? icone,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
    );
  }
}