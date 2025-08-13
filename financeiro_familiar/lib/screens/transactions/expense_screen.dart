import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';
import '../../models/cartao.dart';
import '../../utils/formatters.dart';
import '../../utils/theme_extensions.dart';
import 'add_expense_screen.dart'; // Added for edit mode navigation

// Classe auxiliar para representar faturas de cartão como itens de despesa
class CardInvoiceItem {
  final String cardId;
  final String cardName;
  final double amount;
  final DateTime date;
  final Color cardColor;

  CardInvoiceItem({
    required this.cardId,
    required this.cardName,
    required this.amount,
    required this.date,
    required this.cardColor,
  });
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTime _selectedMonth = DateTime.now();
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTimeRange? _intervaloDatas;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CardInvoiceItem> _getCardInvoicesForMonth(List<Cartao> cartoes) {
    final invoices = <CardInvoiceItem>[];
    
    for (final cartao in cartoes) {
      final faturaValor = cartao.getFaturaMes(_selectedMonth.month, _selectedMonth.year);
      if (faturaValor > 0) {
        invoices.add(CardInvoiceItem(
          cardId: cartao.id,
          cardName: cartao.nome,
          amount: faturaValor,
          date: DateTime(_selectedMonth.year, _selectedMonth.month, cartao.vencimentoDia),
          cardColor: cartao.cor,
        ));
      }
    }
    
    return invoices;
  }

  List<Transacao> _getFilteredExpenses(List<Transacao> allTransactions) {
    return allTransactions.where((transacao) {
      // Filtrar apenas despesas
      if (transacao.tipo != TipoTransacao.despesa) return false;
      
      // Filtrar por mês selecionado
      if (transacao.data.year != _selectedMonth.year || 
          transacao.data.month != _selectedMonth.month) {
        return false;
      }
      
      // Filtrar por categoria se selecionada
      if (_selectedCategoryId != null && 
          transacao.categoriaId != _selectedCategoryId) {
        return false;
      }
      
      // Filtrar por conta se selecionada
      if (_selectedAccountId != null && 
          transacao.contaId != _selectedAccountId) {
        return false;
      }
      
      // Filtrar por texto de busca
      if (_searchText.isNotEmpty) {
        return transacao.descricao.toLowerCase().contains(_searchText.toLowerCase());
      }
      
      return true;
    }).toList();
  }

