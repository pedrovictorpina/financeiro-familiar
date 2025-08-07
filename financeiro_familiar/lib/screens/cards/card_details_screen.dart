import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/cartao.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';
import 'add_edit_card_screen.dart';
import 'monthly_invoices_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final Cartao cartao;
  
  const CardDetailsScreen({super.key, required this.cartao});
  
  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late Cartao cartao;
  
  @override
  void initState() {
    super.initState();
    cartao = widget.cartao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cartao.nome),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarCartao(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardVisual(),
            const SizedBox(height: 24),
            _buildLimitInfo(),
            const SizedBox(height: 24),
            _buildDatesInfo(),
            const SizedBox(height: 24),
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardVisual() {
    final percentualUtilizado = cartao.percentualUtilizado;
    
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cartao.cor,
            cartao.cor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cartao.cor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 32,
                ),
                Text(
                  AppConstants.cartaoBandeiras[cartao.bandeira ?? ''] ?? (cartao.bandeira ?? '').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              cartao.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Limite Total',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(cartao.limite),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Disponível',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(cartao.limiteDisponivel),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fatura Atual',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${percentualUtilizado.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentualUtilizado / 100,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(cartao.faturaAtualCalculada),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitInfo() {
    final percentualUtilizado = cartao.percentualUtilizado;
    Color statusColor;
    String statusText;
    
    if (percentualUtilizado >= 90) {
      statusColor = Colors.red;
      statusText = 'Limite quase esgotado';
    } else if (percentualUtilizado >= 70) {
      statusColor = Colors.orange;
      statusText = 'Atenção ao limite';
    } else {
      statusColor = Colors.green;
      statusText = 'Limite saudável';
    }

    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informações do Limite',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Limite Total',
                    Formatters.formatCurrency(cartao.limite),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Fatura Atual',
                    Formatters.formatCurrency(cartao.faturaAtualCalculada),
                    statusColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Disponível',
                    Formatters.formatCurrency(cartao.limiteDisponivel),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Utilização',
                    '${percentualUtilizado.toStringAsFixed(1)}%',
                    statusColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    percentualUtilizado >= 90 
                      ? Icons.warning 
                      : percentualUtilizado >= 70 
                        ? Icons.info 
                        : Icons.check_circle,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDatesInfo() {
    final proximoFechamento = cartao.proximoFechamento;
    final proximoVencimento = cartao.proximoVencimento;
    final diasParaFechamento = proximoFechamento.difference(DateTime.now()).inDays;
    final diasParaVencimento = proximoVencimento.difference(DateTime.now()).inDays;

    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Datas Importantes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fechamento',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dia ${cartao.fechamentoDia}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diasParaFechamento > 0 
                            ? 'Em $diasParaFechamento dias'
                            : diasParaFechamento == 0
                              ? 'Hoje'
                              : 'Próximo mês',
                          style: TextStyle(
                            color: diasParaFechamento <= 3 ? Colors.orange : Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vencimento',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dia ${cartao.vencimentoDia}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diasParaVencimento > 0 
                            ? 'Em $diasParaVencimento dias'
                            : diasParaVencimento == 0
                              ? 'Hoje'
                              : 'Vencido',
                          style: TextStyle(
                            color: diasParaVencimento <= 5 
                              ? Colors.red 
                              : diasParaVencimento <= 10
                                ? Colors.orange
                                : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: diasParaVencimento <= 5 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildActionButton(
              icon: Icons.edit,
              title: 'Editar Cartão',
              subtitle: 'Alterar informações do cartão',
              onTap: () => _editarCartao(context),
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: Icons.receipt_long,
              title: 'Faturas por Mês',
              subtitle: 'Adicionar e gerenciar faturas mensais',
              onTap: () => _gerenciarFaturasMensais(context),
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: Icons.delete,
              title: 'Excluir Cartão',
              subtitle: 'Remover cartão permanentemente',
              color: Colors.red,
              onTap: () => _confirmarExclusao(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFF8B5CF6);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: buttonColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _editarCartao(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCardScreen(cartao: cartao),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Excluir Cartão',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir o cartão "${cartao.nome}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Voltar para a tela anterior
              
              final financeProvider = Provider.of<FinanceProvider>(
                context, 
                listen: false,
              );
              
              final sucesso = await financeProvider.deletarCartao(cartao.id!);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sucesso 
                        ? 'Cartão excluído com sucesso'
                        : 'Erro ao excluir cartão',
                    ),
                    backgroundColor: sucesso ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _gerenciarFaturasMensais(BuildContext context) async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MonthlyInvoicesScreen(cartao: cartao),
      ),
    );
    
    // Se houve alteração nas faturas, recarregar os dados
    if (resultado == true) {
      final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      await financeProvider.carregarDados();
      
      // Atualizar o cartão local com os dados mais recentes
      final cartaoAtualizado = financeProvider.cartoes.firstWhere(
        (c) => c.id == cartao.id,
        orElse: () => cartao,
      );
      
      setState(() {
        cartao = cartaoAtualizado;
      });
    }
  }
}