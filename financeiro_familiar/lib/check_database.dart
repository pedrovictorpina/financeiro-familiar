// Script para verificar estrutura do banco de dados
// Execute este arquivo através da aplicação Flutter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseChecker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> checkDatabaseStructure() async {
    print('🔍 Verificando estrutura do banco de dados...');
    print('=' * 50);

    try {
      // Verificar usuário atual
      final user = _auth.currentUser;
      if (user != null) {
        print('👤 Usuário logado: ${user.email}');
        print('🆔 UID: ${user.uid}');
      } else {
        print('❌ Nenhum usuário logado');
        return;
      }

      // Verificar coleção de usuários
      print('\n📊 Verificando coleções...');
      
      final usuarios = await _firestore.collection('usuarios').limit(1).get();
      print('📁 Coleção "usuarios": ${usuarios.docs.isEmpty ? "Vazia" : "${usuarios.docs.length} documento(s)"}');
      
      // Verificar coleção de orçamentos
      final orcamentos = await _firestore.collection('orcamentos').limit(1).get();
      print('📁 Coleção "orcamentos": ${orcamentos.docs.isEmpty ? "Vazia" : "${orcamentos.docs.length} documento(s)"}');
      
      if (orcamentos.docs.isNotEmpty) {
        final orcamentoId = orcamentos.docs.first.id;
        print('\n🔍 Verificando subcoleções do orçamento: $orcamentoId');
        
        // Verificar subcoleções
        final subcollections = ['transacoes', 'categorias', 'contas', 'cartoes', 'metas', 'planejamentos', 'config_dashboard'];
        
        for (final subcollection in subcollections) {
          try {
            final docs = await _firestore
                .collection('orcamentos')
                .doc(orcamentoId)
                .collection(subcollection)
                .limit(1)
                .get();
            print('  📂 $subcollection: ${docs.docs.isEmpty ? "Vazia" : "${docs.docs.length} documento(s)"}');
          } catch (e) {
            print('  ❌ Erro ao verificar $subcollection: $e');
          }
        }
      }

      // Teste de criação de documento
      print('\n🧪 Testando criação de documento...');
      try {
        await _firestore.collection('test').doc('connection_test').set({
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'connected',
          'user': user?.uid,
        });
        print('✅ Documento de teste criado com sucesso');
        
        // Remover documento de teste
        await _firestore.collection('test').doc('connection_test').delete();
        print('✅ Documento de teste removido');
      } catch (e) {
        print('❌ Erro ao criar documento de teste: $e');
      }

    } catch (e) {
      print('❌ Erro geral: $e');
    }

    print('\n' + '=' * 50);
    print('✅ Verificação concluída!');
  }
}