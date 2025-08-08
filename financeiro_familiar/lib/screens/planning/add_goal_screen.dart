import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/meta.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';

class AddGoalScreen extends StatefulWidget {
  final Meta? meta; // Para edição

  const AddGoalScreen({
    super.key,
    this.meta,
  });

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorMetaController = TextEditingController();
  final _valorAtualController = TextEditingController();
  
  DateTime _prazo = DateTime.now().add(const Duration(days: 365));
  IconData _iconeSelecionado = Icons.savings;
  Color _corSelecionada = Colors.blue;
  bool _isLoading = false;
  
  final List<Color> _coresPadrao = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];
  bool get _isEditing => widget.meta != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nomeController.text = widget.meta!.nome;
      _descricaoController.text = widget.meta!.descricao ?? '';
      _valorMetaController.text = widget.meta!.valorMeta.toStringAsFixed(2).replaceAll('.', ',');
      _valorAtualController.text = widget.meta!.valorAtual.toStringAsFixed(2).replaceAll('.', ',');
      _prazo = widget.meta!.prazo;
      if (widget.meta!.icone != null) {
        _iconeSelecionado = IconData(int.parse(widget.meta!.icone!), fontFamily: 'MaterialIcons');
      }
      if (widget.meta!.cor != null) {
        _corSelecionada = Color(int.parse(widget.meta!.cor!.replaceFirst('#', '0xFF')));
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorMetaController.dispose();
    _valorAtualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          _isEditing ? 'Editar Meta' : 'Nova Meta',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarMeta,
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
                    'Salvar',
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
            // Nome da meta
            const Text(
              'Nome da Meta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ex: Viagem para Europa, Carro novo...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira o nome da meta';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Descrição
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
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Descreva sua meta em detalhes...',
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

            const SizedBox(height: 24),

            // Valor da meta
            const Text(
              'Valor da Meta',
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
                          Icons.flag,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Valor objetivo',
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
                    controller: _valorMetaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o valor da meta';
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

            // Valor atual (apenas para edição)
            if (_isEditing) ...[
              const Text(
                'Valor Atual',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valorAtualController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'R\$ 0,00',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final valor = double.tryParse(value.replaceAll(',', '.'));
                    if (valor == null || valor < 0) {
                      return 'Por favor, insira um valor válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // Prazo
            const Text(
              'Prazo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selecionarPrazo,
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
                      Formatters.formatDate(_prazo),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_calcularDiasRestantes()} dias',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ícone
            const Text(
              'Ícone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.metaIcons.length,
                itemBuilder: (context, index) {
                  final icone = AppConstants.metaIcons.values.elementAt(index);
                  final isSelected = icone == _iconeSelecionado;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _iconeSelecionado = icone),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? _corSelecionada.withOpacity(0.2) : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _corSelecionada : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icone,
                        color: isSelected ? _corSelecionada : Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Cor
            const Text(
              'Cor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _coresPadrao.length,
                itemBuilder: (context, index) {
                  final cor = _coresPadrao[index];
                  final isSelected = cor == _corSelecionada;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _corSelecionada = cor),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: cor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

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
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sobre as metas',
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
                    '• Defina objetivos financeiros claros e mensuráveis\n• Acompanhe seu progresso ao longo do tempo\n• Adicione valores conforme for poupando para a meta',
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

  int _calcularDiasRestantes() {
    final agora = DateTime.now();
    final diferenca = _prazo.difference(agora).inDays;
    return diferenca > 0 ? diferenca : 0;
  }

  Future<void> _selecionarPrazo() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _prazo,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 anos
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (data != null) {
      setState(() => _prazo = data);
    }
  }

  Future<void> _salvarMeta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final valorMeta = double.parse(_valorMetaController.text.replaceAll(',', '.'));
      final valorAtual = _isEditing && _valorAtualController.text.isNotEmpty
          ? double.parse(_valorAtualController.text.replaceAll(',', '.'))
          : 0.0;
      
      final meta = Meta(
        id: _isEditing ? widget.meta!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        valorMeta: valorMeta,
        valorAtual: valorAtual,
        prazo: _prazo,
        descricao: _descricaoController.text.trim(),
        icone: _iconeSelecionado?.codePoint.toString(),
        cor: '#${_corSelecionada?.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      );

      final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      final success = _isEditing 
          ? await financeProvider.atualizarMeta(meta)
          : await financeProvider.adicionarMeta(meta);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Meta atualizada com sucesso!' : 'Meta criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(financeProvider.errorMessage ?? 'Erro ao salvar meta'),
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