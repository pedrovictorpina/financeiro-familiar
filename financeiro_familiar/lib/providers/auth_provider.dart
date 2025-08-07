import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Usuario? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  Usuario? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _userData = null;
      }
      
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _userData = await _authService.getUserData(uid);
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados do usuário: $e';
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String nome) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        nome: nome,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserData(Usuario usuario) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.updateUserData(usuario);
      _userData = usuario;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.deleteAccount();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}