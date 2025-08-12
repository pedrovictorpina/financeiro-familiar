import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';
import '../../utils/formatters.dart';
import '../../utils/theme_extensions.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  DateTime _selectedMonth = DateTime.now();
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedCategoryId;
  String? _selectedAccountId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transacao> _getFilteredIncomes(List<Transacao> allTransactions) {
    return allTransactions.where((transacao) {
      if (transacao.tipo != TipoTransacao.receita) return false;
      if (transacao.data.year != _selectedMonth.year || transacao.data.month != _selectedMonth.month) return false;
      if (_selectedCategoryId != null && transacao.categoriaId != _selectedCategoryId) return false;
      if (_selectedAccountId != null && transacao.contaId != _selectedAccountId) return false;
      if (_searchText.isNotEmpty) {
        return transacao.descricao.toLowerCase().contains(_searchText.toLowerCase());
      }
      return true;
    }).toList();
  }

  List<Transacao> _getPaginatedIncomes(List<Transacao> filtered) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Receitas',
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
          final filteredIncomes = _getFilteredIncomes(financeProvider.transacoes);
          final paginated = _getPaginatedIncomes(filteredIncomes);
          final totalPages = (filteredIncomes.length / _itemsPerPage).ceil();
          final totalValue = filteredIncomes.fold(0.0, (sum, t) => sum + t.valor);

          return Column(
            children: [
              _buildMonthHeader(totalValue, filteredIncomes.length),
              Expanded(
                child: filteredIncomes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paginated.length,
                        itemBuilder: (context, index) {
                          final transacao = paginated[index];
                          return _buildIncomeCard(context, transacao, financeProvider);
                        },
                      ),
              ),
              if (totalPages > 1) _buildPagination(totalPages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(double totalValue, int transactionCount) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TransactionColors.getReceitaBackground(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$transactionCount receitas',
                  style: const TextStyle(
                    color: TransactionColors.receita,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TransactionColors.getReceitaBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: TransactionColors.receita,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de receitas',
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

  Widget _buildIncomeCard(BuildContext context, Transacao transacao, FinanceProvider financeProvider) {
    final categoria = financeProvider.categorias.firstWhere(
      (c) => c.id == transacao.categoriaId,
      orElse: () => Categoria(
        id: '',
        nome: 'Categoria não encontrada',
        tipo: TipoCategoria.receita,
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
                '+${Formatters.formatCurrency(transacao.valor)}',
                style: const TextStyle(
                  color: TransactionColors.receita,
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
            Icons.trending_up,
            size: 64,
            color: context.iconColorMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma receita encontrada',
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
        _currentPage = 0;
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Buscar receitas',
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
                          .where((c) => c.tipo == TipoCategoria.receita)
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
}