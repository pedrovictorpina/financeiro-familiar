import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';
import '../../models/transacao.dart';
import '../../models/meta.dart';
import '../../models/conta.dart';
import '../cards/cards_screen.dart';
import '../cards/card_details_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../accounts/accounts_screen.dart';
import '../transactions/income_screen.dart';
import '../transactions/expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isBalanceVisible = true;
  int _selectedYear = DateTime.now().year;
  
  String get selectedMonth {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[_selectedMonth.month - 1];
  }
  
  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Consumer<FinanceProvider>(
          builder: (context, financeProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWeb ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isWeb),
                  const SizedBox(height: 24),
                  _buildBalanceCard(context, financeProvider, isWeb),
                  const SizedBox(height: 24),
                  _buildIncomeExpenseCards(context, financeProvider, isWeb),
                  const SizedBox(height: 24),
                  // Só mostra a seção de progresso se não estiver 100% completa
                  Consumer<FinanceProvider>(
                    builder: (context, financeProvider, child) {
                      final hasTransactions = financeProvider.transacoes.isNotEmpty;
                      final hasCategories = financeProvider.categorias.isNotEmpty;
                      final hasAccounts = financeProvider.contas.isNotEmpty;
                      final hasCards = financeProvider.cartoes.isNotEmpty;
                      final hasBudget = financeProvider.orcamentos.isNotEmpty;
                      
                      int completedSteps = 1; // Informações iniciais sempre completas
                       if (hasAccounts) completedSteps++;
                       if (hasCards) completedSteps++;
                       if (hasCategories) completedSteps++;
                       // Finaliza quando tem transações (guia interativo concluído)
                       if (hasTransactions) completedSteps = 4;
                      
                      // Só mostra se não estiver 100% completo
                      if (completedSteps < 4) {
                        return Column(
                          children: [
                            _buildProgressSection(context, isWeb),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              _buildAccountsSection(context, isWeb),
                  const SizedBox(height: 24),
                  _buildCreditCardsSection(context, isWeb),
                  const SizedBox(height: 24),
                  _buildExpensesByCategorySection(context, isWeb),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWeb) {
    return Row(
      children: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return CircleAvatar(
              radius: isWeb ? 24 : 20,
              backgroundColor: Colors.grey[700],
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: isWeb ? 24 : 20,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _showMonthPicker,
            child: Row(
              children: [
Text(
                  selectedMonth,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 24 : 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, FinanceProvider financeProvider, bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo em contas',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isWeb ? 16 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _isBalanceVisible 
                    ? Formatters.formatCurrency(financeProvider.saldoTotal)
                    : '••••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 32 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCards(BuildContext context, FinanceProvider financeProvider, bool isWeb) {
    return Row(
      children: [
        Expanded(
          child: _buildIncomeExpenseCard(
            context,
            'Receitas',
            Formatters.formatCurrency(financeProvider.receitasMes),
            Icons.arrow_upward,
            Colors.green,
            isWeb,
            () => _navigateToIncomes(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIncomeExpenseCard(
            context,
            'Despesas',
            Formatters.formatCurrency(financeProvider.despesasMes),
            Icons.arrow_downward,
            Colors.red,
            isWeb,
            () => _navigateToExpenses(context),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseCard(BuildContext context, String title, String value, IconData icon, Color color, bool isWeb, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isWeb ? 20 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: isWeb ? 14 : 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWeb ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, bool isWeb) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final hasTransactions = financeProvider.transacoes.isNotEmpty;
        final hasCategories = financeProvider.categorias.isNotEmpty;
        final hasAccounts = financeProvider.contas.isNotEmpty;
        final hasCards = financeProvider.cartoes.isNotEmpty;
        final hasBudget = financeProvider.orcamentos.isNotEmpty;
        // Removido seção de metas temporariamente
        
        int completedSteps = 1; // Informações iniciais sempre completas
         if (hasAccounts) completedSteps++;
         if (hasCards) completedSteps++;
         if (hasCategories) completedSteps++;
         // Finaliza quando tem transações (guia interativo concluído)
         if (hasTransactions) completedSteps = 4;
        
        return Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Primeiros passos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${((completedSteps / 4) * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: completedSteps / 4,
                      backgroundColor: Colors.grey[700],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProgressItem('Preencha as informações iniciais', true, isWeb),
              const SizedBox(height: 12),
              _buildProgressItem('Cadastre uma conta bancária', hasAccounts, isWeb),
              const SizedBox(height: 12),
              _buildProgressItem('Cadastre um cartão de crédito', hasCards, isWeb),
              const SizedBox(height: 12),
              _buildProgressItem('Configure suas categorias', hasCategories, isWeb),
              const SizedBox(height: 20),
              // Botão para iniciar o guia interativo
              if (completedSteps < 4)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb ? 16 : 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: Text(
                      'Iniciar Guia Interativo',
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String title, bool completed, bool isWeb) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: completed ? Colors.green : Colors.transparent,
            border: completed ? null : Border.all(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: completed
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: completed ? Colors.grey[400] : Colors.white,
              fontSize: isWeb ? 14 : 13,
              decoration: completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (completed)
          const Text(
            '🎉',
            style: TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildProgressStep(String title, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF8B5CF6) : Colors.transparent,
              border: completed ? null : Border.all(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: completed
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed ? Colors.grey[400] : Colors.white,
                fontSize: 14,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, bool isWeb) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        return Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AccountsScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (financeProvider.contas.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma conta cadastrada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 16 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione sua primeira conta para começar',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isWeb ? 14 : 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...financeProvider.contas.take(3).map((conta) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: conta.cor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getContaIcon(conta.tipo),
                          color: conta.cor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conta.nome,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWeb ? 16 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(conta.saldoAtual),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: isWeb ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AccountsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ADICIONAR UMA CONTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 14 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(financeProvider.saldoTotal),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getContaIcon(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.banco:
        return Icons.account_balance;
      case TipoConta.carteira:
        return Icons.account_balance_wallet;
      case TipoConta.poupanca:
        return Icons.savings;
      case TipoConta.investimento:
        return Icons.trending_up;
    }
  }

  Widget _buildCreditCardsSection(BuildContext context, bool isWeb) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        return Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cartões de crédito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              if (financeProvider.cartoes.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.credit_card,
                        color: Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ops! Você ainda não tem nenhum cartão\nde crédito cadastrado.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 16 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Melhore seu controle financeiro agora!',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isWeb ? 14 : 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CardsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ADICIONAR NOVO CARTÃO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 14 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...financeProvider.cartoes.take(3).map((cartao) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CardDetailsScreen(cartao: cartao),
                          ),
                        );
                      },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Color(0xFF8B5CF6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartao.nome,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isWeb ? 16 : 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Fatura: ${Formatters.formatCurrency(cartao.faturaAtual)}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: isWeb ? 14 : 12,
                                      ),
                                    ),
                                    Text(
                                      'Limite: ${Formatters.formatCurrency(cartao.limite)}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: isWeb ? 12 : 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${((cartao.faturaAtual / cartao.limite) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: cartao.faturaAtual > cartao.limite * 0.8 ? Colors.red : Colors.green,
                                      fontSize: isWeb ? 14 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (cartao.faturaAtual / cartao.limite).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[700],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cartao.faturaAtual > cartao.limite * 0.8 ? Colors.red : Colors.green,
                            ),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CardsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ADICIONAR NOVO CARTÃO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 14 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesByCategorySection(BuildContext context, bool isWeb) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final gastosPorCategoria = financeProvider.getGastosPorCategoria();
        
        return Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gastos por categoria',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              if (gastosPorCategoria.isEmpty) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum gasto registrado',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: gastosPorCategoria.length,
                            itemBuilder: (context, index) {
                              final categoriaNome = gastosPorCategoria.keys.elementAt(index);
                              final valor = gastosPorCategoria[categoriaNome]!;
                              final total = gastosPorCategoria.values.fold(0.0, (sum, v) => sum + v);
                              final percentage = (valor / total * 100);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(index),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        categoriaNome,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isWeb ? 14 : 12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: isWeb ? 12 : 11,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Formatters.formatCurrency(valor),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isWeb ? 14 : 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
      const Color(0xFF84CC16),
    ];
    return colors[index % colors.length];
  }

  void _navigateToIncomes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IncomeScreen(),
      ),
    );
  }

  void _navigateToExpenses(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExpenseScreen(),
      ),
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              _selectedYear--;
                            });
                          },
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        Text(
                          _selectedYear.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              _selectedYear++;
                            });
                          },
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildMonthButton('JAN.', 1, setDialogState),
                        _buildMonthButton('FEV.', 2, setDialogState),
                        _buildMonthButton('MAR.', 3, setDialogState),
                        _buildMonthButton('ABR.', 4, setDialogState),
                        _buildMonthButton('MAI.', 5, setDialogState),
                        _buildMonthButton('JUN.', 6, setDialogState),
                        _buildMonthButton('JUL.', 7, setDialogState),
                        _buildMonthButton('AGO.', 8, setDialogState),
                        _buildMonthButton('SET.', 9, setDialogState),
                        _buildMonthButton('OUT.', 10, setDialogState),
                        _buildMonthButton('NOV.', 11, setDialogState),
                        _buildMonthButton('DEZ.', 12, setDialogState),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime.now();
                                _selectedYear = DateTime.now().year;
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'MÊS ATUAL',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthButton(String month, int monthNumber, StateSetter setDialogState) {
    final isSelected = _selectedMonth.month == monthNumber && _selectedMonth.year == _selectedYear;
    
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          // Não atualiza o estado principal ainda, apenas o estado do dialog
        });
        setState(() {
          _selectedMonth = DateTime(_selectedYear, monthNumber);
        });
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            month,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}