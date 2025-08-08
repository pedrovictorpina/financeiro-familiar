import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';

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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _temFiltrosAtivos() 
                        ? 'Nenhuma transação encontrada'
                        : 'Nenhuma transação registrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _temFiltrosAtivos()
                        ? 'Tente ajustar os filtros'
                        : 'Adicione sua primeira transação',
                    style: TextStyle(color: Colors.grey[500]),
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
        cor = Colors.green;
        icone = Icons.arrow_upward;
        sinal = '+';
        break;
      case TipoTransacao.despesa:
        cor = Colors.red;
        icone = Icons.arrow_downward;
        sinal = '-';
        break;
      case TipoTransacao.transferencia:
        cor = Colors.blue;
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalhes da Transação',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implementar edição
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implementar exclusão
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildDetailRow('Descrição', transacao.descricao),
                        _buildDetailRow('Tipo', _getTipoTransacaoNome(transacao.tipo)),
                        _buildDetailRow('Valor', Formatters.formatCurrency(transacao.valor)),
                        _buildDetailRow('Data', Formatters.formatDate(transacao.data)),
                        _buildDetailRow('Categoria', categoria.nome),
                        _buildDetailRow('Conta', conta.nome),
                        _buildDetailRow('Recorrente', transacao.recorrente ? 'Sim' : 'Não'),
                        if (transacao.contaDestinoId != null) ...[
                          _buildDetailRow('Conta Destino', 
                            financeProvider.contas.firstWhere(
                              (c) => c.id == transacao.contaDestinoId,
                              orElse: () => conta,
                            ).nome,
                          ),
                        ],
                        _buildDetailRow('Criado em', Formatters.formatDateTime(transacao.timestamp)),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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