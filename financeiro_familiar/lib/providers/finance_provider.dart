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
import '../services/auth_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

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
        .where(
          (t) =>
              t.tipo == TipoTransacao.receita &&
              t.data.month == agora.month &&
              t.data.year == agora.year,
        )
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double get despesasMes {
    final agora = DateTime.now();
    return _transacoes
        .where(
          (t) =>
              t.tipo == TipoTransacao.despesa &&
              t.data.month == agora.month &&
              t.data.year == agora.year,
        )
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double get saldoMes => receitasMes - despesasMes;

  // Novos métodos para filtragem por mês
  double getReceitasMes(DateTime mes) {
    return _transacoes
        .where(
          (t) =>
              t.tipo == TipoTransacao.receita &&
              t.data.month == mes.month &&
              t.data.year == mes.year,
        )
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double getDespesasMes(DateTime mes) {
    return _transacoes
        .where(
          (t) =>
              t.tipo == TipoTransacao.despesa &&
              t.data.month == mes.month &&
              t.data.year == mes.year,
        )
        .fold(0.0, (sum, t) => sum + t.valor);
  }

  double getSaldoMes(DateTime mes) {
    return getReceitasMes(mes) - getDespesasMes(mes);
  }

  // Atualizar método getGastosPorCategoria para aceitar mês
  Map<String, double> getGastosPorCategoria([DateTime? mes]) {
    final mesReferencia = mes ?? DateTime.now();
    final gastos = <String, double>{};

    for (final transacao in _transacoes) {
      if (transacao.tipo == TipoTransacao.despesa &&
          transacao.data.month == mesReferencia.month &&
          transacao.data.year == mesReferencia.year) {
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

        gastos[categoria.nome] =
            (gastos[categoria.nome] ?? 0) + transacao.valor;
      }
    }

    return gastos;
  }

  // ORÇAMENTOS
  void carregarOrcamentos(String uid) {
    print('DEBUG: Iniciando carregamento de orçamentos para UID: $uid');
    _firestoreService
        .getOrcamentosDoUsuario(uid)
        .listen(
          (orcamentos) async {
            print('DEBUG: Orçamentos carregados: ${orcamentos.length}');
            _orcamentos = orcamentos;

            // Se não há orçamentos, criar um padrão
            if (orcamentos.isEmpty) {
              print(
                'DEBUG: Nenhum orçamento encontrado, criando orçamento padrão',
              );
              await _criarOrcamentoPadrao(uid);
              return; // O listener será chamado novamente após a criação
            }

            if (_orcamentoAtual == null && orcamentos.isNotEmpty) {
              print(
                'DEBUG: Selecionando primeiro orçamento: ${orcamentos.first.id}',
              );
              selecionarOrcamento(orcamentos.first.id!);
            }

            print('DEBUG: Orçamento atual: ${_orcamentoAtual?.id}');
            notifyListeners();
          },
          onError: (error) {
            print('DEBUG: Erro ao carregar orçamentos: $error');
            _errorMessage = 'Erro ao carregar orçamentos: $error';
            notifyListeners();
          },
        );
  }

  Future<void> _criarOrcamentoPadrao(String uid) async {
    try {
      final agora = DateTime.now();
      final mesAtual =
          '${agora.year}-${agora.month.toString().padLeft(2, '0')}';

      final orcamentoPadrao = Orcamento(
        id: '',
        nome: 'Meu Orçamento',
        criadorUid: uid,
        usuariosVinculados: [uid],
        mesAtual: mesAtual,
        dataCriacao: agora,
      );

      await _firestoreService.criarOrcamento(orcamentoPadrao);
    } catch (e) {
      _errorMessage = 'Erro ao criar orçamento padrão: $e';
      notifyListeners();
    }
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
    _firestoreService.getTransacoes(orcamentoId).listen((transacoes) {
      _transacoes = transacoes;
      notifyListeners();
    });

    // Carregar categorias
    _firestoreService.getCategorias(orcamentoId).listen((categorias) {
      _categorias = categorias;
      notifyListeners();
    });

    // Carregar contas
    _firestoreService.getContas(orcamentoId).listen((contas) {
      _contas = contas;
      notifyListeners();
    });

    // Carregar cartões
    _firestoreService.getCartoes(orcamentoId).listen((cartoes) {
      _cartoes = cartoes;
      notifyListeners();
    });

    // Carregar metas
    _firestoreService.getMetas(orcamentoId).listen((metas) {
      _metas = metas;
      notifyListeners();
    });

    // Carregar planejamentos do mês atual
    final mesAtual = DateTime.now().toString().substring(0, 7); // YYYY-MM
    _firestoreService.getPlanejamentos(orcamentoId, mesAtual).listen((
      planejamentos,
    ) {
      _planejamentos = planejamentos;
      notifyListeners();
    });

    // Carregar configuração do dashboard
    _firestoreService.getConfigDashboard(orcamentoId).listen((configs) {
      _configDashboard = configs;
      notifyListeners();
    });
  }

  // TRANSAÇÕES
  Future<bool> adicionarTransacao(Transacao transacao) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.adicionarTransacao(
        _orcamentoAtual!.id,
        transacao,
      );
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
      await _firestoreService.atualizarTransacao(
        _orcamentoAtual!.id,
        transacao,
      );
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
      await _firestoreService.deletarTransacao(
        _orcamentoAtual!.id,
        transacaoId,
      );
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
      await _firestoreService.adicionarCategoria(
        _orcamentoAtual!.id,
        categoria,
      );
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
      await _firestoreService.adicionarConta(_orcamentoAtual!.id, conta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarConta(Conta conta) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.atualizarConta(_orcamentoAtual!.id, conta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletarConta(String contaId) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.deletarConta(_orcamentoAtual!.id, contaId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CARTÕES
  Future<bool> adicionarCartao(Cartao cartao) async {
    if (_orcamentoAtual == null) {
      _errorMessage = 'Nenhum orçamento selecionado';
      print('DEBUG: Tentativa de adicionar cartão sem orçamento selecionado');
      return false;
    }

    print('DEBUG: Adicionando cartão ao orçamento: ${_orcamentoAtual!.id}');
    print('DEBUG: Usuário autenticado: ${_authService.currentUser?.uid}');

    _setLoading(true);
    try {
      await _firestoreService.adicionarCartao(_orcamentoAtual!.id, cartao);
      print('DEBUG: Cartão adicionado com sucesso');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('DEBUG: Erro ao adicionar cartão: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarCartao(Cartao cartao) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.atualizarCartao(_orcamentoAtual!.id, cartao);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletarCartao(String cartaoId) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.deletarCartao(_orcamentoAtual!.id, cartaoId);
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
      await _firestoreService.adicionarMeta(_orcamentoAtual!.id, meta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarMeta(Meta meta) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.atualizarMeta(_orcamentoAtual!.id, meta);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarProgressoMeta(
    String metaId,
    double valorAdicionado,
    String? descricao,
  ) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.atualizarProgressoMeta(
        _orcamentoAtual!.id,
        metaId,
        valorAdicionado,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> excluirMeta(String metaId) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.excluirMeta(_orcamentoAtual!.id, metaId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // PLANEJAMENTOS
  void carregarPlanejamentosMes(DateTime mes) {
    if (_orcamentoAtual == null) return;

    final mesFormatado = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';
    _firestoreService
        .getPlanejamentos(_orcamentoAtual!.id, mesFormatado)
        .listen(
          (planejamentos) {
            _planejamentos = planejamentos;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Erro ao carregar planejamentos: $error';
            notifyListeners();
          },
        );
  }

  Future<bool> adicionarPlanejamento(Planejamento planejamento) async {
    if (_orcamentoAtual == null) {
      print('DEBUG: Erro - Orçamento atual é null');
      return false;
    }

    print(
      'DEBUG: Adicionando planejamento ao orçamento ${_orcamentoAtual!.id}',
    );
    print('DEBUG: Dados do planejamento: ${planejamento.toMap()}');

    _setLoading(true);
    try {
      final id = await _firestoreService.adicionarPlanejamento(
        _orcamentoAtual!.id,
        planejamento,
      );
      print('DEBUG: Planejamento adicionado com ID: $id');
      return true;
    } catch (e) {
      print('DEBUG: Erro ao adicionar planejamento: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> atualizarPlanejamento(Planejamento planejamento) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.atualizarPlanejamento(
        _orcamentoAtual!.id,
        planejamento,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> excluirPlanejamento(String planejamentoId) async {
    if (_orcamentoAtual == null) return false;

    _setLoading(true);
    try {
      await _firestoreService.excluirPlanejamento(
        _orcamentoAtual!.id,
        planejamentoId,
      );
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
      await _firestoreService.salvarConfigDashboard(
        _orcamentoAtual!.id,
        configs,
      );
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
    return _transacoes
        .where(
          (t) =>
              t.data.isAfter(inicio.subtract(const Duration(days: 1))) &&
              t.data.isBefore(fim.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<Transacao> getTransacoesPorCategoria(String categoriaId) {
    return _transacoes.where((t) => t.categoriaId == categoriaId).toList();
  }

  // Método getGastosPorCategoria sem filtro de mês foi removido para evitar duplicidade.
  // Utilize getGastosPorCategoria([DateTime? mes]) definido anteriormente, passando o mês desejado ou null para usar o mês atual.

  // Método para atualizar orçamento
  Future<bool> atualizarOrcamento(dynamic orcamento) async {
    _setLoading(true);
    try {
      // Simular atualização do orçamento
      // Em uma implementação real, isso seria salvo no Firestore
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método para restaurar backup
  Future<bool> restaurarBackup(Map<String, dynamic> backupData) async {
    _setLoading(true);
    try {
      // Simular restauração do backup
      // Em uma implementação real, isso restauraria todos os dados do backup
      await Future.delayed(const Duration(milliseconds: 1000));

      // Recarregar dados após restauração
      await carregarDados();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
