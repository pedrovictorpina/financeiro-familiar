import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';
import '../../models/planejamento.dart';
import '../../models/categoria.dart';
import 'add_budget_screen.dart';
import 'add_goal_screen.dart';
import 'add_goal_value_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _mesSelecionado = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carregar planejamentos do mês selecionado após o orçamento ser carregado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );

      // Aguardar o orçamento ser carregado antes de carregar planejamentos
      if (financeProvider.orcamentoAtual != null) {
        financeProvider.carregarPlanejamentosMes(_mesSelecionado);
      } else {
        // Aguardar um pouco e tentar novamente
        Future.delayed(Duration(milliseconds: 500), () {
          if (financeProvider.orcamentoAtual != null) {
            financeProvider.carregarPlanejamentosMes(_mesSelecionado);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejamento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orçamento', icon: Icon(Icons.pie_chart_outline)),
            Tab(text: 'Metas', icon: Icon(Icons.flag_outlined)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selecionarMes,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrcamentoTab(), _buildMetasTab()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-planning',
        onPressed: () {
          if (_tabController.index == 0) {
            _adicionarPlanejamento();
          } else {
            _adicionarMeta();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrcamentoTab() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final planejamentos = financeProvider.planejamentos.where((p) {
          final partes = p.mes.split('-');
          if (partes.length >= 2) {
            final ano = int.tryParse(partes[0]) ?? 0;
            final mes = int.tryParse(partes[1]) ?? 0;
            return ano == _mesSelecionado.year && mes == _mesSelecionado.month;
          }
          return false;
        }).toList();

        if (planejamentos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum orçamento definido',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Defina limites para suas categorias',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _adicionarPlanejamento,
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Orçamento'),
                ),
              ],
            ),
          );
        }

        final totalLimite = planejamentos.fold<double>(
          0,
          (sum, p) => sum + p.limite,
        );
        final totalGasto = planejamentos.fold<double>(
          0,
          (sum, p) => sum + p.gastoAtual,
        );
        final percentualGeral = totalLimite > 0
            ? (totalGasto / totalLimite) * 100
            : 0;

        return Column(
          children: [
            // Resumo geral
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatMonthName(_mesSelecionado),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orçamento Total',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Formatters.formatCurrency(totalLimite),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gasto Atual',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Formatters.formatCurrency(totalGasto),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getCorPorcentagem(
                                      percentualGeral.toDouble(),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restante',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Formatters.formatCurrency(
                                totalLimite - totalGasto,
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: totalLimite - totalGasto >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: percentualGeral / 100,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCorPorcentagem(percentualGeral.toDouble()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${Formatters.formatPercentage(percentualGeral.toDouble())} do orçamento utilizado',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Lista de planejamentos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: planejamentos.length,
                itemBuilder: (context, index) {
                  final planejamento = planejamentos[index];
                  return _buildPlanejamentoCard(
                    context,
                    planejamento,
                    financeProvider,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetasTab() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        if (financeProvider.metas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma meta definida',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie metas para seus objetivos financeiros',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _adicionarMeta,
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Meta'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: financeProvider.metas.length,
          itemBuilder: (context, index) {
            final meta = financeProvider.metas[index];
            return _buildMetaCard(context, meta, financeProvider);
          },
        );
      },
    );
  }

  Widget _buildPlanejamentoCard(
    BuildContext context,
    Planejamento planejamento,
    FinanceProvider financeProvider,
  ) {
    final categoria = financeProvider.categorias.firstWhere(
      (c) => c.id == planejamento.categoriaId,
      orElse: () => Categoria(
        id: '',
        nome: 'Categoria não encontrada',
        tipo: TipoCategoria.despesa,
        cor: Colors.grey,
        icone: Icons.help_outline,
      ),
    );

    final cor = _getCorPorcentagem(planejamento.percentualGasto);
    final iconeStatus = _getIconeStatus(planejamento.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoria.cor.withAlpha(51),
                  child: Icon(categoria.icone, color: categoria.cor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getTextoStatus(planejamento.status),
                        style: TextStyle(
                          color: cor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(iconeStatus, color: cor, size: 20),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarPlanejamento(planejamento);
                    } else if (value == 'excluir') {
                      _excluirPlanejamento(planejamento.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Limite',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(planejamento.limite),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gasto',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(planejamento.gastoAtual),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restante',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(planejamento.saldoRestante),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: planejamento.saldoRestante >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: planejamento.percentualGasto / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(cor),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.formatPercentage(planejamento.percentualGasto)} utilizado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(
    BuildContext context,
    meta,
    FinanceProvider financeProvider,
  ) {
    final cor = meta.isCompleta
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
    final icone = meta.isCompleta ? Icons.check_circle : Icons.flag_outlined;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(
                    int.parse(meta.cor!.replaceFirst('#', '0xFF')),
                  ).withAlpha(51),
                  child: Icon(
                    meta.icone != null
                        ? IconData(
                            int.parse(meta.icone!),
                            fontFamily: 'MaterialIcons',
                          )
                        : Icons.flag_outlined,
                    color: Color(
                      int.parse(meta.cor!.replaceFirst('#', '0xFF')),
                    ),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (meta.descricao.isNotEmpty)
                        Text(
                          meta.descricao,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Icon(icone, color: cor, size: 20),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'adicionar',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Adicionar Valor'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarMeta(meta);
                    } else if (value == 'adicionar') {
                      _adicionarValorMeta(meta);
                    } else if (value == 'excluir') {
                      _excluirMeta(meta.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(meta.valorMeta),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atual',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(meta.valorAtual),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restante',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatCurrency(meta.valorRestante),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: meta.valorRestante <= 0
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: meta.percentualConcluido / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(cor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${Formatters.formatPercentage(meta.percentualConcluido)} concluído',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                if (meta.prazo != null)
                  Text(
                    meta.isPrazoVencido
                        ? 'Prazo vencido'
                        : '${meta.diasRestantes} dias restantes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: meta.isPrazoVencido ? Colors.red : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCorPorcentagem(double percentual) {
    if (percentual <= 50) return Colors.green;
    if (percentual <= 80) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconeStatus(StatusPlanejamento status) {
    switch (status) {
      case StatusPlanejamento.normal:
        return Icons.check_circle;
      case StatusPlanejamento.atencao:
        return Icons.warning;
      case StatusPlanejamento.excedido:
        return Icons.error;
    }
  }

  String _getTextoStatus(StatusPlanejamento status) {
    switch (status) {
      case StatusPlanejamento.normal:
        return 'Dentro do limite';
      case StatusPlanejamento.atencao:
        return 'Próximo do limite';
      case StatusPlanejamento.excedido:
        return 'Limite excedido';
    }
  }

  void _selecionarMes() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _mesSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() {
        _mesSelecionado = DateTime(data.year, data.month);
      });

      // Carregar planejamentos do novo mês selecionado
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      financeProvider.carregarPlanejamentosMes(_mesSelecionado);
    }
  }

  void _adicionarPlanejamento() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(mesSelecionado: _mesSelecionado),
      ),
    );
  }

  void _editarPlanejamento(Planejamento planejamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(
          mesSelecionado: _mesSelecionado,
          planejamento: planejamento,
        ),
      ),
    );
  }

  void _excluirPlanejamento(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Planejamento'),
        content: const Text(
          'Tem certeza que deseja excluir este planejamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final financeProvider = Provider.of<FinanceProvider>(
                context,
                listen: false,
              );
              final success = await financeProvider.excluirPlanejamento(id);
              if (!mounted) return;
              Navigator.of(context).pop();
              if (success) {
                financeProvider.carregarPlanejamentosMes(_mesSelecionado);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Planejamento excluído com sucesso'),
                  ),
                );
              } else {
                final msg =
                    financeProvider.errorMessage ??
                    'Erro ao excluir planejamento';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _adicionarMeta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
  }

  void _editarMeta(meta) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalScreen(meta: meta)),
    );
  }

  void _adicionarValorMeta(meta) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGoalValueScreen(meta: meta)),
    );
  }

  void _excluirMeta(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: const Text('Tem certeza que deseja excluir esta meta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final financeProvider = Provider.of<FinanceProvider>(
                context,
                listen: false,
              );
              final success = await financeProvider.excluirMeta(id);
              if (!mounted) return;
              Navigator.of(context).pop();
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meta excluída com sucesso')),
                );
              } else {
                final msg =
                    financeProvider.errorMessage ?? 'Erro ao excluir meta';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
