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

  // Método para atualizar perfil do usuário
  Future<bool> atualizarPerfil(String nome, String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (_userData != null) {
        final usuarioAtualizado = _userData?.copyWith(nome: nome, email: email);

        if (usuarioAtualizado != null) {
          await _authService.updateUserData(usuarioAtualizado);
        }
        _userData = usuarioAtualizado;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método para alterar senha
  Future<bool> alterarSenha(String senhaAtual, String novaSenha) async {
    _setLoading(true);
    _clearError();

    try {
      if (_user != null) {
        // Reautenticar o usuário com a senha atual
        final credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: senhaAtual,
        );

        await _user?.reauthenticateWithCredential(credential);

        // Atualizar a senha
        await _user?.updatePassword(novaSenha);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }
}
