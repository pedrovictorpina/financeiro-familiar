enum TipoCard {
  saldoGeral,
  contasResumo,
  objetivos,
  despesasPorCategoria,
  graficoPizza,
  transacoesRecentes,
  metasProgresso,
  cartoesCredito,
  planejamentoMensal,
}

class ConfigDashboard {
  final String id;
  final TipoCard cardId;
  final bool ativo;
  final int ordem;

  ConfigDashboard({
    required this.id,
    required this.cardId,
    required this.ativo,
    this.ordem = 0,
  });

  factory ConfigDashboard.fromMap(Map<String, dynamic> map, String id) {
    return ConfigDashboard(
      id: id,
      cardId: TipoCard.values.firstWhere(
        (e) => e.toString().split('.').last == map['cardId'],
        orElse: () => TipoCard.saldoGeral,
      ),
      ativo: map['ativo'] ?? true,
      ordem: map['ordem'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId.toString().split('.').last,
      'ativo': ativo,
      'ordem': ordem,
    };
  }

  ConfigDashboard copyWith({
    String? id,
    TipoCard? cardId,
    bool? ativo,
    int? ordem,
  }) {
    return ConfigDashboard(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      ativo: ativo ?? this.ativo,
      ordem: ordem ?? this.ordem,
    );
  }

  String get titulo {
    switch (cardId) {
      case TipoCard.saldoGeral:
        return 'Saldo Geral';
      case TipoCard.contasResumo:
        return 'Resumo das Contas';
      case TipoCard.objetivos:
        return 'Objetivos';
      case TipoCard.despesasPorCategoria:
        return 'Despesas por Categoria';
      case TipoCard.graficoPizza:
        return 'Gráfico de Gastos';
      case TipoCard.transacoesRecentes:
        return 'Transações Recentes';
      case TipoCard.metasProgresso:
        return 'Progresso das Metas';
      case TipoCard.cartoesCredito:
        return 'Cartões de Crédito';
      case TipoCard.planejamentoMensal:
        return 'Planejamento Mensal';
    }
  }

  String get descricao {
    switch (cardId) {
      case TipoCard.saldoGeral:
        return 'Visão geral do saldo total';
      case TipoCard.contasResumo:
        return 'Resumo de todas as contas';
      case TipoCard.objetivos:
        return 'Acompanhamento dos objetivos';
      case TipoCard.despesasPorCategoria:
        return 'Gastos organizados por categoria';
      case TipoCard.graficoPizza:
        return 'Gráfico visual dos gastos';
      case TipoCard.transacoesRecentes:
        return 'Últimas transações realizadas';
      case TipoCard.metasProgresso:
        return 'Progresso das metas financeiras';
      case TipoCard.cartoesCredito:
        return 'Status dos cartões de crédito';
      case TipoCard.planejamentoMensal:
        return 'Acompanhamento do orçamento mensal';
    }
  }
}
