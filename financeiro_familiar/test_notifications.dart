import 'package:flutter/material.dart';
import 'package:financeiro_familiar/services/notification_service.dart';
import 'package:financeiro_familiar/models/cartao.dart';

/// Script de teste para notificações
class NotificationTest {
  static Future<void> runTests() async {
    final notificationService = NotificationService();
    
    print('🔥 Iniciando testes de notificação...\n');
    
    // Teste 1: Inicialização
    await _testInitialization(notificationService);
    
    // Teste 2: Permissões
    await _testPermissions(notificationService);
    
    // Teste 3: Notificação de teste
    await _testBasicNotification(notificationService);
    
    // Teste 4: Notificação agendada
    await _testScheduledNotification(notificationService);
    
    // Teste 5: Verificar notificações pendentes
    await _testPendingNotifications(notificationService);
    
    print('\n✅ Testes de notificação concluídos!');
  }
  
  static Future<void> _testInitialization(NotificationService service) async {
    print('📱 Teste 1: Inicialização do serviço de notificação');
    try {
      await service.initialize();
      print('✅ Serviço inicializado com sucesso\n');
    } catch (e) {
      print('❌ Erro na inicialização: $e\n');
    }
  }
  
  static Future<void> _testPermissions(NotificationService service) async {
    print('🔐 Teste 2: Verificação de permissões');
    try {
      final granted = await service.requestPermissions();
      print('Permissões concedidas: $granted');
      print(granted ? '✅ Permissões OK\n' : '⚠️ Permissões negadas\n');
    } catch (e) {
      print('❌ Erro ao verificar permissões: $e\n');
    }
  }
  
  static Future<void> _testBasicNotification(NotificationService service) async {
    print('📲 Teste 3: Notificação básica (imediata)');
    try {
      await service.showTestNotification();
      print('✅ Notificação de teste enviada\n');
    } catch (e) {
      print('❌ Erro ao enviar notificação de teste: $e\n');
    }
  }
  
  static Future<void> _testScheduledNotification(NotificationService service) async {
    print('⏰ Teste 4: Notificação agendada');
    try {
      // Criar um cartão de teste
      final cartaoTeste = Cartao(
        id: 'test_card_001',
        nome: 'Cartão de Teste',
        bandeira: 'visa',
        vencimentoDia: DateTime.now().add(const Duration(days: 5)).day,
        limite: 1000.0,
        faturaAtual: 250.0,
        userId: 'test_user',
      );
      
      await service.scheduleCardPaymentReminder(
        cardId: cartaoTeste.id,
        cardName: cartaoTeste.nome,
        dueDay: cartaoTeste.vencimentoDia,
        reminderDays: 2,
      );
      
      print('✅ Notificação agendada para cartão: ${cartaoTeste.nome}');
      print('📅 Vencimento dia: ${cartaoTeste.vencimentoDia}');
      print('⏱️ Lembrete: 2 dias antes\n');
    } catch (e) {
      print('❌ Erro ao agendar notificação: $e\n');
    }
  }
  
  static Future<void> _testPendingNotifications(NotificationService service) async {
    print('📋 Teste 5: Verificar notificações pendentes');
    try {
      final pending = await service.getPendingNotifications();
      print('Notificações pendentes: ${pending.length}');
      
      for (final notification in pending) {
        print('  - ID: ${notification.id}');
        print('    Título: ${notification.title}');
        print('    Corpo: ${notification.body}');
        print('    Payload: ${notification.payload}');
      }
      
      print(pending.isEmpty ? '⚠️ Nenhuma notificação pendente\n' : '✅ Notificações listadas\n');
    } catch (e) {
      print('❌ Erro ao verificar pendentes: $e\n');
    }
  }
  
  static Future<void> cancelAllTests(NotificationService service) async {
    print('🗑️ Cancelando todas as notificações de teste...');
    try {
      await service.cancelAllNotifications();
      print('✅ Notificações canceladas\n');
    } catch (e) {
      print('❌ Erro ao cancelar: $e\n');
    }
  }
}