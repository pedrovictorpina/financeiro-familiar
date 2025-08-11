import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/conta.dart';
import '../../utils/bank_utils.dart';
import '../../utils/theme_extensions.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contas Bancárias',
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final contas = financeProvider.contas;
          
          return Column(
            children: [
              if (contas.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.account_balance_outlined,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhuma conta cadastrada',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Adicione sua primeira conta bancária\npara começar a controlar suas finanças',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contas.length,
                    itemBuilder: (context, index) {
                      final conta = contas[index];
                      final bankInfo = conta.banco != null 
                          ? BankUtils.getBankInfo(conta.banco!) 
                          : BankUtils.getBankInfo('outro');
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              width: 4,
                              color: bankInfo.color,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: bankInfo.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                bankInfo.icon,
                                color: bankInfo.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conta.nome,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        bankInfo.name,
                                        style: TextStyle(
                                          color: bankInfo.color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        ' • ',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        conta.tipoNome,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${conta.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: conta.saldoAtual >= 0 ? theme.colorScheme.primary : Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Saldo atual',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              color: theme.cardColor,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditAccountDialog(conta);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(conta);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 20),
                                      const SizedBox(width: 8),
                                      Text('Editar', style: TextStyle(color: theme.colorScheme.onSurface)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Excluir', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Botão adicionar
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAccountDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Adicionar Conta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAccountDialog() {
    final nomeController = TextEditingController();
    final saldoController = TextEditingController();
    TipoConta tipoSelecionado = TipoConta.banco;
    String bancoSelecionado = 'outro';
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Nova Conta',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome da conta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: saldoController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saldo inicial',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixText: 'R\$ ',
                    prefixStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: bancoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                  items: BankUtils.getBankKeys().map((banco) {
                    final bankInfo = BankUtils.getBankInfo(banco);
                    return DropdownMenuItem(
                      value: banco,
                      child: Row(
                        children: [
                          Icon(
                            bankInfo.icon,
                            color: bankInfo.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bankInfo.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      bancoSelecionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoConta>(
                  value: tipoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de conta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
                items: TipoConta.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(
                      _getTipoContaName(tipo),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tipoSelecionado = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => _addAccount(
                nomeController.text,
                saldoController.text,
                tipoSelecionado,
                bancoSelecionado,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoContaName(TipoConta tipo) {
    switch (tipo) {
      case TipoConta.banco:
        return 'Banco';
      case TipoConta.poupanca:
        return 'Poupança';
      case TipoConta.investimento:
        return 'Investimento';
      case TipoConta.carteira:
        return 'Carteira';
    }
  }

  void _addAccount(String nome, String saldoText, TipoConta tipo, String banco) {
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o nome da conta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double saldo = 0.0;
    if (saldoText.isNotEmpty) {
      saldo = double.tryParse(saldoText.replaceAll(',', '.')) ?? 0.0;
    }

    final bankInfo = BankUtils.getBankInfo(banco);
    final conta = Conta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      tipo: tipo,
      saldoAtual: saldo,
      saldoPrevisto: saldo,
      cor: bankInfo.color,
      banco: banco,
    );

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    financeProvider.adicionarConta(conta).then((success) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta adicionada com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(financeProvider.errorMessage ?? 'Erro ao adicionar conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showEditAccountDialog(Conta conta) {
    final nomeController = TextEditingController(text: conta.nome);
    final saldoController = TextEditingController(text: conta.saldoAtual.toString());
    TipoConta tipoSelecionado = conta.tipo;
    String bancoSelecionado = conta.banco ?? 'outro';
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Editar Conta',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome da conta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: saldoController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saldo atual',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixText: 'R\$ ',
                    prefixStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: bancoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                  items: BankUtils.getBankKeys().map((banco) {
                    final bankInfo = BankUtils.getBankInfo(banco);
                    return DropdownMenuItem(
                      value: banco,
                      child: Row(
                        children: [
                          Icon(
                            bankInfo.icon,
                            color: bankInfo.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bankInfo.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      bancoSelecionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoConta>(
                  value: tipoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de conta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                  items: TipoConta.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(
                        _getTipoContaName(tipo),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tipoSelecionado = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
               onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => _updateAccount(
                 dialogContext,
                 conta,
                 nomeController.text,
                 saldoController.text,
                 tipoSelecionado,
                 bancoSelecionado,
               ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAccount(BuildContext context, Conta conta, String nome, String saldoText, TipoConta tipo, String banco) {
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o nome da conta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double saldo = 0.0;
    if (saldoText.isNotEmpty) {
      saldo = double.tryParse(saldoText.replaceAll(',', '.')) ?? 0.0;
    }

    final bankInfo = BankUtils.getBankInfo(banco);
    final contaAtualizada = conta.copyWith(
      nome: nome,
      tipo: tipo,
      saldoAtual: saldo,
      saldoPrevisto: saldo,
      cor: bankInfo.color,
      banco: banco,
    );

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    financeProvider.atualizarConta(contaAtualizada).then((success) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta atualizada com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(financeProvider.errorMessage ?? 'Erro ao atualizar conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(Conta conta) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Excluir Conta',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir a conta "${conta.nome}"?\n\nEsta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(dialogContext, conta),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context, Conta conta) {
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    financeProvider.deletarConta(conta.id).then((success) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(financeProvider.errorMessage ?? 'Erro ao excluir conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}