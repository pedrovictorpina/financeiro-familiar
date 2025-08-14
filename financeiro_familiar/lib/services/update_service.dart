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
      final response = await http
          .get(
            Uri.parse(AppConfig.latestReleaseUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestVersion = releaseData['tag_name'].toString().replaceAll(
          'v',
          '',
        );

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
        } else {
          return {
            'hasUpdate': false,
            'currentVersion': currentVersion,
            'latestVersion': latestVersion,
            'releaseNotes': releaseData['body'] ?? '',
            'releaseUrl': releaseData['html_url'],
          };
        }
      }

      return {'hasUpdate': false, 'currentVersion': currentVersion};
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

  static Future<void> showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Row(
            children: [
              Icon(Icons.system_update, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                AppConfig.updateAvailableTitle,
                style: TextStyle(color: cs.onSurface),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nova versão ${updateInfo['latestVersion']} disponível!\nVersão atual: ${updateInfo['currentVersion']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Novidades:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    updateInfo['releaseNotes'] ?? 'Sem descrição disponível.',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Mais Tarde', style: TextStyle(color: cs.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openReleaseInBrowser(updateInfo['releaseUrl']);
              },
              child: Text('Ver no GitHub', style: TextStyle(color: cs.primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              onPressed: updateInfo['downloadUrl'] != null
                  ? () {
                      Navigator.of(context).pop();
                      downloadAndInstallUpdate(
                        context,
                        updateInfo['downloadUrl'],
                      );
                    }
                  : null,
              child: const Text('Baixar e Instalar'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showUpToDateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          title: Row(
            children: [
              Icon(Icons.verified, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                AppConfig.appUpToDateTitle,
                style: TextStyle(color: cs.onSurface),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppConfig.appUpToDateMessage}\nVersão atual: ${updateInfo['currentVersion']}',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (updateInfo['releaseNotes'] != null &&
                    (updateInfo['releaseNotes'] as String)
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Novidades desta versão:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      updateInfo['releaseNotes'],
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar', style: TextStyle(color: cs.primary)),
            ),
            if (updateInfo['releaseUrl'] != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openReleaseInBrowser(updateInfo['releaseUrl']);
                },
                child: Text(
                  'Ver no GitHub',
                  style: TextStyle(color: cs.primary),
                ),
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

  static Future<void> downloadAndInstallUpdate(
    BuildContext context,
    String downloadUrl,
  ) async {
    try {
      // Verificar permissões
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          if (context.mounted) {
            _showErrorSnackBar(
              context,
              'Permissão para instalar aplicativos negada.',
            );
          }
          return;
        }
      }

      // Mostrar dialog de progresso
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  AppConfig.downloadingMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
          _showErrorSnackBar(
            context,
            'Não foi possível abrir o arquivo APK para instalação.',
          );
        }
      } else if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Download de APK disponível apenas no Android.',
        );
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
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: cs.onError)),
        backgroundColor: cs.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static Future<void> checkForUpdatesOnStartup(BuildContext context) async {
    final updateInfo = await checkForUpdates();

    if (updateInfo != null) {
      // Aguardar um pouco para garantir que a UI esteja pronta
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        if (updateInfo['hasUpdate'] == true) {
          await showUpdateDialog(context, updateInfo);
        } else {
          // Opcional: não mostrar automaticamente ao iniciar; apenas quando usuário tocar em "Verificar Atualizações"
        }
      }
    }
  }

  // Exposição para uso explícito a partir de Configurações
  static Future<void> checkForUpdatesAndNotify(BuildContext context) async {
    final updateInfo = await checkForUpdates();
    if (!context.mounted) return;
    if (updateInfo == null) {
      _showErrorSnackBar(
        context,
        'Não foi possível verificar atualizações agora.',
      );
      return;
    }
    if (updateInfo['hasUpdate'] == true) {
      await showUpdateDialog(context, updateInfo);
    } else {
      await showUpToDateDialog(context, updateInfo);
    }
  }
}