  List<Widget> _getAllExpenseItems(List<Transacao> filteredExpenses, List<CardInvoiceItem> cardInvoices, FinanceProvider financeProvider) {
    final items = <Widget>[];
    
    // Adicionar transações regulares
    for (final transacao in filteredExpenses) {
      items.add(_buildExpenseCard(context, transacao, financeProvider));
    }
    
    // Adicionar faturas de cartão (apenas se não há filtro de categoria ou conta)
    if (_selectedCategoryId == null && _selectedAccountId == null) {
      for (final invoice in cardInvoices) {
        // Filtrar por texto de busca se aplicável
        if (_searchText.isNotEmpty && 
            !invoice.cardName.toLowerCase().contains(_searchText.toLowerCase()) &&
            !'fatura'.toLowerCase().contains(_searchText.toLowerCase())) {
          continue;
        }
        items.add(_buildCardInvoiceCard(context, invoice));
      }
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Despesas',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final filteredExpenses = _getFilteredExpenses(financeProvider.transacoes);
          final cardInvoices = _getCardInvoicesForMonth(financeProvider.cartoes);
          final allItems = _getAllExpenseItems(filteredExpenses, cardInvoices, financeProvider);
          
          // Calcular totais
          final transactionsTotal = filteredExpenses.fold(0.0, (sum, t) => sum + t.valor);
          final invoicesTotal = (_selectedCategoryId == null && _selectedAccountId == null) 
              ? cardInvoices.fold(0.0, (sum, invoice) => sum + invoice.amount)
              : 0.0;
          final totalValue = transactionsTotal + invoicesTotal;
          final invoiceCount = (_selectedCategoryId == null && _selectedAccountId == null) 
              ? cardInvoices.length 
              : 0;
          
          // Paginação
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, allItems.length);
          final paginatedItems = allItems.sublist(startIndex, endIndex);
          final totalPages = (allItems.length / _itemsPerPage).ceil();

          return Column(
            children: [
              // Header com resumo do mês
              _buildMonthHeader(totalValue, filteredExpenses.length, invoiceCount),
              
              // Lista de despesas e faturas
              Expanded(
                child: allItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paginatedItems.length,
                        itemBuilder: (context, index) => paginatedItems[index],
                      ),
              ),
              
              // Paginação
              if (totalPages > 1) _buildPagination(totalPages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(double totalValue, int transactionCount, int invoiceCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _selectMonth(context),
                child: Row(
                  children: [
                    Text(
                      Formatters.formatMonthName(_selectedMonth),
                      style: TextStyle(
                        color: context.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.primaryText,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (transactionCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TransactionColors.getDespesaBackground(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$transactionCount despesas',
                        style: const TextStyle(
                          color: TransactionColors.despesa,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (invoiceCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$invoiceCount faturas',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TransactionColors.getDespesaBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: TransactionColors.despesa,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de despesas',
                    style: TextStyle(
                      color: context.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(totalValue),
                    style: TextStyle(
                      color: context.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInvoiceCard(BuildContext context, CardInvoiceItem invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            width: 4,
            color: invoice.cardColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: invoice.cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.credit_card,
              color: invoice.cardColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fatura ${invoice.cardName}',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cartão de Crédito',
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vencimento: ${Formatters.formatDate(invoice.date)}',
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${Formatters.formatCurrency(invoice.amount)}',
                style: TextStyle(
                  color: invoice.cardColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Fatura',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Transacao transacao, FinanceProvider financeProvider) {
    final categoria = financeProvider.categorias.firstWhere(
      (c) => c.id == transacao.categoriaId,
      orElse: () => Categoria(
        id: '',
        nome: 'Categoria não encontrada',
        tipo: TipoCategoria.despesa,
        cor: Colors.grey,
        icone: Icons.help_outline,
      ),
    );
    
    final conta = financeProvider.contas.firstWhere(
      (c) => c.id == transacao.contaId,
      orElse: () => Conta(
        id: '',
        nome: 'Conta não encontrada',
        tipo: TipoConta.banco,
        saldoAtual: 0,
        saldoPrevisto: 0,
        cor: Colors.grey,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoria.cor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              categoria.icone,
              color: categoria.cor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.descricao,
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categoria.nome,
                  style: TextStyle(
                    color: context.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${conta.nome} • ${Formatters.formatDate(transacao.data)}',
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${Formatters.formatCurrency(transacao.valor)}',
                style: const TextStyle(
                  color: TransactionColors.despesa,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (transacao.recorrente)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.infoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Recorrente',
                    style: TextStyle(
                      color: context.infoColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.mutedText),
            onSelected: (value) async {
              if (value == 'editar') {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(transacao: transacao),
                  ),
                );
              } else if (value == 'excluir') {
                final confirm = await _confirmarExclusao(transacao);
                if (confirm == true) {
                  final success = await financeProvider.deletarTransacao(transacao.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Despesa excluída com sucesso!' : (financeProvider.errorMessage ?? 'Erro ao excluir despesa')),
                        backgroundColor: success ? Colors.green : context.errorColor,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: const [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_down,
            size: 64,
            color: context.iconColorMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma despesa encontrada',
            style: TextStyle(
              fontSize: 18,
              color: context.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou selecionar outro mês',
            style: TextStyle(
              color: context.mutedText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Anterior'),
          ),
          Text(
            'Página ${_currentPage + 1} de $totalPages',
            style: TextStyle(
              color: context.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Próxima'),
          ),
        ],
      ),
    );
  }

  void _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _currentPage = 0; // Reset pagination
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Buscar despesas',
          style: TextStyle(color: context.primaryText),
        ),
        content: TextField(
          controller: _searchController,
          style: TextStyle(color: context.primaryText),
          decoration: InputDecoration(
            hintText: 'Digite para buscar...',
            hintStyle: TextStyle(color: context.secondaryText),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchText = '';
                _searchController.clear();
                _currentPage = 0;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchText = _searchController.text;
                _currentPage = 0;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Filtros',
              style: TextStyle(color: context.primaryText),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categoria',
                    style: TextStyle(color: context.primaryText),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _selectedCategoryId,
                    dropdownColor: context.dropdownColor,
                    style: TextStyle(color: context.primaryText),
                    decoration: InputDecoration(
                      hintText: 'Todas as categorias',
                      hintStyle: TextStyle(color: context.secondaryText),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas as categorias'),
                      ),
                      ...financeProvider.categorias
                          .where((c) => c.tipo == TipoCategoria.despesa)
                          .map((categoria) {
                        return DropdownMenuItem<String?>(
                          value: categoria.id,
                          child: Text(categoria.nome),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conta',
                    style: TextStyle(color: context.primaryText),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _selectedAccountId,
                    dropdownColor: context.dropdownColor,
                    style: TextStyle(color: context.primaryText),
                    decoration: InputDecoration(
                      hintText: 'Todas as contas',
                      hintStyle: TextStyle(color: context.secondaryText),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas as contas'),
                      ),
                      ...financeProvider.contas.map((conta) {
                        return DropdownMenuItem<String?>(
                          value: conta.id,
                          child: Text(conta.nome),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedAccountId = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _selectedAccountId = null;
                    _currentPage = 0;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Limpar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentPage = 0;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selecionarPeriodo() async {
    final agora = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(agora.year + 1),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: TransactionColors.despesa,
              secondary: TransactionColors.despesa,
              surface: theme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _intervaloDatas = picked);
    }
  }

  Future<bool?> _confirmarExclusao(Transacao transacao) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Excluir despesa', style: TextStyle(color: context.primaryText)),
        content: Text(
          'Deseja realmente excluir a despesa "${transacao.descricao}" no valor de -${Formatters.formatCurrency(transacao.valor)}?',
          style: TextStyle(color: context.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: context.primaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}