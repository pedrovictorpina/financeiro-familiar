import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/cartao.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Configurações gerais
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Inicializar o plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Ação quando o usuário toca na notificação
    if (kDebugMode) {
      print('Notificação tocada: ${notificationResponse.payload}');
    }
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true; // Para web e outras plataformas
  }

  Future<void> scheduleCardPaymentReminder({
    required String cardId,
    required String cardName,
    required int dueDay,
    required int reminderDays,
  }) async {
    if (!_initialized) await initialize();

    // Garantir permissão de notificação antes de agendar
    try {
      await requestPermissions();
    } catch (_) {}

    // Cancelar notificação anterior se existir
    await cancelCardPaymentReminder(cardId);

    // Calcular próxima data de vencimento
    final now = DateTime.now();
    DateTime nextDueDate = DateTime(now.year, now.month, dueDay);

    // Se a data já passou neste mês, agendar para o próximo mês
    if (nextDueDate.isBefore(now)) {
      nextDueDate = DateTime(now.year, now.month + 1, dueDay);
    }

    // Calcular data do lembrete
    final reminderDate = nextDueDate.subtract(Duration(days: reminderDays));

    // Verificar se a data do lembrete não está no passado
    if (reminderDate.isBefore(now)) {
      return; // Não agendar se a data já passou
    }

    // Configurar detalhes da notificação
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: 'Lembretes de pagamento de cartão de crédito',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Agendar notificação com fallback para inexact
    final scheduleTime = tz.TZDateTime.from(reminderDate, tz.local);
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _getNotificationId(cardId),
        'Lembrete de Fatura',
        'A fatura do cartão $cardName vence em $reminderDays ${reminderDays == 1 ? 'dia' : 'dias'}!',
        scheduleTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'card_payment_$cardId',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Falha ao agendar com exatidão: $e. Tentando agendamento inexact.');
      }
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _getNotificationId(cardId),
        'Lembrete de Fatura',
        'A fatura do cartão $cardName vence em $reminderDays ${reminderDays == 1 ? 'dia' : 'dias'}!',
        scheduleTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'card_payment_$cardId',
      );
    }

    if (kDebugMode) {
      print('Notificação agendada para $cardName em $reminderDate');
    }
  }

  Future<void> cancelCardPaymentReminder(String cardId) async {
    await _flutterLocalNotificationsPlugin.cancel(_getNotificationId(cardId));
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleCardReminders({
    required List<Cartao> cartoes,
    required int reminderDays,
  }) async {
    for (final cartao in cartoes) {
      await scheduleCardPaymentReminder(
        cardId: cartao.id,
        cardName: cartao.nome,
        dueDay: cartao.vencimentoDia,
        reminderDays: reminderDays,
      );
    }
  }

  int _getNotificationId(String cardId) {
    // Gerar um ID único baseado no ID do cartão
    return cardId.hashCode;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: 'Teste de notificação',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Teste de Notificação',
      'Esta é uma notificação de teste do Financeiro Familiar',
      platformChannelSpecifics,
      payload: 'test_notification',
    );
  }

  Future<void> scheduleDebugNotificationIn(Duration delay) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: 'Notificação de debug agendada',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final scheduled = tz.TZDateTime.now(tz.local).add(delay);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999001, // ID fixo para debug
        'Lembrete (debug) agendado',
        'Este é um lembrete agendado para testes (${delay.inSeconds}s).',
        scheduled,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'debug_scheduled',
      );
      if (kDebugMode) {
        print('✓ Debug notification agendada EXATA para: $scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao agendar exato (debug): $e. Reagendando como inexact.');
      }
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          999001,
          'Lembrete (debug) agendado',
          'Este é um lembrete agendado para testes (${delay.inSeconds}s). [INEXATO]',
          scheduled,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'debug_scheduled',
        );
        if (kDebugMode) {
          print('✓ Debug notification reagendada INEXATA para: $scheduled');
        }
      } catch (e2) {
        if (kDebugMode) {
          print('❌ Falha total no agendamento de debug: $e2');
        }
        rethrow;
      }
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      // Tenta verificar se alarmes exatos estão permitidos
      // Se não houver erro ao agendar, significa que estão permitidos
      final testTime = tz.TZDateTime.now(tz.local).add(const Duration(milliseconds: 100));
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // ID temporário para teste
        'Teste de permissão',
        'Teste',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      // Cancelar imediatamente
      await _flutterLocalNotificationsPlugin.cancel(999999);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Alarmes exatos não permitidos: $e');
      }
      return false;
    }
  }

  Future<void> showSchedulePermissionDialog() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: 'Informação sobre permissões',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      999998,
      'Permissão necessária',
      'Para notificações precisas, permita "Alarmes e lembretes" nas configurações do app.',
      platformChannelSpecifics,
    );
  }
}
