import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/categoria.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Categorias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final categorias = financeProvider.categorias;
          
          return Column(
            children: [
              if (categorias.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withAlpha(51),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            size: 60,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Nenhuma categoria configurada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Crie categorias para organizar\nsuas receitas e despesas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _createDefaultCategories,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Criar Categorias Padrão'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Tabs para receitas e despesas
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: const Color(0xFF8B5CF6),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.trending_up, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Receitas (${categorias.where((c) => c.tipo == TipoCategoria.receita).length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.trending_down, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Despesas (${categorias.where((c) => c.tipo == TipoCategoria.despesa).length})'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            children: [
                              _buildCategoryList(
                                categorias.where((c) => c.tipo == TipoCategoria.receita).toList(),
                                TipoCategoria.receita,
                              ),
                              _buildCategoryList(
                                categorias.where((c) => c.tipo == TipoCategoria.despesa).toList(),
                                TipoCategoria.despesa,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Botões de ação
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (categorias.isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _createDefaultCategories,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B5CF6),
                            side: const BorderSide(color: Color(0xFF8B5CF6)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Padrão'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddCategoryDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Nova Categoria',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Categoria> categorias, TipoCategoria tipo) {
    if (categorias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == TipoCategoria.receita ? Icons.trending_up : Icons.trending_down,
              size: 48,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma categoria de ${tipo == TipoCategoria.receita ? 'receita' : 'despesa'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: categoria.cor.withAlpha(51),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    categoria.icone,
                    color: categoria.cor,
                    size: 24,
                  ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categoria ${categoria.tipo == TipoCategoria.receita ? 'de receita' : 'de despesa'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tipo == TipoCategoria.receita
                      ? Colors.green.withAlpha(51)
                        : Colors.red.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tipo == TipoCategoria.receita ? 'Receita' : 'Despesa',
                  style: TextStyle(
                    color: tipo == TipoCategoria.receita ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final nomeController = TextEditingController();
    TipoCategoria tipoSelecionado = TipoCategoria.despesa;
    Color corSelecionada = const Color(0xFF8B5CF6);
    IconData iconeSelecionado = Icons.category;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Nova Categoria',
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
                    labelText: 'Nome da categoria',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<TipoCategoria>(
                  value: tipoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF2A2A2A),
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                  items: TipoCategoria.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(
                        tipo == TipoCategoria.receita ? 'Receita' : 'Despesa',
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
                const SizedBox(height: 16),
                // Seletor de cor
                const Text(
                  'Cor',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _getCores().map((cor) {
                    final isSelected = cor == corSelecionada;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          corSelecionada = cor;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => _addCategory(
                nomeController.text,
                tipoSelecionado,
                corSelecionada,
                iconeSelecionado,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCores() {
    return [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
      const Color(0xFF10B981), // Green
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFFF6B35), // Orange
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6B7280), // Gray
    ];
  }

  void _addCategory(String nome, TipoCategoria tipo, Color cor, IconData icone) {
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o nome da categoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoria = Categoria(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      tipo: tipo,
      cor: cor,
      icone: icone,
    );

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    financeProvider.adicionarCategoria(categoria).then((success) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria adicionada com sucesso!'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(financeProvider.errorMessage ?? 'Erro ao adicionar categoria'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _createDefaultCategories() {
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    
    final categoriasPadrao = [
      // Receitas
      Categoria(
        id: 'receita_salario',
        nome: 'Salário',
        tipo: TipoCategoria.receita,
        cor: const Color(0xFF10B981),
        icone: Icons.work,
      ),
      Categoria(
        id: 'receita_freelance',
        nome: 'Freelance',
        tipo: TipoCategoria.receita,
        cor: const Color(0xFF3B82F6),
        icone: Icons.laptop,
      ),
      Categoria(
        id: 'receita_investimentos',
        nome: 'Investimentos',
        tipo: TipoCategoria.receita,
        cor: const Color(0xFF8B5CF6),
        icone: Icons.trending_up,
      ),
      
      // Despesas
      Categoria(
        id: 'despesa_alimentacao',
        nome: 'Alimentação',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFFEF4444),
        icone: Icons.restaurant,
      ),
      Categoria(
        id: 'despesa_transporte',
        nome: 'Transporte',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFFF59E0B),
        icone: Icons.directions_car,
      ),
      Categoria(
        id: 'despesa_moradia',
        nome: 'Moradia',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFF6B7280),
        icone: Icons.home,
      ),
      Categoria(
        id: 'despesa_saude',
        nome: 'Saúde',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFFEF4444),
        icone: Icons.local_hospital,
      ),
      Categoria(
        id: 'despesa_educacao',
        nome: 'Educação',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFF3B82F6),
        icone: Icons.school,
      ),
      Categoria(
        id: 'despesa_lazer',
        nome: 'Lazer',
        tipo: TipoCategoria.despesa,
        cor: const Color(0xFF8B5CF6),
        icone: Icons.movie,
      ),
    ];

    // Adicionar categorias uma por uma
    for (final categoria in categoriasPadrao) {
      financeProvider.adicionarCategoria(categoria);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Categorias padrão criadas com sucesso!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}