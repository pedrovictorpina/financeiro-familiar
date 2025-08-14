import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? actionType;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.actionType,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? actionType,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionType: actionType ?? this.actionType,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionType': actionType,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      actionType: json['actionType'],
      data: json['data'],
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  static const String _notificationsKey = 'app_notifications';

  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  bool get hasUnread => unreadCount > 0;

  NotificationsProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications = decoded
            .map((item) => AppNotification.fromJson(item))
            .toList();

        // Ordenar por data de criação (mais recentes primeiro)
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Erro ao salvar notificações: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String? actionType,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      actionType: actionType,
      data: data,
    );

    _notifications.insert(0, notification);

    // Manter apenas as últimas 50 notificações
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> removeNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Métodos para adicionar tipos específicos de notificações
  Future<void> addTransactionNotification(
    String type,
    double amount,
    String description,
  ) async {
    final isIncome = type == 'receita';
    await addNotification(
      title: isIncome ? 'Nova Receita' : 'Nova Despesa',
      message:
          '${isIncome ? "Receita" : "Despesa"} de R\$ ${amount.toStringAsFixed(2)} - $description',
      actionType: 'transaction',
      data: {'type': type, 'amount': amount, 'description': description},
    );
  }

  Future<void> addCardPaymentReminder(String cardName, int daysUntilDue) async {
    await addNotification(
      title: 'Lembrete de Fatura',
      message:
          'A fatura do cartão $cardName vence em $daysUntilDue ${daysUntilDue == 1 ? "dia" : "dias"}!',
      actionType: 'card_reminder',
      data: {'cardName': cardName, 'daysUntilDue': daysUntilDue},
    );
  }

  Future<void> addBudgetAlert(
    String categoryName,
    double spent,
    double budget,
  ) async {
    final percentage = (spent / budget * 100).round();
    await addNotification(
      title: 'Alerta de Orçamento',
      message:
          'Você gastou $percentage% do orçamento da categoria $categoryName',
      actionType: 'budget_alert',
      data: {'categoryName': categoryName, 'spent': spent, 'budget': budget},
    );
  }
}
