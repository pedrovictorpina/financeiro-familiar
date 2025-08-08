import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

class UpdateService {
  
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // Verificar se a configuração está correta
      if (!AppConfig.isConfigured) {
        debugPrint('UpdateService: ${AppConfig.configurationError}');
        return null;
      }
      
      // Obter versão atual do app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Consultar última release no GitHub
      final response = await http.get(
        Uri.parse(AppConfig.latestReleaseUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestVersion = releaseData['tag_name'].toString().replaceAll('v', '');
        
        // Comparar versões
        if (_isNewerVersion(currentVersion, latestVersion)) {
          return {
            'hasUpdate': true,
            'currentVersion': currentVersion,
            'latestVersion': latestVersion,
            'releaseNotes': releaseData['body'] ?? '',
            'downloadUrl': _getApkDownloadUrl(releaseData['assets']),
            'releaseUrl': releaseData['html_url'],
          };
        }
      }
      
      return {
        'hasUpdate': false,
        'currentVersion': currentVersion,
      };
    } catch (e) {
      debugPrint('Erro ao verificar atualizações: $e');
      return null;
    }
  }
  
  static String? _getApkDownloadUrl(List<dynamic> assets) {
    for (var asset in assets) {
      if (asset['name'].toString().endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    return null;
  }
  
  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    
    return false;
  }
  
  static Future<void> showUpdateDialog(BuildContext context, Map<String, dynamic> updateInfo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Colors.blue),
              SizedBox(width: 8),
              Text('Atualização Disponível'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nova versão ${updateInfo['latestVersion']} disponível!\n'
                  'Versão atual: ${updateInfo['currentVersion']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Novidades:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    updateInfo['releaseNotes'] ?? 'Sem descrição disponível.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mais Tarde'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openReleaseInBrowser(updateInfo['releaseUrl']);
              },
              child: const Text('Ver no GitHub'),
            ),
            ElevatedButton(
              onPressed: updateInfo['downloadUrl'] != null
                  ? () {
                      Navigator.of(context).pop();
                      downloadAndInstallUpdate(context, updateInfo['downloadUrl']);
                    }
                  : null,
              child: const Text('Baixar e Instalar'),
            ),
          ],
        );
      },
    );
  }
  
  static Future<void> _openReleaseInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  static Future<void> downloadAndInstallUpdate(BuildContext context, String downloadUrl) async {
    try {
      // Verificar permissões
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          if (context.mounted) {
            _showErrorSnackBar(context, 'Permissão para instalar aplicativos negada.');
          }
          return;
        }
      }
      
      // Mostrar dialog de progresso
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Baixando atualização...'),
              ],
            ),
          ),
        );
      }
      
      // Baixar o APK
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/update.apk';
      
      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
          }
        },
      );
      
      // Fechar dialog de progresso
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Abrir o APK para instalação manual
      if (Platform.isAndroid) {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else if (context.mounted) {
          _showErrorSnackBar(context, 'Não foi possível abrir o arquivo APK para instalação.');
        }
      } else if (context.mounted) {
        _showErrorSnackBar(context, 'Download de APK disponível apenas no Android.');
      }
      
    } catch (e) {
      // Fechar dialog de progresso se estiver aberto
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, 'Erro ao baixar atualização: $e');
      }
    }
  }
  
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  static Future<void> checkForUpdatesOnStartup(BuildContext context) async {
    final updateInfo = await checkForUpdates();
    
    if (updateInfo != null && updateInfo['hasUpdate'] == true) {
      // Aguardar um pouco para garantir que a UI esteja pronta
      await Future.delayed(const Duration(seconds: 2));
      
      if (context.mounted) {
        await showUpdateDialog(context, updateInfo);
      }
    }
  }
}