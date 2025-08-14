import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/planejamento.dart';
import '../../models/categoria.dart';
import '../../utils/formatters.dart';

class AddBudgetScreen extends StatefulWidget {
  final DateTime mesSelecionado;
  final Planejamento? planejamento; // Para edição

  const AddBudgetScreen({
    super.key,
    required this.mesSelecionado,
    this.planejamento,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limiteController = TextEditingController();

  String? _categoriaId;
  bool _isLoading = false;
  bool get _isEditing => widget.planejamento != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _categoriaId = widget.planejamento!.categoriaId;
      _limiteController.text = widget.planejamento!.limite
          .toStringAsFixed(2)
          .replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _limiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          _isEditing ? 'Editar Orçamento' : 'Novo Orçamento',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarOrcamento,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final categoriasDespesa = financeProvider.categorias
              .where((c) => c.tipo == TipoCategoria.despesa)
              .toList();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Mês selecionado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Orçamento para ${Formatters.formatMonthName(widget.mesSelecionado)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Categoria
                const Text(
                  'Categoria',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _categoriaId,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Selecione uma categoria',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  items: categoriasDespesa.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria.id,
                      child: Row(
                        children: [
                          Icon(categoria.icone, color: categoria.cor, size: 20),
                          const SizedBox(width: 12),
                          Text(categoria.nome),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _categoriaId = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione uma categoria';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Limite
                const Text(
                  'Limite do Orçamento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Valor limite para gastos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _limiteController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'R\$ 0,00',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 24,
                          ),
                          border: InputBorder.none,
                          prefixText: 'R\$ ',
                          prefixStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor limite';
                          }
                          final valor = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (valor == null || valor <= 0) {
                            return 'Por favor, insira um valor válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Informações adicionais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sobre o orçamento',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• O orçamento define um limite de gastos para a categoria selecionada\n• Você será notificado quando atingir 80% do limite\n• O sistema calculará automaticamente seus gastos atuais',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _salvarOrcamento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final limite = double.parse(_limiteController.text.replaceAll(',', '.'));
      final mesFormatado =
          '${widget.mesSelecionado.year}-${widget.mesSelecionado.month.toString().padLeft(2, '0')}';

      print(
        'DEBUG: Salvando planejamento - Mês: $mesFormatado, Categoria: $_categoriaId, Limite: $limite',
      );

      final planejamento = Planejamento(
        id: _isEditing
            ? widget.planejamento!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        categoriaId: _categoriaId!,
        mes: mesFormatado,
        limite: limite,
        gastoAtual: _isEditing ? widget.planejamento!.gastoAtual : 0,
      );

      print('DEBUG: Planejamento criado: ${planejamento.toMap()}');

      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      print('DEBUG: Orçamento atual ID: ${financeProvider.orcamentoAtual?.id}');

      final success = _isEditing
          ? await financeProvider.atualizarPlanejamento(planejamento)
          : await financeProvider.adicionarPlanejamento(planejamento);

      print('DEBUG: Resultado do salvamento: $success');
      if (!success) {
        print('DEBUG: Erro: ${financeProvider.errorMessage}');
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Orçamento atualizado com sucesso!'
                    : 'Orçamento criado com sucesso!',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                financeProvider.errorMessage ?? 'Erro ao salvar orçamento',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Exceção ao salvar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao processar dados'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
