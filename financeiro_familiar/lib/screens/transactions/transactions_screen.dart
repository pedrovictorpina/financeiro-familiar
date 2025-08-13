import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';
import '../../utils/theme_extensions.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TipoTransacao? _filtroTipo;
  String? _filtroCategoria;
  String? _filtroConta;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _textoPesquisa = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
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
          final transacoesFiltradas = _filtrarTransacoes(financeProvider.transacoes);
          
          if (transacoesFiltradas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: context.iconColorMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _temFiltrosAtivos() 
                        ? 'Nenhuma transação encontrada'
                        : 'Nenhuma transação registrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: context.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _temFiltrosAtivos()
                        ? 'Tente ajustar os filtros'
                        : 'Adicione sua primeira transação',
                    style: TextStyle(color: context.mutedText),
                  ),
                  if (_temFiltrosAtivos()) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _limparFiltros,
                      child: const Text('Limpar Filtros'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_temFiltrosAtivos()) _buildFilterChips(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await financeProvider.carregarDados();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transacoesFiltradas.length,
                    itemBuilder: (context, index) {
                      final transacao = transacoesFiltradas[index];
                      return _buildTransactionCard(context, transacao, financeProvider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filtroTipo != null)
            Chip(
              label: Text(_getTipoTransacaoNome(_filtroTipo!)),
              onDeleted: () => setState(() => _filtroTipo = null),
            ),
          if (_filtroCategoria != null)
            Chip(
              label: Text(_filtroCategoria!),
              onDeleted: () => setState(() => _filtroCategoria = null),
            ),
          if (_filtroConta != null)
            Chip(
              label: Text(_filtroConta!),
              onDeleted: () => setState(() => _filtroConta = null),
            ),
          if (_dataInicio != null || _dataFim != null)
            Chip(
              label: Text(_getTextoFiltroData()),
              onDeleted: () => setState(() {
                _dataInicio = null;
                _dataFim = null;
              }),
            ),
          if (_textoPesquisa.isNotEmpty)
            Chip(
              label: Text('"$_textoPesquisa"'),
              onDeleted: () => setState(() {
                _textoPesquisa = '';
                _searchController.clear();
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transacao transacao, FinanceProvider financeProvider) {
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

    Color cor;
    IconData icone;
    String sinal;
    
    switch (transacao.tipo) {
      case TipoTransacao.receita:
        cor = TransactionColors.receita;
        icone = Icons.arrow_upward;
        sinal = '+';
        break;
      case TipoTransacao.despesa:
        cor = TransactionColors.despesa;
        icone = Icons.arrow_downward;
        sinal = '-';
        break;
      case TipoTransacao.transferencia:
        cor = TransactionColors.transferencia;
        icone = Icons.swap_horiz;
        sinal = '';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withAlpha(51),
          child: Icon(icone, color: cor),
        ),
        title: Text(
          transacao.descricao,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(categoria.nome),
            Text(
              '${conta.nome} • ${Formatters.formatDate(transacao.data)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sinal${Formatters.formatCurrency(transacao.valor)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cor,
                fontSize: 16,
              ),
            ),
            if (transacao.recorrente)
              Icon(
                Icons.repeat,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(context, transacao, financeProvider),
      ),
    );
  }

  List<Transacao> _filtrarTransacoes(List<Transacao> transacoes) {
    return transacoes.where((transacao) {
      // Filtro por tipo
      if (_filtroTipo != null && transacao.tipo != _filtroTipo) {
        return false;
      }
      
      // Filtro por categoria
      if (_filtroCategoria != null && transacao.categoriaId != _filtroCategoria) {
        return false;
      }
      
      // Filtro por conta
      if (_filtroConta != null && transacao.contaId != _filtroConta) {
        return false;
      }
      
      // Filtro por data
      if (_dataInicio != null && transacao.data.isBefore(_dataInicio!)) {
        return false;
      }
      if (_dataFim != null && transacao.data.isAfter(_dataFim!)) {
        return false;
      }
      
      // Filtro por texto
      if (_textoPesquisa.isNotEmpty) {
        final texto = _textoPesquisa.toLowerCase();
        return transacao.descricao.toLowerCase().contains(texto);
      }
      
      return true;
    }).toList();
  }

  bool _temFiltrosAtivos() {
    return _filtroTipo != null ||
           _filtroCategoria != null ||
           _filtroConta != null ||
           _dataInicio != null ||
           _dataFim != null ||
           _textoPesquisa.isNotEmpty;
  }

  void _limparFiltros() {
    setState(() {
      _filtroTipo = null;
      _filtroCategoria = null;
      _filtroConta = null;
      _dataInicio = null;
      _dataFim = null;
      _textoPesquisa = '';
      _searchController.clear();
    });
  }

  String _getTipoTransacaoNome(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.receita:
        return 'Receita';
      case TipoTransacao.despesa:
        return 'Despesa';
      case TipoTransacao.transferencia:
        return 'Transferência';
    }
  }

  String _getTextoFiltroData() {
    if (_dataInicio != null && _dataFim != null) {
      return '${Formatters.formatDate(_dataInicio!)} - ${Formatters.formatDate(_dataFim!)}';
    } else if (_dataInicio != null) {
      return 'A partir de ${Formatters.formatDate(_dataInicio!)}';
    } else if (_dataFim != null) {
      return 'Até ${Formatters.formatDate(_dataFim!)}';
    }
    return '';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          return AlertDialog(
            title: const Text('Filtros'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro por tipo
                  const Text('Tipo de Transação'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TipoTransacao?>(
                    value: _filtroTipo,
                    decoration: const InputDecoration(
                      hintText: 'Todos os tipos',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<TipoTransacao?>(
                        value: null,
                        child: Text('Todos os tipos'),
                      ),
                      ...TipoTransacao.values.map((tipo) {
                        return DropdownMenuItem<TipoTransacao?>(
                          value: tipo,
                          child: Text(_getTipoTransacaoNome(tipo)),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _filtroTipo = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filtro por categoria
                  const Text('Categoria'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _filtroCategoria,
                    decoration: const InputDecoration(
                      hintText: 'Todas as categorias',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas as categorias'),
                      ),
                      ...financeProvider.categorias.map((categoria) {
                        return DropdownMenuItem<String?>(
                          value: categoria.id,
                          child: Text(categoria.nome),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _filtroCategoria = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filtro por conta
                  const Text('Conta'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _filtroConta,
                    decoration: const InputDecoration(
                      hintText: 'Todas as contas',
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
                    onChanged: (value) => setState(() => _filtroConta = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filtro por período
                  const Text('Período'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Data inicial',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _dataInicio != null 
                                ? Formatters.formatDate(_dataInicio!) 
                                : '',
                          ),
                          onTap: () async {
                            final data = await showDatePicker(
                              context: context,
                              initialDate: _dataInicio ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (data != null) {
                              setState(() => _dataInicio = data);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Data final',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _dataFim != null 
                                ? Formatters.formatDate(_dataFim!) 
                                : '',
                          ),
                          onTap: () async {
                            final data = await showDatePicker(
                              context: context,
                              initialDate: _dataFim ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (data != null) {
                              setState(() => _dataFim = data);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _limparFiltros();
                  Navigator.of(context).pop();
                },
                child: const Text('Limpar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pesquisar Transações'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Digite para pesquisar...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onChanged: (value) {
              setState(() => _textoPesquisa = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _textoPesquisa = '';
                  _searchController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Pesquisar'),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transacao transacao, FinanceProvider financeProvider) {
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

    Color cor;
    IconData icone;
    String sinal;
    
    switch (transacao.tipo) {
      case TipoTransacao.receita:
        cor = TransactionColors.receita;
        icone = Icons.arrow_upward;
        sinal = '+';
        break;
      case TipoTransacao.despesa:
        cor = TransactionColors.despesa;
        icone = Icons.arrow_downward;
        sinal = '-';
        break;
      case TipoTransacao.transferencia:
        cor = TransactionColors.transferencia;
        icone = Icons.swap_horiz;
        sinal = '';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header com indicador e botões de ação
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Cabeçalho principal com valor em destaque
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cor.withOpacity(0.1),
                          cor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icone,
                                color: cor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTipoTransacaoNome(transacao.tipo),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transacao.descricao,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // TODO: Implementar edição
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Edição em desenvolvimento')),
                                    );
                                  },
                                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  onPressed: () {
                                    // TODO: Implementar exclusão
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Exclusão em desenvolvimento')),
                                    );
                                  },
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Valor em destaque
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$sinal${Formatters.formatCurrency(transacao.valor)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: cor,
                                ),
                              ),
                              if (transacao.recorrente) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        size: 16,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Recorrente',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lista de detalhes
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildModernDetailSection('Informações Gerais', [
                          _buildModernDetailRow(
                            Icons.calendar_today_outlined,
                            'Data',
                            Formatters.formatDate(transacao.data),
                            Theme.of(context).colorScheme.primary,
                          ),
                          _buildModernDetailRow(
                            categoria.icone,
                            'Categoria',
                            categoria.nome,
                            categoria.cor,
                          ),
                          _buildModernDetailRow(
                            Icons.account_balance_wallet_outlined,
                            'Conta',
                            conta.nome,
                            conta.cor,
                          ),
                          if (transacao.contaDestinoId != null)
                            _buildModernDetailRow(
                              Icons.arrow_forward,
                              'Conta Destino',
                              financeProvider.contas.firstWhere(
                                (c) => c.id == transacao.contaDestinoId,
                                orElse: () => conta,
                              ).nome,
                              Colors.orange,
                            ),
                        ]),
                        
                        const SizedBox(height: 24),
                        
                        _buildModernDetailSection('Informações do Sistema', [
                          _buildModernDetailRow(
                            Icons.access_time,
                            'Criado em',
                            Formatters.formatDateTime(transacao.timestamp),
                            Colors.grey,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}