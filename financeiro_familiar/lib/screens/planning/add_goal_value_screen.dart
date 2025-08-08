import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meta.dart';
import '../../providers/finance_provider.dart';
import '../../utils/formatters.dart';

class AddGoalValueScreen extends StatefulWidget {
  final Meta meta;

  const AddGoalValueScreen({
    super.key,
    required this.meta,
  });

  @override
  State<AddGoalValueScreen> createState() => _AddGoalValueScreenState();
}

class _AddGoalValueScreenState extends State<AddGoalValueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valorRestante = widget.meta.valorRestante;
    final percentualAtual = widget.meta.percentualConcluido;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Adicionar Valor',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _adicionarValor,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : const Text(
                    'Adicionar',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informações da meta
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (widget.meta.cor != null 
                  ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                  : Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (widget.meta.cor != null 
                    ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                    : Colors.blue).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (widget.meta.cor != null 
                            ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                            : Colors.blue).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.meta.icone != null 
                            ? IconData(int.parse(widget.meta.icone!), fontFamily: 'MaterialIcons')
                            : Icons.track_changes,
                          color: widget.meta.cor != null 
                            ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                            : Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.meta.nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Meta: ${Formatters.formatCurrency(widget.meta.valorMeta)}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Progresso atual
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valor atual',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(widget.meta.valorAtual),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Restante',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(valorRestante),
                            style: TextStyle(
                              color: valorRestante > 0 
                              ? (widget.meta.cor != null 
                                ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                                : Colors.blue)
                              : Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Barra de progresso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${percentualAtual.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: widget.meta.cor != null 
                                ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                                : Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentualAtual / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.meta.cor != null 
                              ? Color(int.parse(widget.meta.cor!.replaceFirst('#', '0xFF')))
                              : Colors.blue
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Valor a adicionar
            const Text(
              'Valor a Adicionar',
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
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
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Quanto você quer adicionar?',
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
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0,00',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 24,
                      ),
                      border: InputBorder.none,
                      prefixText: 'R\$ ',
                      prefixStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um valor';
                      }
                      final valor = double.tryParse(value.replaceAll(',', '.'));
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

            // Descrição (opcional)
            const Text(
              'Descrição (opcional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ex: Economia do mês, venda de item...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões de valor rápido
            const Text(
              'Valores Rápidos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildValorRapido(50),
                _buildValorRapido(100),
                _buildValorRapido(200),
                _buildValorRapido(500),
                _buildValorRapido(valorRestante.clamp(0, double.infinity)),
              ],
            ),

            const SizedBox(height: 32),

            // Informações
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
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Dica',
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
                    'Adicione valores regularmente para manter o progresso da sua meta. Cada contribuição te aproxima do seu objetivo!',
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
      ),
    );
  }

  Widget _buildValorRapido(double valor) {
    if (valor <= 0) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () {
        _valorController.text = valor.toStringAsFixed(2).replaceAll('.', ',');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          valor == widget.meta.valorRestante
              ? 'Completar (${Formatters.formatCurrency(valor)})'
              : Formatters.formatCurrency(valor),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _adicionarValor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));
      final novoValorAtual = widget.meta.valorAtual + valor;
      
      final metaAtualizada = widget.meta.copyWith(
        valorAtual: novoValorAtual,
      );

      final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      final success = await financeProvider.atualizarProgressoMeta(
        widget.meta.id,
        valor,
        _descricaoController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          
          // Mostrar mensagem especial se a meta foi completada
          final isCompleta = novoValorAtual >= widget.meta.valorMeta;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isCompleta 
                    ? '🎉 Parabéns! Meta "${widget.meta.nome}" concluída!'
                    : 'Valor adicionado com sucesso!',
              ),
              backgroundColor: isCompleta ? Colors.amber : Colors.green,
              duration: Duration(seconds: isCompleta ? 4 : 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(financeProvider.errorMessage ?? 'Erro ao adicionar valor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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