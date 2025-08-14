import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/cartao.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class AddEditCardScreen extends StatefulWidget {
  final Cartao? cartao;

  const AddEditCardScreen({super.key, this.cartao});

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _limiteController = TextEditingController();

  final _fechamentoDiaController = TextEditingController();
  final _vencimentoDiaController = TextEditingController();

  String _bandeiraSelecionada = 'visa';
  Color _corSelecionada = const Color(0xFF8B5CF6);
  bool _isLoading = false;

  final List<Color> _coresDisponiveis = [
    const Color(0xFF8B5CF6), // Roxo
    const Color(0xFF3B82F6), // Azul
    const Color(0xFF10B981), // Verde
    const Color(0xFFF59E0B), // Amarelo
    const Color(0xFFEF4444), // Vermelho
    const Color(0xFF8B5A2B), // Marrom
    const Color(0xFF6B7280), // Cinza
    const Color(0xFFEC4899), // Rosa
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cartao != null) {
      _preencherCampos();
    }
  }

  void _preencherCampos() {
    final cartao = widget.cartao!;
    _nomeController.text = cartao.nome;
    _limiteController.text = cartao.limite
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    _fechamentoDiaController.text = cartao.fechamentoDia.toString();
    _vencimentoDiaController.text = cartao.vencimentoDia.toString();
    _bandeiraSelecionada = cartao.bandeira ?? '';
    _corSelecionada = cartao.cor;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _limiteController.dispose();

    _fechamentoDiaController.dispose();
    _vencimentoDiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.cartao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Cartão' : 'Novo Cartão'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview do cartão
            _buildCardPreview(),
            const SizedBox(height: 24),

            // Campos do formulário
            _buildFormFields(),

            const SizedBox(height: 32),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvarCartao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isEdicao ? 'Atualizar' : 'Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_corSelecionada, _corSelecionada.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _corSelecionada.withOpacity(0.3),
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
                const Icon(Icons.credit_card, color: Colors.white, size: 32),
                Text(
                  AppConstants.cartaoBandeiras[_bandeiraSelecionada] ??
                      _bandeiraSelecionada.toUpperCase(),
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
              _nomeController.text.isEmpty
                  ? 'Nome do Cartão'
                  : _nomeController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Limite',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      _limiteController.text.isEmpty
                          ? 'R\$ 0,00'
                          : 'R\$ ${_limiteController.text}',
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
                      'Vencimento',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      _vencimentoDiaController.text.isEmpty
                          ? 'Dia --'
                          : 'Dia ${_vencimentoDiaController.text}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do cartão
        TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: 'Nome do Cartão',
            hintText: 'Ex: Cartão Principal',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),

        const SizedBox(height: 16),

        // Bandeira
        DropdownButtonFormField<String>(
          value: _bandeiraSelecionada,
          decoration: const InputDecoration(
            labelText: 'Bandeira',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.payment),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF2A2A2A),
          items: AppConstants.cartaoBandeiras.entries.map((entry) {
            return DropdownMenuItem(value: entry.key, child: Text(entry.value));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _bandeiraSelecionada = value!;
            });
          },
        ),

        const SizedBox(height: 16),

        // Limite
        TextFormField(
          controller: _limiteController,
          decoration: const InputDecoration(
            labelText: 'Limite do Cartão',
            hintText: '0,00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
            prefixText: 'R\$ ',
          ),
          style: const TextStyle(color: Colors.white),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Limite é obrigatório';
            }
            final numero = double.tryParse(value.replaceAll(',', '.'));
            if (numero == null || numero <= 0) {
              return 'Limite deve ser maior que zero';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),

        const SizedBox(height: 16),

        // Dias de fechamento e vencimento
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fechamentoDiaController,
                decoration: const InputDecoration(
                  labelText: 'Dia do Fechamento',
                  hintText: '1-31',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  final dia = int.tryParse(value);
                  if (dia == null || dia < 1 || dia > 31) {
                    return 'Dia inválido';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _vencimentoDiaController,
                decoration: const InputDecoration(
                  labelText: 'Dia do Vencimento',
                  hintText: '1-31',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  final dia = int.tryParse(value);
                  if (dia == null || dia < 1 || dia > 31) {
                    return 'Dia inválido';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Seletor de cor
        const Text(
          'Cor do Cartão',
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
          children: _coresDisponiveis.map((cor) {
            final isSelected = cor == _corSelecionada;
            return GestureDetector(
              onTap: () => setState(() => _corSelecionada = cor),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _salvarCartao() async {
    if (!_formKey.currentState!.validate()) return;

    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );

    // Verificar se há um orçamento selecionado
    if (financeProvider.orcamentoAtual == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum orçamento selecionado. Selecione um orçamento nas configurações.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final limite = double.parse(_limiteController.text.replaceAll(',', '.'));

      final fechamentoDia = int.parse(_fechamentoDiaController.text);
      final vencimentoDia = int.parse(_vencimentoDiaController.text);

      final cartao = Cartao(
        id: widget.cartao?.id ?? '',
        nome: _nomeController.text.trim(),
        limite: limite,
        faturaAtual: 0.0,
        fechamentoDia: fechamentoDia,
        vencimentoDia: vencimentoDia,
        bandeira: _bandeiraSelecionada,
        cor: _corSelecionada,
        faturasMensais: widget.cartao?.faturasMensais ?? [],
      );

      bool sucesso;

      if (widget.cartao != null) {
        sucesso = await financeProvider.atualizarCartao(cartao);
      } else {
        sucesso = await financeProvider.adicionarCartao(cartao);
      }

      if (mounted) {
        if (sucesso) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.cartao != null
                    ? 'Cartão atualizado com sucesso'
                    : 'Cartão adicionado com sucesso',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                financeProvider.errorMessage ?? 'Erro ao salvar cartão',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
