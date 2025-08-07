import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/usuario.dart';
import 'check_database.dart';

class FirebaseConnectionTest {
  static final FirestoreService _firestoreService = FirestoreService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<String> _logs = [];

  static void _log(String message) {
    _logs.add(message);
    debugPrint(message);
  }

  /// Testa a inicialização do Firebase
  static Future<bool> testFirebaseInitialization() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _log('✅ Firebase inicializado com sucesso');
      return true;
    } catch (e) {
      _log('❌ Erro ao inicializar Firebase: $e');
      return false;
    }
  }

  /// Testa a conexão com o Firestore
  static Future<bool> testFirestoreConnection() async {
    try {
      // Tenta fazer uma operação simples no Firestore
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
      });
      
      // Lê o documento para confirmar
      final doc = await _firestore.collection('test').doc('connection').get();
      if (doc.exists) {
        _log('✅ Conexão com Firestore estabelecida');
        
        // Remove o documento de teste
        await _firestore.collection('test').doc('connection').delete();
        return true;
      }
      return false;
    } catch (e) {
      _log('❌ Erro na conexão com Firestore: $e');
      return false;
    }
  }

  /// Testa a autenticação do Firebase
  static Future<bool> testFirebaseAuth() async {
    try {
      // Verifica se o Firebase Auth está funcionando
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email ?? 'Nenhum';
      _log('✅ Firebase Auth disponível. Usuário atual: $userEmail');
      return true;
    } catch (e) {
      _log('❌ Erro no Firebase Auth: $e');
      return false;
    }
  }

  /// Verifica a estrutura das coleções no Firestore
  static Future<void> checkDatabaseStructure() async {
    try {
      _log('\n📊 Verificando estrutura do banco de dados...');
      
      // Verifica coleção de usuários
      final usuarios = await _firestore.collection('usuarios').limit(1).get();
      final usuariosCount = usuarios.docs.length;
      _log('📁 Coleção "usuarios": ${usuarios.docs.isEmpty ? "Vazia" : "$usuariosCount documento(s)"}');
      
      // Verifica coleção de orçamentos
      final orcamentos = await _firestore.collection('orcamentos').limit(1).get();
      final orcamentosCount = orcamentos.docs.length;
      _log('📁 Coleção "orcamentos": ${orcamentos.docs.isEmpty ? "Vazia" : "$orcamentosCount documento(s)"}');
      
      if (orcamentos.docs.isNotEmpty) {
        final orcamentoId = orcamentos.docs.first.id;
        _log('\n🔍 Verificando subcoleções do orçamento: $orcamentoId');
        
        // Verifica subcoleções
        final subcollections = ['transacoes', 'categorias', 'contas', 'cartoes', 'metas', 'planejamentos', 'config_dashboard'];
        
        for (final subcollection in subcollections) {
          try {
            final docs = await _firestore
                .collection('orcamentos')
                .doc(orcamentoId)
                .collection(subcollection)
                .limit(1)
                .get();
            final docsCount = docs.docs.length;
            _log('  📂 $subcollection: ${docs.docs.isEmpty ? "Vazia" : "$docsCount documento(s)"}');
          } catch (e) {
            _log('  ❌ Erro ao verificar $subcollection: $e');
          }
        }
      }
    } catch (e) {
      _log('❌ Erro ao verificar estrutura: $e');
    }
  }

  /// Testa operações CRUD básicas
  static Future<void> testCRUDOperations() async {
    try {
      _log('\n🧪 Testando operações CRUD...');
      
      // Teste de criação de usuário de teste
      final testUser = Usuario(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        nome: 'Usuário Teste',
        email: 'teste@exemplo.com',
        orcamentos: [],
        dataCriacao: DateTime.now(),
      );
      
      // CREATE - Criar usuário
      await _firestore.collection('usuarios').doc(testUser.uid).set(testUser.toMap());
      _log('✅ CREATE: Usuário criado');
      
      // READ - Ler usuário
      final userDoc = await _firestore.collection('usuarios').doc(testUser.uid).get();
      if (userDoc.exists) {
        _log('✅ READ: Usuário lido com sucesso');
      }
      
      // UPDATE - Atualizar usuário
      await _firestore.collection('usuarios').doc(testUser.uid).update({
        'nome': 'Usuário Teste Atualizado',
      });
      _log('✅ UPDATE: Usuário atualizado');
      
      // DELETE - Deletar usuário
      await _firestore.collection('usuarios').doc(testUser.uid).delete();
      _log('✅ DELETE: Usuário deletado');
      
    } catch (e) {
      _log('❌ Erro nas operações CRUD: $e');
    }
  }

  /// Executa todos os testes
  static Future<List<String>> runAllTests() async {
    _logs.clear();
    _log('🚀 Iniciando testes de conexão Firebase...');
    _log('=' * 50);
    
    // Teste 1: Inicialização
    final initSuccess = await testFirebaseInitialization();
    if (!initSuccess) {
      _log('❌ Falha na inicialização. Parando testes.');
      return _logs;
    }
    
    // Teste 2: Conexão Firestore
    final firestoreSuccess = await testFirestoreConnection();
    if (!firestoreSuccess) {
      _log('❌ Falha na conexão Firestore.');
    }
    
    // Teste 3: Firebase Auth
    await testFirebaseAuth();
    
    // Teste 4: Estrutura do banco
    await checkDatabaseStructure();
    
    // Teste 5: Operações CRUD
    await testCRUDOperations();
    
    _log('\n' + '=' * 50);
    _log('🏁 Testes concluídos!');
    
    return List.from(_logs);
  }
}

