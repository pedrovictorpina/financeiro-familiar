import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/finance_provider.dart';
import '../../models/cartao.dart';
import '../../utils/formatters.dart';

class MonthlyInvoicesScreen extends StatefulWidget {
  final Cartao cartao;

  const MonthlyInvoicesScreen({super.key, required this.cartao});

  @override
  State<MonthlyInvoicesScreen> createState() => _MonthlyInvoicesScreenState();
}

class _MonthlyInvoicesScreenState extends State<MonthlyInvoicesScreen> {
  final _valorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _descricao = '';
  final _descricaoController = TextEditingController();

  List<Map<String, dynamic>> _faturasMensais = [];
  bool _houveMudancas = false;

  @override
  void initState() {
    super.initState();
    _faturasMensais = List<Map<String, dynamic>>.from(
      widget.cartao.faturasMensais,
    );
    print('DEBUG: Faturas carregadas no initState: ${_faturasMensais.length}');
    print('DEBUG: Faturas do cartão: ${widget.cartao.faturasMensais}');
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_houveMudancas);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Faturas - ${widget.cartao.nome}'),
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        body: Column(
          children: [
            _buildAddInvoiceForm(),
            Expanded(child: _buildInvoicesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInvoiceForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.add_circle,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Adicionar Fatura Mensal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo de valor
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor da Fatura',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
            ),

            const SizedBox(height: 16),

            // Campo de descrição
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _descricao = value,
            ),

            const SizedBox(height: 16),

            // Seletor de data
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mês/Ano: ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão adicionar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Adicionar Fatura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    print(
      'DEBUG: _buildInvoicesList - Tamanho da lista: ${_faturasMensais.length}',
    );
    print(
      'DEBUG: _buildInvoicesList - Lista vazia? ${_faturasMensais.isEmpty}',
    );
    print('DEBUG: _buildInvoicesList - Conteúdo: $_faturasMensais');

    if (_faturasMensais.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma fatura adicionada',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione faturas mensais para melhor controle',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _faturasMensais.length,
      itemBuilder: (context, index) {
        final fatura = _faturasMensais[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: const Color(0xFF2A2A2A),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            title: Text(
              Formatters.formatCurrency(fatura['valor']),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fatura['mes'].toString().padLeft(2, '0')}/${fatura['ano']}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (fatura['descricao'].isNotEmpty)
                  Text(
                    fatura['descricao'],
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  onPressed: () => _editInvoice(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeInvoice(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addInvoice() async {
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar se já existe fatura para este mês/ano
    final existeFatura = _faturasMensais.any(
      (fatura) =>
          fatura['mes'] == _selectedDate.month &&
          fatura['ano'] == _selectedDate.year,
    );

    if (existeFatura) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Já existe uma fatura para este mês/ano'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _faturasMensais.add({
        'valor': valor,
        'mes': _selectedDate.month,
        'ano': _selectedDate.year,
        'descricao': _descricao,
        'data': Timestamp.now(),
      });

      // Ordenar por ano e mês (mais recente primeiro)
      _faturasMensais.sort((a, b) {
        final dateA = DateTime(a['ano'], a['mes']);
        final dateB = DateTime(b['ano'], b['mes']);
        return dateB.compareTo(dateA);
      });
    });

    // Limpar campos
    _valorController.clear();
    _descricaoController.clear();
    _descricao = '';

    // Salvar no cartão
    await _salvarFaturasMensais();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fatura adicionada com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeInvoice(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Remover Fatura',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja remover esta fatura?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _faturasMensais.removeAt(index);
              });

              // Salvar no cartão
              await _salvarFaturasMensais();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fatura removida com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarFaturasMensais() async {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );

    print('DEBUG: Salvando faturas mensais: ${_faturasMensais.length}');
    print('DEBUG: Dados das faturas: $_faturasMensais');

    // Criar uma cópia do cartão com as faturas atualizadas
    final cartaoAtualizado = widget.cartao.copyWith(
      faturasMensais: _faturasMensais,
    );

    print(
      'DEBUG: Cartão atualizado - faturas: ${cartaoAtualizado.faturasMensais}',
    );

    final resultado = await financeProvider.atualizarCartao(cartaoAtualizado);
    print('DEBUG: Resultado da atualização: $resultado');

    if (resultado) {
      _houveMudancas = true;
    }
  }

  void _editInvoice(int index) {
    final fatura = _faturasMensais[index];
    final controller = TextEditingController(
      text: fatura['valor'].toStringAsFixed(2).replaceAll('.', ','),
    );
    final descricaoController = TextEditingController(
      text: fatura['descricao'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Editar Fatura',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mês/Ano: ${fatura['mes'].toString().padLeft(2, '0')}/${fatura['ano']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Valor da Fatura',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoValor = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );

              if (novoValor == null || novoValor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, insira um valor válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              setState(() {
                _faturasMensais[index] = {
                  'valor': novoValor,
                  'mes': fatura['mes'],
                  'ano': fatura['ano'],
                  'descricao': descricaoController.text,
                  'data': fatura['data'],
                };
              });

              // Salvar no cartão
              await _salvarFaturasMensais();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fatura editada com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
