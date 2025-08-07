import 'package:flutter/material.dart';
import '../models/orcamento.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';
import '../models/conta.dart';
import '../models/cartao.dart';
import '../models/meta.dart';
import '../models/planejamento.dart';
import '../models/config_dashboard.dart';
import '../services/firestore_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Estado atual
  Orcamento? _orcamentoAtual;
  List<Orcamento> _orcamentos = [];
  List<Transacao> _transacoes = [];
  List<Categoria> _categorias = [];
  List<Conta> _contas = [];
  List<Cartao> _cartoes = [];
  List<Meta> _metas = [];
  List<Planejamento> _planejamentos = [];
  List<ConfigDashboard> _configDashboard = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Orcamento? get orcamentoAtual => _orcamentoAtual;
  List<Orcamento> get orcamentos => _orcamentos;
  List<Transacao> get transacoes => _transacoes;
  List<Categoria> get categorias => _categorias;
  List<Conta> get contas => _contas;
  List<Cartao> get cartoes => _cartoes;
  List<Meta> get metas => _metas;
  List<Planejamento> get planejamentos => _planejamentos;
  List<ConfigDashboard> get configDashboard => _configDashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters calculados
  double get saldoTotal {
    return _contas.fold(0.0, (sum, conta) => sum + conta.saldoAtual);
  }

  double get receitasMes {
    final agora = DateTime.now();
    return _transacoes
        .where((t) => t.tipo == TipoTransacao.receita && 
                     t.data.month == agora.month && 
                     t.data.year == agora.year)
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double get despesasMes {
    final agora = DateTime.now();
    return _transacoes
        .where((t) => t.tipo == TipoTransacao.despesa && 
                     t.data.month == agora.month && 
                     t.data.year == agora.year)
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double get saldoMes => receitasMes - despesasMes;

  // ORÇAMENTOS
  void carregarOrcamentos(String uid) {
    _firestoreService.getOrcamentosDoUsuario(uid).listen(
      (orcamentos) {
        _orcamentos = orcamentos;
        if (_orcamentoAtual == null && orcamentos.isNotEmpty) {
          selecionarOrcamento(orcamentos.first.id!);
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar orçamentos: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> criarOrcamento(Orcamento orcamento) async {
    _setLoading(true);
    try {
      final id = await _firestoreService.criarOrcamento(orcamento);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selecionarOrcamento(String orcamentoId) {
    _orcamentoAtual = _orcamentos.firstWhere((o) => o.id == orcamentoId);
    _carregarDadosOrcamento(orcamentoId);
    notifyListeners();
  }

  Future<void> carregarDados() async {
    if (_orcamentoAtual != null) {
      _carregarDadosOrcamento(_orcamentoAtual!.id);
    }
  }

  void _carregarDadosOrcamento(String orcamentoId) {
    // Carregar transações
    _firestoreService.getTransacoes(orcamentoId).listen(
      (transacoes) {
        _transacoes = transacoes;
        notifyListeners();
      },
    );

    // Carregar categorias
    _firestoreService.getCategorias(orcamentoId).listen(
      (categorias) {
        _categorias = categorias;
        notifyListeners();
      },
    );

    // Carregar contas
    _firestoreService.getContas(orcamentoId).listen(
      (contas) {
        _contas = contas;
        notifyListeners();
      },
    );

    // Carregar cartões
    _firestoreService.getCartoes(orcamentoId).listen(
      (cartoes) {
        _cartoes = cartoes;
        notifyListeners();
      },
    );

    // Carregar metas
    _firestoreService.getMetas(orcamentoId).listen(
      (metas) {
        _metas = metas;
        notifyListeners();
      },
    );

    // Carregar planejamentos do mês atual
    final mesAtual = DateTime.now().toString().substring(0, 7); // YYYY-MM
    _firestoreService.getPlanejamentos(orcamentoId, mesAtual).listen(
      (planejamentos) {
        _planejamentos = planejamentos;
        notifyListeners();
      },
    );

    // Carregar configuração do dashboard
    _firestoreService.getConfigDashboard(orcamentoId).listen(
      (configs) {
        _configDashboard = configs;
        notifyListeners();
      },
    );
  }

  // TRANSAÇÕES
  Future<bool> adicionarTransacao(Transacao transacao) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.adicionarTransacao(_orcamentoAtual!.id!, transacao);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarTransacao(Transacao transacao) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.atualizarTransacao(_orcamentoAtual!.id!, transacao);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletarTransacao(String transacaoId) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.deletarTransacao(_orcamentoAtual!.id!, transacaoId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CATEGORIAS
  Future<bool> adicionarCategoria(Categoria categoria) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.adicionarCategoria(_orcamentoAtual!.id!, categoria);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CONTAS
  Future<bool> adicionarConta(Conta conta) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.adicionarConta(_orcamentoAtual!.id!, conta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // METAS
  Future<bool> adicionarMeta(Meta meta) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.adicionarMeta(_orcamentoAtual!.id!, meta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarProgressoMeta(String metaId, double novoValor) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.atualizarProgressoMeta(_orcamentoAtual!.id!, metaId, novoValor);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // PLANEJAMENTOS
  Future<bool> adicionarPlanejamento(Planejamento planejamento) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.adicionarPlanejamento(_orcamentoAtual!.id!, planejamento);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CONFIGURAÇÃO DASHBOARD
  Future<bool> salvarConfigDashboard(List<ConfigDashboard> configs) async {
    if (_orcamentoAtual == null) return false;
    
    _setLoading(true);
    try {
      await _firestoreService.salvarConfigDashboard(_orcamentoAtual!.id!, configs);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Filtros e consultas
  List<Transacao> getTransacoesPorPeriodo(DateTime inicio, DateTime fim) {
    return _transacoes.where((t) => 
        t.data.isAfter(inicio.subtract(const Duration(days: 1))) &&
        t.data.isBefore(fim.add(const Duration(days: 1)))
    ).toList();
  }

  List<Transacao> getTransacoesPorCategoria(String categoriaId) {
    return _transacoes.where((t) => t.categoriaId == categoriaId).toList();
  }

  Map<String, double> getGastosPorCategoria() {
    final gastos = <String, double>{};
    
    for (final transacao in _transacoes) {
      if (transacao.tipo == TipoTransacao.despesa) {
        final categoria = _categorias.firstWhere(
          (c) => c.id == transacao.categoriaId,
          orElse: () => Categoria(
            id: '',
            nome: 'Sem categoria',
            tipo: TipoCategoria.despesa,
            cor: Colors.grey,
            icone: Icons.help_outline,
          ),
        );
        
        gastos[categoria.nome] = (gastos[categoria.nome] ?? 0) + transacao.valor;
      }
    }
    
    return gastos;
  }
}