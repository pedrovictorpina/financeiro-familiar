import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Transacao> _getPaginatedExpenses(List<Transacao> filteredExpenses) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredExpenses.length);
    return filteredExpenses.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Despesas',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          final paginatedExpenses = _getPaginatedExpenses(filteredExpenses);
          final totalPages = (filteredExpenses.length / _itemsPerPage).ceil();
          final totalValue = filteredExpenses.fold(0.0, (sum, t) => sum + t.valor);

          return Column(
            children: [
              // Header com resumo do mês
              _buildMonthHeader(totalValue, filteredExpenses.length),
              
              // Lista de despesas
              Expanded(
                child: filteredExpenses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paginatedExpenses.length,
                        itemBuilder: (context, index) {
                          final transacao = paginatedExpenses[index];
                          return _buildExpenseCard(context, transacao, financeProvider);
                        },
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

  Widget _buildMonthHeader(double totalValue, int transactionCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$transactionCount despesas',
                  style: const TextStyle(
                    color: Colors.red,
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
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.red,
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
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(totalValue),
                    style: const TextStyle(
                      color: Colors.white,
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
        color: const Color(0xFF2A2A2A),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categoria.nome,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${conta.nome} • ${Formatters.formatDate(transacao.data)}',
                  style: TextStyle(
                    color: Colors.grey[500],
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
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (transacao.recorrente)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Recorrente',
                    style: TextStyle(
                      color: Colors.blue,
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
            Icons.trending_down,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma despesa encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou selecionar outro mês',
            style: TextStyle(
              color: Colors.grey[500],
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
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Anterior'),
          ),
          Text(
            'Página ${_currentPage + 1} de $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
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
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Buscar despesas',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite para buscar...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
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
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Filtros',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoria',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _selectedCategoryId,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Todas as categorias',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
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
                  const Text(
                    'Conta',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _selectedAccountId,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Todas as contas',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
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