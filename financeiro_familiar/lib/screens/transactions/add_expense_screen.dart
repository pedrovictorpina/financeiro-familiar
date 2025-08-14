import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/transacao.dart';
import '../../models/categoria.dart';
import '../../models/conta.dart';
import '../../utils/formatters.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/currency_input_formatter.dart';
import '../../providers/auth_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Transacao? transacao; // Opcional para modo de edição

  const AddExpenseScreen({super.key, this.transacao});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  String? _categoriaId;
  String? _contaId;
  DateTime _dataSelecionada = DateTime.now();
  bool _recorrente = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      final t = widget.transacao!;
      _descricaoController.text = t.descricao;
      _valorController.text = CurrencyInputFormatter.formatValue(t.valor);
      _categoriaId = t.categoriaId;
      _contaId = t.contaId;
      _dataSelecionada = t.data;
      _recorrente = t.recorrente;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.transacao != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          isEditMode ? 'Editar Despesa' : 'Nova Despesa',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarDespesa,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : Text(
                    isEditMode ? 'Atualizar' : 'Salvar',
                    style: const TextStyle(
                      color: Colors.red,
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
                // Valor
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Text(
                            'Valor da despesa',
                            style: TextStyle(
                              color: context.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        style: TextStyle(
                          color: context.primaryText,
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
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor';
                          }
                          final valor = CurrencyInputFormatter.parseValue(
                            value,
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

                // Descrição
                Text(
                  'Descrição',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descricaoController,
                  style: TextStyle(color: context.primaryText),
                  decoration: const InputDecoration(
                    hintText: 'Ex: Supermercado, Combustível, Conta de luz...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Categoria
                Text(
                  'Categoria',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _categoriaId,
                  dropdownColor: context.dropdownColor,
                  style: TextStyle(color: context.primaryText),
                  decoration: const InputDecoration(
                    hintText: 'Selecione uma categoria',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
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

                // Conta
                Text(
                  'Conta',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _contaId,
                  dropdownColor: context.dropdownColor,
                  style: TextStyle(color: context.primaryText),
                  decoration: const InputDecoration(
                    hintText: 'Selecione uma conta',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  items: financeProvider.contas.map((conta) {
                    return DropdownMenuItem<String>(
                      value: conta.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: conta.cor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(conta.nome),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _contaId = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione uma conta';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Data
                Text(
                  'Data',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selecionarData,
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                          Formatters.formatDate(_dataSelecionada),
                          style: TextStyle(
                            color: context.primaryText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recorrente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.containerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, color: context.iconColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Despesa recorrente',
                              style: TextStyle(
                                color: context.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Esta despesa se repete mensalmente',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _recorrente,
                        onChanged: (value) =>
                            setState(() => _recorrente = value),
                        activeColor: Colors.red,
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

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  Future<void> _salvarDespesa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final parsed =
          CurrencyInputFormatter.parseValue(_valorController.text) ?? 0.0;
      final valor = parsed;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? 'unknown';
      final isEditMode = widget.transacao != null;

      final transacao = isEditMode
          ? widget.transacao!.copyWith(
              valor: valor,
              data: _dataSelecionada,
              descricao: _descricaoController.text.trim(),
              categoriaId: _categoriaId!,
              contaId: _contaId!,
              recorrente: _recorrente,
            )
          : Transacao(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              tipo: TipoTransacao.despesa,
              valor: valor,
              data: _dataSelecionada,
              descricao: _descricaoController.text.trim(),
              categoriaId: _categoriaId!,
              contaId: _contaId!,
              recorrente: _recorrente,
              criadoPor: userId,
              timestamp: DateTime.now(),
            );

      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      final success = isEditMode
          ? await financeProvider.atualizarTransacao(transacao)
          : await financeProvider.adicionarTransacao(transacao);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? 'Despesa atualizada com sucesso!'
                    : 'Despesa adicionada com sucesso!',
              ),
              backgroundColor: TransactionColors.despesa,
            ),
          );
        }
      } else {
        if (mounted) {
          final msg =
              financeProvider.errorMessage ??
              (isEditMode
                  ? 'Erro ao atualizar despesa'
                  : 'Erro ao adicionar despesa');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: context.errorColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar dados'),
            backgroundColor: context.errorColor,
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
