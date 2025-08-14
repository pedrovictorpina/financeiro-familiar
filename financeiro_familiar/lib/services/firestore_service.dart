import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orcamento.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';
import '../models/conta.dart';
import '../models/cartao.dart';
import '../models/meta.dart';
import '../models/planejamento.dart';
import '../models/config_dashboard.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ORÇAMENTOS
  Future<String> criarOrcamento(Orcamento orcamento) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .add(orcamento.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar orçamento: $e');
    }
  }

  Stream<List<Orcamento>> getOrcamentosDoUsuario(String uid) {
    return _firestore
        .collection('orcamentos')
        .where('usuariosVinculados', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Orcamento.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> adicionarUsuarioAoOrcamento(
    String orcamentoId,
    String uid,
  ) async {
    try {
      await _firestore.collection('orcamentos').doc(orcamentoId).update({
        'usuariosVinculados': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar usuário ao orçamento: $e');
    }
  }

  // TRANSAÇÕES
  Future<String> adicionarTransacao(
    String orcamentoId,
    Transacao transacao,
  ) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('transacoes')
          .add(transacao.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar transação: $e');
    }
  }

  Stream<List<Transacao>> getTransacoes(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('transacoes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Transacao.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> atualizarTransacao(
    String orcamentoId,
    Transacao transacao,
  ) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('transacoes')
          .doc(transacao.id)
          .update(transacao.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar transação: $e');
    }
  }

  Future<void> deletarTransacao(String orcamentoId, String transacaoId) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('transacoes')
          .doc(transacaoId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }

  // CATEGORIAS
  Future<String> adicionarCategoria(
    String orcamentoId,
    Categoria categoria,
  ) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('categorias')
          .add(categoria.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar categoria: $e');
    }
  }

  Stream<List<Categoria>> getCategorias(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('categorias')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Categoria.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // CONTAS
  Future<String> adicionarConta(String orcamentoId, Conta conta) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('contas')
          .add(conta.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar conta: $e');
    }
  }

  Stream<List<Conta>> getContas(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('contas')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Conta.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> atualizarSaldoConta(
    String orcamentoId,
    String contaId,
    double novoSaldo,
  ) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('contas')
          .doc(contaId)
          .update({'saldoAtual': novoSaldo});
    } catch (e) {
      throw Exception('Erro ao atualizar saldo da conta: $e');
    }
  }

  Future<void> atualizarConta(String orcamentoId, Conta conta) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('contas')
          .doc(conta.id)
          .update(conta.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar conta: $e');
    }
  }

  Future<void> deletarConta(String orcamentoId, String contaId) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('contas')
          .doc(contaId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar conta: $e');
    }
  }

  // CARTÕES
  Future<String> adicionarCartao(String orcamentoId, Cartao cartao) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('cartoes')
          .add(cartao.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar cartão: $e');
    }
  }

  Stream<List<Cartao>> getCartoes(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('cartoes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Cartao.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> atualizarCartao(String orcamentoId, Cartao cartao) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('cartoes')
          .doc(cartao.id)
          .update(cartao.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar cartão: $e');
    }
  }

  Future<void> deletarCartao(String orcamentoId, String cartaoId) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('cartoes')
          .doc(cartaoId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar cartão: $e');
    }
  }

  // METAS
  Future<String> adicionarMeta(String orcamentoId, Meta meta) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('metas')
          .add(meta.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar meta: $e');
    }
  }

  Stream<List<Meta>> getMetas(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('metas')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Meta.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> atualizarProgressoMeta(
    String orcamentoId,
    String metaId,
    double novoValor,
  ) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('metas')
          .doc(metaId)
          .update({'valorAtual': novoValor});
    } catch (e) {
      throw Exception('Erro ao atualizar progresso da meta: $e');
    }
  }

  Future<void> atualizarMeta(String orcamentoId, Meta meta) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('metas')
          .doc(meta.id)
          .update(meta.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }

  Future<void> excluirMeta(String orcamentoId, String metaId) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('metas')
          .doc(metaId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir meta: $e');
    }
  }

  // PLANEJAMENTOS
  Future<String> adicionarPlanejamento(
    String orcamentoId,
    Planejamento planejamento,
  ) async {
    try {
      final docRef = await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('planejamentos')
          .add(planejamento.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar planejamento: $e');
    }
  }

  Stream<List<Planejamento>> getPlanejamentos(String orcamentoId, String mes) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('planejamentos')
        .where('mes', isEqualTo: mes)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Planejamento.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> atualizarPlanejamento(
    String orcamentoId,
    Planejamento planejamento,
  ) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('planejamentos')
          .doc(planejamento.id)
          .update(planejamento.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar planejamento: $e');
    }
  }

  Future<void> excluirPlanejamento(
    String orcamentoId,
    String planejamentoId,
  ) async {
    try {
      await _firestore
          .collection('orcamentos')
          .doc(orcamentoId)
          .collection('planejamentos')
          .doc(planejamentoId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir planejamento: $e');
    }
  }

  // CONFIGURAÇÃO DASHBOARD
  Future<void> salvarConfigDashboard(
    String orcamentoId,
    List<ConfigDashboard> configs,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final config in configs) {
        final docRef = _firestore
            .collection('orcamentos')
            .doc(orcamentoId)
            .collection('config_dashboard')
            .doc(config.cardId.toString().split('.').last);

        batch.set(docRef, config.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao salvar configuração do dashboard: $e');
    }
  }

  Stream<List<ConfigDashboard>> getConfigDashboard(String orcamentoId) {
    return _firestore
        .collection('orcamentos')
        .doc(orcamentoId)
        .collection('config_dashboard')
        .orderBy('ordem')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConfigDashboard.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
