import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';
import '../../models/transacao.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${authProvider.userData?.nome.split(' ').first ?? 'Usuário'}!',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  Formatters.formatMonthName(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<FinanceProvider>(
            builder: (context, financeProvider, child) {
              if (financeProvider.orcamentos.length > 1) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.account_balance_wallet),
                  onSelected: (orcamentoId) {
                    financeProvider.selecionarOrcamento(orcamentoId);
                  },
                  itemBuilder: (context) {
                    return financeProvider.orcamentos.map((orcamento) {
                      return PopupMenuItem<String>(
                        value: orcamento.id,
                        child: Row(
                          children: [
                            Icon(
                              financeProvider.orcamentoAtual?.id == orcamento.id
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(orcamento.nome)),
                          ],
                        ),
                      );
                    }).toList();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          if (financeProvider.orcamentoAtual == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum orçamento encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crie seu primeiro orçamento para começar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // TODO: Implementar refresh dos dados
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cards de resumo
                  _buildSummaryCards(context, financeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Gráfico de gastos por categoria
                  _buildExpenseChart(context, financeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Contas principais
                  _buildAccountsSection(context, financeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Metas em progresso
                  _buildGoalsSection(context, financeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Transações recentes
                  _buildRecentTransactions(context, financeProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, FinanceProvider financeProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Saldo Total',
                value: Formatters.formatCurrency(financeProvider.saldoTotal),
                icon: Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Saldo do Mês',
                value: Formatters.formatCurrencyWithSign(financeProvider.saldoMes),
                icon: financeProvider.saldoMes >= 0 ? Icons.trending_up : Icons.trending_down,
                color: financeProvider.saldoMes >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Receitas',
                value: Formatters.formatCurrency(financeProvider.receitasMes),
                icon: Icons.arrow_upward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Despesas',
                value: Formatters.formatCurrency(financeProvider.despesasMes),
                icon: Icons.arrow_downward,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context, FinanceProvider financeProvider) {
    final gastosPorCategoria = financeProvider.getGastosPorCategoria();
    
    if (gastosPorCategoria.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline),
                  const SizedBox(width: 8),
                  Text(
                    'Gastos por Categoria',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma despesa registrada este mês',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final sections = gastosPorCategoria.entries.take(5).map((entry) {
      final index = gastosPorCategoria.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '${Formatters.formatPercentage((entry.value / financeProvider.despesasMes) * 100)}',
        color: AppConstants.getColorByIndex(index),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline),
                const SizedBox(width: 8),
                Text(
                  'Gastos por Categoria',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...gastosPorCategoria.entries.take(5).map((entry) {
              final index = gastosPorCategoria.keys.toList().indexOf(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppConstants.getColorByIndex(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(
                      Formatters.formatCurrency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, FinanceProvider financeProvider) {
    if (financeProvider.contas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance),
                const SizedBox(width: 8),
                Text(
                  'Contas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de contas
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...financeProvider.contas.take(3).map((conta) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: conta.cor.withOpacity(0.2),
                  child: Icon(
                    AppConstants.getContaIcon(conta.tipo.toString().split('.').last),
                    color: conta.cor,
                  ),
                ),
                title: Text(conta.nome),
                subtitle: Text(conta.tipoNome),
                trailing: Text(
                  Formatters.formatCurrency(conta.saldoAtual),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, FinanceProvider financeProvider) {
    if (financeProvider.metas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  'Metas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de metas
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...financeProvider.metas.take(3).map((meta) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(meta.nome)),
                        Text(
                          '${Formatters.formatPercentage(meta.percentualConcluido)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: meta.percentualConcluido / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.formatCurrency(meta.valorAtual)} de ${Formatters.formatCurrency(meta.valorMeta)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, FinanceProvider financeProvider) {
    final transacoesRecentes = financeProvider.transacoes.take(5).toList();
    
    if (transacoesRecentes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 8),
                Text(
                  'Transações Recentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de transações
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...transacoesRecentes.map((transacao) {
              Color cor;
              IconData icone;
              
              switch (transacao.tipo) {
                case TipoTransacao.receita:
                  cor = Colors.green;
                  icone = Icons.arrow_upward;
                  break;
                case TipoTransacao.despesa:
                  cor = Colors.red;
                  icone = Icons.arrow_downward;
                  break;
                case TipoTransacao.transferencia:
                  cor = Colors.blue;
                  icone = Icons.swap_horiz;
                  break;
              }
              
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: cor.withOpacity(0.2),
                  child: Icon(icone, color: cor),
                ),
                title: Text(transacao.descricao),
                subtitle: Text(Formatters.formatDate(transacao.data)),
                trailing: Text(
                  transacao.tipo == TipoTransacao.receita
                      ? '+${Formatters.formatCurrency(transacao.valor)}'
                      : '-${Formatters.formatCurrency(transacao.valor)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}