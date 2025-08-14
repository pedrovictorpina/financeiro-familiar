import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/transacao.dart';
import '../../models/conta.dart';
import '../../utils/formatters.dart';
import '../../utils/theme_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../utils/currency_input_formatter.dart';

class AddTransferScreen extends StatefulWidget {
  final Transacao? transacao;
  const AddTransferScreen({super.key, this.transacao});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  String? _contaOrigemId;
  String? _contaDestinoId;
  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transacao;
    if (t != null) {
      _descricaoController.text = t.descricao;
      _valorController.text = CurrencyInputFormatter.formatValue(t.valor);
      _dataSelecionada = t.data;
      _contaOrigemId = t.contaId;
      _contaDestinoId = t.contaDestinoId;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          widget.transacao != null
              ? 'Editar Transferência'
              : 'Nova Transferência',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarTransferencia,
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
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Valor
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TransactionColors.getTransferenciaBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TransactionColors.transferencia.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TransactionColors.transferencia.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              color: TransactionColors.transferencia,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Valor da transferência',
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        style: TextStyle(
                          color: context.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'R\$ 0,00',
                          hintStyle: TextStyle(
                            color: context.secondaryText,
                            fontSize: 24,
                          ),
                          border: InputBorder.none,
                          prefixText: 'R\$ ',
                          prefixStyle: const TextStyle(
                            color: TransactionColors.transferencia,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor';
                          }
                          final valor = CurrencyInputFormatter.parseValue(value);
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

                // Conta de Origem
                Text(
                  'Conta de origem',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _contaOrigemId,
                  dropdownColor: context.dropdownColor,
                  style: TextStyle(color: context.primaryText),
                  iconEnabledColor: TransactionColors.transferencia,
                  focusColor: TransactionColors.transferencia.withOpacity(0.1),
                  decoration: InputDecoration(
                    hintText: 'Selecione a conta de origem',
                    hintStyle: TextStyle(color: context.secondaryText),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: TransactionColors.transferencia.withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: TransactionColors.transferencia,
                        width: 2,
                      ),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(conta.nome),
                                Text(
                                  'Saldo: ${Formatters.formatCurrency(conta.saldoAtual)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _contaOrigemId = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione a conta de origem';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Ícone de transferência
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Conta de Destino
                Text(
                  'Conta de destino',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _contaDestinoId,
                  dropdownColor: context.dropdownColor,
                  style: TextStyle(color: context.primaryText),
                  iconEnabledColor: TransactionColors.transferencia,
                  focusColor: TransactionColors.transferencia.withOpacity(0.1),
                  decoration: InputDecoration(
                    hintText: 'Selecione a conta de destino',
                    hintStyle: TextStyle(color: context.secondaryText),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: TransactionColors.transferencia.withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: TransactionColors.transferencia,
                        width: 2,
                      ),
                    ),
                  ),
                  items: financeProvider.contas
                      .where((conta) => conta.id != _contaOrigemId)
                      .map((conta) {
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(conta.nome),
                                    Text(
                                      'Saldo: ${Formatters.formatCurrency(conta.saldoAtual)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) => setState(() => _contaDestinoId = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione a conta de destino';
                    }
                    if (value == _contaOrigemId) {
                      return 'A conta de destino deve ser diferente da origem';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Descrição
                Text(
                  'Descrição (opcional)',
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
                    hintText: 'Ex: Transferência para poupança, Pagamento...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
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
                      border: Border.all(color: context.borderColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: context.iconColorMuted,
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

                const SizedBox(height: 32),

                // Aviso sobre saldo
                if (_contaOrigemId != null)
                  ..._buildSaldoWarning(financeProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSaldoWarning(FinanceProvider financeProvider) {
    final contaOrigem = financeProvider.contas.firstWhere(
      (c) => c.id == _contaOrigemId,
      orElse: () => Conta(
        id: '',
        nome: '',
        tipo: TipoConta.banco,
        saldoAtual: 0,
        saldoPrevisto: 0,
        cor: Colors.grey,
      ),
    );

    final valor =
        double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
    final saldoInsuficiente = valor > contaOrigem.saldoAtual;

    if (saldoInsuficiente && valor > 0) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.warningColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: context.warningColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo insuficiente',
                      style: TextStyle(
                        color: context.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Saldo disponível: ${Formatters.formatCurrency(contaOrigem.saldoAtual)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ];
    }

    return [];
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
              primary: Colors.blue,
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

  Future<void> _salvarTransferencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validações adicionais antes de salvar
    final valor =
        CurrencyInputFormatter.parseValue(_valorController.text) ?? 0.0;

    // Verificar se as contas são diferentes
    if (_contaOrigemId == _contaDestinoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A conta de origem deve ser diferente da conta de destino',
          ),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    // Verificar saldo suficiente na conta de origem
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final contaOrigem = financeProvider.contas.firstWhere(
      (c) => c.id == _contaOrigemId,
      orElse: () => Conta(
        id: '',
        nome: '',
        tipo: TipoConta.banco,
        saldoAtual: 0,
        saldoPrevisto: 0,
        cor: Colors.grey,
      ),
    );

    if (valor > contaOrigem.saldoAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo insuficiente na conta de origem. Saldo disponível: ${Formatters.formatCurrency(contaOrigem.saldoAtual)}',
          ),
          backgroundColor: context.errorColor,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final descricao = _descricaoController.text.trim().isEmpty
          ? 'Transferência entre contas'
          : _descricaoController.text.trim();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? 'unknown';

      bool success = false;
      if (widget.transacao != null) {
        final transacaoAtualizada = widget.transacao!.copyWith(
          valor: valor,
          data: _dataSelecionada,
          descricao: descricao,
          contaId: _contaOrigemId!,
          contaDestinoId: _contaDestinoId!,
        );
        success = await financeProvider.atualizarTransacao(transacaoAtualizada);
      } else {
        final transacao = Transacao(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tipo: TipoTransacao.transferencia,
          valor: valor,
          data: _dataSelecionada,
          descricao: descricao,
          categoriaId: '', // Transferências não precisam de categoria
          contaId: _contaOrigemId!,
          contaDestinoId: _contaDestinoId!,
          recorrente: false,
          criadoPor: userId,
          timestamp: DateTime.now(),
        );
        success = await financeProvider.adicionarTransacao(transacao);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.transacao != null
                    ? 'Transferência atualizada com sucesso!'
                    : 'Transferência realizada com sucesso!',
              ),
              backgroundColor: TransactionColors.transferencia,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                financeProvider.errorMessage ?? 'Erro ao salvar transferência',
              ),
              backgroundColor: context.errorColor,
            ),
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
