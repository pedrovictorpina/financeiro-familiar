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
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

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

    // Agendar notificação
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _getNotificationId(cardId),
      'Lembrete de Fatura',
      'A fatura do cartão $cardName vence em $reminderDays ${reminderDays == 1 ? 'dia' : 'dias'}!',
      tz.TZDateTime.from(reminderDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'card_payment_$cardId',
    );

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
}