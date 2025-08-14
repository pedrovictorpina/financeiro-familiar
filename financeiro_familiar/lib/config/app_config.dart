class AppConfig {
  // Configurações do GitHub para verificação de atualizações
  static const String githubOwner =
      'pedrovictorpina'; // ⚠️ USUÁRIO DO GITHUB DEFINIDO
  static const String githubRepo =
      'financeiro-familiar'; // ⚠️ NOME DO REPOSITÓRIO

  // URLs da API do GitHub
  static const String githubApiUrl = 'https://api.github.com/repos';
  static String get latestReleaseUrl =>
      '$githubApiUrl/$githubOwner/$githubRepo/releases/latest';
  static String get releasesUrl =>
      '$githubApiUrl/$githubOwner/$githubRepo/releases';

  // Configurações de atualização
  static const bool enableAutoUpdateCheck = true;
  static const Duration updateCheckInterval = Duration(hours: 24);

  // Configurações de download
  static const int downloadTimeoutSeconds = 300; // 5 minutos
  static const String apkFileName = 'financeiro-familiar.apk';

  // Mensagens
  static const String updateAvailableTitle = 'Atualização Disponível';
  static const String updateAvailableMessage =
      'Uma nova versão do aplicativo está disponível!';
  static const String appUpToDateTitle = 'App Atualizado! 🎉';
  static const String appUpToDateMessage =
      'Você está usando a versão mais recente do aplicativo.';
  static const String downloadingMessage = 'Baixando atualização...';
  static const String installingMessage = 'Instalando atualização...';

  // Validação de configuração
  static bool get isConfigured {
    // Considera válido quando o usuário do GitHub foi preenchido e ambos não estão vazios
    return githubOwner.isNotEmpty && githubRepo.isNotEmpty;
  }

  static String get configurationError {
    if (!isConfigured) {
      return 'Configure o githubOwner e githubRepo em lib/config/app_config.dart';
    }
    return '';
  }
}