/// Widget para executar os testes na interface
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isRunning = false;
  bool _isCheckingDatabase = false;
  List<String> _logs = [];

  void _runTests() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    final testLogs = await FirebaseConnectionTest.runAllTests();
    
    setState(() {
      _logs = testLogs;
      _isRunning = false;
    });
  }

  void _checkDatabaseStructure() async {
    setState(() {
      _isCheckingDatabase = true;
      _logs.clear();
    });

    try {
      List<String> logs = [];
      
      logs.add('🔍 Verificando estrutura do banco de dados...');
      logs.add('=' * 50);
      
      // Verificar usuário atual
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        logs.add('👤 Usuário logado: ${user.email}');
        logs.add('🆔 UID: ${user.uid}');
      } else {
        logs.add('❌ Nenhum usuário logado');
        setState(() {
          _logs = logs;
          _isCheckingDatabase = false;
        });
        return;
      }

      // Verificar coleção de usuários
      logs.add('\n📊 Verificando coleções...');
      
      final usuarios = await FirebaseFirestore.instance.collection('usuarios').limit(1).get();
      logs.add('📁 Coleção "usuarios": ${usuarios.docs.isEmpty ? "Vazia" : "${usuarios.docs.length} documento(s)"}');
      
      // Verificar coleção de orçamentos
      final orcamentos = await FirebaseFirestore.instance.collection('orcamentos').limit(1).get();
      logs.add('📁 Coleção "orcamentos": ${orcamentos.docs.isEmpty ? "Vazia" : "${orcamentos.docs.length} documento(s)"}');
      
      if (orcamentos.docs.isNotEmpty) {
        final orcamentoId = orcamentos.docs.first.id;
        logs.add('\n🔍 Verificando subcoleções do orçamento: $orcamentoId');
        
        // Verificar subcoleções
        final subcollections = ['transacoes', 'categorias', 'contas', 'cartoes', 'metas', 'planejamentos', 'config_dashboard'];
        
        for (final subcollection in subcollections) {
          try {
            final docs = await FirebaseFirestore.instance
                .collection('orcamentos')
                .doc(orcamentoId)
                .collection(subcollection)
                .limit(1)
                .get();
            logs.add('  📂 $subcollection: ${docs.docs.isEmpty ? "Vazia" : "${docs.docs.length} documento(s)"}');
          } catch (e) {
            logs.add('  ❌ Erro ao verificar $subcollection: $e');
          }
        }
      }

      // Teste de criação de documento
      logs.add('\n🧪 Testando criação de documento...');
      try {
        await FirebaseFirestore.instance.collection('test').doc('connection_test').set({
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'connected',
          'user': user.uid,
        });
        logs.add('✅ Documento de teste criado com sucesso');
        
        // Remover documento de teste
        await FirebaseFirestore.instance.collection('test').doc('connection_test').delete();
        logs.add('✅ Documento de teste removido');
      } catch (e) {
        logs.add('❌ Erro ao criar documento de teste: $e');
      }

      logs.add('\n' + '=' * 50);
      logs.add('✅ Verificação concluída!');
      
      setState(() {
        _logs = logs;
        _isCheckingDatabase = false;
      });
    } catch (e) {
      setState(() {
        _logs = ['❌ Erro geral: $e'];
        _isCheckingDatabase = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Firebase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: (_isRunning || _isCheckingDatabase) ? null : _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Executando testes...'),
                      ],
                    )
                  : const Text(
                      'Executar Testes Firebase',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (_isRunning || _isCheckingDatabase) ? null : _checkDatabaseStructure,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isCheckingDatabase
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Verificando banco...'),
                      ],
                    )
                  : const Text(
                      'Verificar Estrutura do Banco',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black87,
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Clique no botão para executar os testes',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          Color textColor = Colors.white;
                          
                          if (log.contains('✅')) {
                            textColor = Colors.green;
                          } else if (log.contains('❌')) {
                            textColor = Colors.red;
                          } else if (log.contains('🚀') || log.contains('🏁')) {
                            textColor = Colors.yellow;
                          } else if (log.contains('📊') || log.contains('🔍')) {
                            textColor = Colors.cyan;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}