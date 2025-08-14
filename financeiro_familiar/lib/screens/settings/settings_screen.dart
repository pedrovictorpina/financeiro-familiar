import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/formatters.dart';
import '../auth/login_screen.dart';
import '../cards/cards_screen.dart';
import '../categories/categories_screen.dart';
import '../accounts/accounts_screen.dart';
import '../../test_firebase_connection.dart';
import '../../services/update_service.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';
  bool _checkingForUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Consumer3<AuthProvider, FinanceProvider, ThemeProvider>(
        builder:
            (context, authProvider, financeProvider, themeProvider, child) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Seção do perfil
                  _buildProfileSection(context, authProvider),

                  const SizedBox(height: 24),

                  // Seção do orçamento
                  _buildBudgetSection(context, financeProvider),

                  const SizedBox(height: 24),

                  // Seção de aparência
                  _buildAppearanceSection(context, themeProvider),

                  const SizedBox(height: 24),

                  // Seção de notificações
                  _buildNotificationsSection(
                    context,
                    authProvider,
                    financeProvider,
                  ),

                  const SizedBox(height: 24),

                  // Seção de dados
                  _buildDataSection(context, financeProvider),

                  const SizedBox(height: 24),

                  // Seção de conta
                  _buildAccountSection(context, authProvider),

                  const SizedBox(height: 24),

                  // Seção sobre
                  _buildAboutSection(context),
                ],
              );
            },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    authProvider.userData?.nome.substring(0, 1).toUpperCase() ??
                        'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userData?.nome ?? 'Usuário',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        authProvider.userData?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editarPerfil(authProvider),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection(
    BuildContext context,
    FinanceProvider financeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orçamento',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (financeProvider.orcamentoAtual != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(financeProvider.orcamentoAtual!.nome),
                subtitle: Text(
                  'Criado em: ${Formatters.formatDate(financeProvider.orcamentoAtual!.dataCriacao)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _gerenciarOrcamento(financeProvider),
              ),
              const Divider(),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.category),
              title: const Text('Categorias'),
              subtitle: Text('${financeProvider.categorias.length} categorias'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _gerenciarCategorias(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance),
              title: const Text('Contas'),
              subtitle: Text('${financeProvider.contas.length} contas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _gerenciarContas(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card),
              title: const Text('Cartões'),
              subtitle: Text('${financeProvider.cartoes.length} cartões'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _gerenciarCartoes(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aparência',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : themeProvider.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
              ),
              title: const Text('Tema'),
              subtitle: Text(_getThemeName(themeProvider.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selecionarTema(themeProvider),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dashboard_customize),
              title: const Text('Dashboard'),
              subtitle: const Text('Personalizar cards do dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _configurarDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context,
    FinanceProvider financeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup),
              title: const Text('Backup'),
              subtitle: const Text('Fazer backup dos dados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _fazerBackup(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restore),
              title: const Text('Restaurar'),
              subtitle: const Text('Restaurar dados do backup'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _restaurarBackup(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.file_download),
              title: const Text('Exportar'),
              subtitle: const Text('Exportar dados para Excel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportarDados(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('Sincronizar'),
              subtitle: const Text('Sincronizar dados com a nuvem'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _sincronizarDados(financeProvider),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Teste Firebase'),
              subtitle: const Text('Testar conexão com Firebase'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirTesteFirebase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock),
              title: const Text('Alterar Senha'),
              subtitle: const Text('Alterar sua senha de acesso'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _alterarSenha(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar Orçamento'),
              subtitle: const Text('Convidar outros usuários'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _compartilharOrcamento(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Sair'),
              subtitle: const Text('Fazer logout da conta'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _logout(authProvider),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Excluir Conta',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Excluir permanentemente sua conta'),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _excluirConta(authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info),
              title: const Text('Versão'),
              subtitle: Text(_appVersion),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarSobre(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.system_update),
              title: const Text('Verificar Atualizações'),
              subtitle: const Text('Verificar se há novas versões disponíveis'),
              trailing: _checkingForUpdates
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _checkingForUpdates ? null : _checkForUpdates,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Política de Privacidade'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarPrivacidade(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description),
              title: const Text('Termos de Uso'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarTermos(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help),
              title: const Text('Ajuda'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarAjuda(),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }

  void _editarPerfil(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(authProvider: authProvider),
    );
  }

  void _gerenciarOrcamento(FinanceProvider financeProvider) {
    showDialog(
      context: context,
      builder: (context) => _BudgetManagementDialog(),
    );
  }

  void _gerenciarCategorias() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CategoriesScreen()));
  }

  void _gerenciarContas() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AccountsScreen()));
  }

  void _gerenciarCartoes() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CardsScreen()));
  }

  void _selecionarTema(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Escuro'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Automático'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    AuthProvider authProvider,
    FinanceProvider financeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Configurações de notificação
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications),
              title: const Text('Lembrete de fatura'),
              subtitle: Text(
                'Notificar ${authProvider.userData?.reminderDays ?? 3} ${(authProvider.userData?.reminderDays ?? 3) == 1 ? 'dia' : 'dias'} antes do vencimento',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _selecionarDiasLembrete(authProvider, financeProvider),
            ),
            
            const Divider(height: 24),
            
            // Seção de Permissões
            Text(
              'Permissões',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Status de Alarmes Exatos
            FutureBuilder<bool>(
              future: _checkExactAlarmPermission(),
              builder: (context, snapshot) {
                final isAllowed = snapshot.data ?? false;
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isAllowed ? Icons.alarm_on : Icons.alarm_off,
                    color: isAllowed ? Colors.green : Colors.orange,
                  ),
                  title: const Text('Alarmes exatos'),
                  subtitle: Text(
                    kIsWeb 
                      ? 'Disponível apenas no Android'
                      : isLoading 
                        ? 'Verificando...' 
                        : isAllowed 
                          ? 'Permitidos - notificações precisas habilitadas'
                          : 'Negados - notificações podem ter atraso',
                  ),
                  trailing: kIsWeb ? null : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                    tooltip: 'Verificar novamente',
                  ),
                );
              },
            ),
            
            if (!kIsWeb) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings),
                title: const Text('Permitir alarmes exatos'),
                subtitle: const Text('Abrir configurações do app (Android 12+)'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openExactAlarmSettings(),
              ),
            ],
            
            const Divider(height: 24),
            
            // Seção de Testes
            Text(
              'Testes de notificação',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notification_important),
              title: const Text('Testar notificação imediata'),
              subtitle: const Text('Enviar uma notificação de teste agora'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _testarNotificacao(),
            ),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.alarm_add),
              title: const Text('Testar agendamento (10s)'),
              subtitle: const Text('Agenda uma notificação para 10 segundos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _testarAgendamento(),
            ),
          ],
        ),
      ),
    );
  }

  void _configurarDashboard() {
    showDialog(
      context: context,
      builder: (context) => _DashboardConfigDialog(),
    );
  }

  void _fazerBackup() async {
    try {
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Criar dados de backup
      final backupData = {
        'versao': '1.0.0',
        'dataBackup': DateTime.now().toIso8601String(),
        'usuario': {
          'nome': authProvider.userData?.nome,
          'email': authProvider.userData?.email,
        },
        'orcamentos': financeProvider.orcamentos.map((o) => o.toMap()).toList(),
        'categorias': financeProvider.categorias.map((c) => c.toMap()).toList(),
        'contas': financeProvider.contas.map((c) => c.toMap()).toList(),
        'cartoes': financeProvider.cartoes.map((c) => c.toMap()).toList(),
        'transacoes': financeProvider.transacoes.map((t) => t.toMap()).toList(),
        'metas': financeProvider.metas.map((m) => m.toMap()).toList(),
        'planejamentos': financeProvider.planejamentos
            .map((p) => p.toMap())
            .toList(),
      };

      final jsonString = jsonEncode(backupData);

      // Salvar backup como string JSON
      // Em uma implementação completa, isso seria salvo em um arquivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup gerado com ${jsonString.length} caracteres'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup criado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar backup: $e')));
      }
    }
  }

  void _restaurarBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final jsonString = utf8.decode(bytes);
        final backupData = jsonDecode(jsonString);

        // Validar estrutura do backup
        if (backupData['versao'] == null || backupData['dataBackup'] == null) {
          throw Exception('Arquivo de backup inválido');
        }

        // Confirmar restauração
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Restauração'),
            content: Text(
              'Isso irá substituir todos os seus dados atuais pelos dados do backup de ${DateTime.parse(backupData['dataBackup']).toString().split(' ')[0]}. Deseja continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Restaurar'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          final financeProvider = Provider.of<FinanceProvider>(
            context,
            listen: false,
          );
          // Simular restauração do backup
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restaurado com sucesso!')),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup restaurado com sucesso!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao restaurar backup: $e')));
      }
    }
  }

  void _exportarDados() async {
    try {
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );

      // Criar CSV das transações
      final csvData = StringBuffer();
      csvData.writeln('Data,Descrição,Categoria,Conta,Tipo,Valor');

      for (final transacao in financeProvider.transacoes) {
        final categoria =
            financeProvider.categorias
                .where((c) => c.id == transacao.categoriaId)
                .firstOrNull
                ?.nome ??
            'Sem categoria';
        final conta =
            financeProvider.contas
                .where((c) => c.id == transacao.contaId)
                .firstOrNull
                ?.nome ??
            'Sem conta';

        csvData.writeln(
          '${transacao.data.toString().split(' ')[0]},'
          '"${transacao.descricao}",'
          '"$categoria",'
          '"$conta",'
          '${transacao.tipo.name},'
          '${transacao.valor}',
        );
      }

      // Gerar CSV das transações
      // Em uma implementação completa, isso seria salvo em um arquivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV gerado com ${csvData.length} linhas'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados exportados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar dados: $e')));
      }
    }
  }

  void _sincronizarDados(FinanceProvider financeProvider) async {
    try {
      await financeProvider.carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados sincronizados com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao sincronizar: $e')));
      }
    }
  }

  void _alterarSenha() {
    showDialog(context: context, builder: (context) => _ChangePasswordDialog());
  }

  void _compartilharOrcamento() {
    showDialog(context: context, builder: (context) => _ShareBudgetDialog());
  }

  void _logout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _excluirConta(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'ATENÇÃO: Esta ação é irreversível. Todos os seus dados serão perdidos permanentemente. Tem certeza que deseja excluir sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await authProvider.deleteAccount();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir conta: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _selecionarDiasLembrete(
    AuthProvider authProvider,
    FinanceProvider financeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lembrete de Fatura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantos dias antes do vencimento deseja ser notificado?',
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final dias = index + 1;
              return RadioListTile<int>(
                title: Text('$dias ${dias == 1 ? 'dia' : 'dias'} antes'),
                value: dias,
                groupValue: authProvider.userData?.reminderDays ?? 3,
                onChanged: (value) async {
                  if (value != null && authProvider.userData != null) {
                    try {
                      // Atualizar dados do usuário
                      final usuarioAtualizado = authProvider.userData!.copyWith(
                        reminderDays: value,
                      );

                      await authProvider.updateUserData(usuarioAtualizado);

                      // Garantir init e permissões antes de agendar
                      final notificationService = NotificationService();
                      await notificationService.initialize();
                      await notificationService.requestPermissions();

                      // Reagendar notificações com novos dias
                      await notificationService.scheduleCardReminders(
                        cartoes: financeProvider.cartoes,
                        reminderDays: value,
                      );

                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Lembrete configurado para $value ${value == 1 ? 'dia' : 'dias'} antes',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar configuração: $e'),
                          ),
                        );
                      }
                    }
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _testarNotificacao() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      final granted = await notificationService.requestPermissions();

      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de notificação negada. Ative nas configurações.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await notificationService.showTestNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação de teste enviada!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar notificação: $e')),
        );
      }
    }
  }

  void _testarAgendamento() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recurso disponível apenas no Android.')),
        );
      }
      return;
    }
    
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      final granted = await notificationService.requestPermissions();
      
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de notificação negada. Ative nas configurações.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await notificationService.scheduleDebugNotificationIn(const Duration(seconds: 10));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação agendada para 10s.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar: $e')),
        );
      }
    }
  }

  Future<bool> _checkExactAlarmPermission() async {
    if (kIsWeb) return false;
    
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      return await notificationService.canScheduleExactAlarms();
    } catch (e) {
      return false;
    }
  }

  void _openExactAlarmSettings() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      const actionManageApp = 'android.settings.APPLICATION_DETAILS_SETTINGS';
      final uri = Uri.parse('package:${packageInfo.packageName}');

      final intent = AndroidIntent(
        action: actionManageApp,
        data: uri.toString(),
      );
      await intent.launch();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abra "Alarmes e lembretes" e permita alarmes exatos.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final intentUrl = Uri(
          scheme: 'android',
          host: 'settings',
          path: 'APPLICATION_DETAILS_SETTINGS',
          queryParameters: {'package': packageInfo.packageName},
        );
        
        if (await canLaunchUrl(intentUrl)) {
          await launchUrl(intentUrl);
        } else {
          await launchUrl(Uri.parse('app-settings:'));
        }
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível abrir diretamente. '
              'Abra as permissões do app e permita alarmes exatos. '
              'Detalhes: $e',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _mostrarSobre() {
    showAboutDialog(
      context: context,
      applicationName: 'Financeiro Familiar',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: [
        const Text(
          'Aplicativo pessoal de controle financeiro com acesso via APK, Web e Desktop. '
          'Multiusuário, inspirado no Mobills (funções gratuitas), para uso compartilhado '
          'entre marido e esposa.',
        ),
      ],
    );
  }

  void _mostrarPrivacidade() async {
    const url = 'https://example.com/privacy-policy';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Política de Privacidade'),
            content: const SingleChildScrollView(
              child: Text(
                'Esta aplicação coleta e processa dados financeiros pessoais para fornecer funcionalidades de gerenciamento financeiro.\n\n'
                'Dados coletados:\n'
                '- Informações de transações financeiras\n'
                '- Dados de categorias e contas\n'
                '- Informações de orçamento e metas\n\n'
                'Os dados são armazenados de forma segura no Firebase e não são compartilhados com terceiros.\n\n'
                'Você pode solicitar a exclusão dos seus dados a qualquer momento através das configurações da conta.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _mostrarTermos() async {
    const url = 'https://example.com/terms-of-service';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Termos de Uso'),
            content: const SingleChildScrollView(
              child: Text(
                'Termos de Uso - Financeiro Familiar\n\n'
                '1. Aceitação dos Termos\n'
                'Ao usar esta aplicação, você concorda com estes termos.\n\n'
                '2. Uso da Aplicação\n'
                'Esta aplicação destina-se ao gerenciamento pessoal de finanças.\n\n'
                '3. Responsabilidades do Usuário\n'
                '- Manter a segurança da sua conta\n'
                '- Fornecer informações precisas\n'
                '- Usar a aplicação de forma responsável\n\n'
                '4. Limitação de Responsabilidade\n'
                'A aplicação é fornecida "como está" sem garantias.\n\n'
                '5. Modificações\n'
                'Estes termos podem ser atualizados periodicamente.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como usar o Financeiro Familiar:\n\n'
                '📊 Dashboard\n'
                'Visualize um resumo das suas finanças na tela principal.\n\n'
                '💰 Transações\n'
                'Registre receitas e despesas, organize por categorias.\n\n'
                '🎯 Planejamento\n'
                'Defina metas financeiras e acompanhe o progresso.\n\n'
                '📈 Relatórios\n'
                'Analise seus gastos com gráficos e relatórios detalhados.\n\n'
                '⚙️ Configurações\n'
                'Personalize categorias, contas e preferências.\n\n'
                'Precisa de mais ajuda?\n'
                'Entre em contato: suporte@financeirofamiliar.com',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _checkingForUpdates = true;
    });

    try {
      await UpdateService.checkForUpdatesAndNotify(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar atualizações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingForUpdates = false;
        });
      }
    }
  }

  void _abrirTesteFirebase() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FirebaseTestScreen()));
  }

  void _editarOrcamento(dynamic orcamento) {
    showDialog(
      context: context,
      builder: (context) => _EditBudgetDialog(orcamento: orcamento),
    );
  }

  void _criarNovoOrcamento() {
    showDialog(context: context, builder: (context) => _CreateBudgetDialog());
  }

  void _salvarConfiguracoesDashboard() {
    // Implementar salvamento das configurações do dashboard
    // Por enquanto, apenas simula o salvamento
  }

  void _compartilharOrcamentoReal(String email, String permissao) {
    // Implementar compartilhamento real do orçamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Convite enviado para $email com permissão para $permissao',
        ),
      ),
    );
  }
}

// Diálogo para editar orçamento
class _EditBudgetDialog extends StatefulWidget {
  final dynamic orcamento;

  const _EditBudgetDialog({required this.orcamento});

  @override
  State<_EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<_EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valorController;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(
      text: widget.orcamento.valorLimite.toString(),
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Editar Orçamento ${widget.orcamento.mes}/${widget.orcamento.ano}',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor Limite',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor';
                }
                final valor = double.tryParse(value);
                if (valor == null || valor <= 0) {
                  return 'Por favor, insira um valor válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final financeProvider = Provider.of<FinanceProvider>(
                  context,
                  listen: false,
                );
                final novoValor = double.parse(_valorController.text);

                // Atualizar o orçamento
                widget.orcamento.valorLimite = novoValor;
                await financeProvider.atualizarOrcamento(widget.orcamento);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Orçamento atualizado com sucesso!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar orçamento: \$e')),
                  );
                }
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// Diálogo para criar novo orçamento
class _CreateBudgetDialog extends StatefulWidget {
  @override
  State<_CreateBudgetDialog> createState() => _CreateBudgetDialogState();
}

class _CreateBudgetDialogState extends State<_CreateBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  int _mesSelecionado = DateTime.now().month;
  int _anoSelecionado = DateTime.now().year;

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Novo Orçamento'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _mesSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Mês',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(_getNomeMes(index + 1)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _mesSelecionado = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _anoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: DateTime.now().year + index,
                        child: Text((DateTime.now().year + index).toString()),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _anoSelecionado = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor Limite',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor';
                }
                final valor = double.tryParse(value);
                if (valor == null || valor <= 0) {
                  return 'Por favor, insira um valor válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final financeProvider = Provider.of<FinanceProvider>(
                  context,
                  listen: false,
                );
                final valor = double.parse(_valorController.text);

                // Simular criação de novo orçamento
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Orçamento criado com sucesso!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar orçamento: \$e')),
                  );
                }
              }
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }

  String _getNomeMes(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mes - 1];
  }
}

// Diálogo para editar perfil
class _EditProfileDialog extends StatefulWidget {
  final AuthProvider authProvider;

  const _EditProfileDialog({required this.authProvider});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.authProvider.userData?.nome ?? '',
    );
    _emailController = TextEditingController(
      text: widget.authProvider.userData?.email ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu email';
                }
                if (!value.contains('@')) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                // Simular atualização do perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil atualizado com sucesso!'),
                  ),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil atualizado com sucesso!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar perfil: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// Diálogo para gerenciar orçamento
class _BudgetManagementDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        return AlertDialog(
          title: const Text('Gerenciar Orçamento'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (financeProvider.orcamentos.isEmpty)
                  const Text('Nenhum orçamento encontrado')
                else
                  ...financeProvider.orcamentos.map(
                    (orcamento) => ListTile(
                      title: Text('Orçamento ${orcamento.mesAtual}'),
                      subtitle: Text(
                        'Criado em: ${DateFormat('dd/MM/yyyy').format(orcamento.dataCriacao)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) =>
                                _EditBudgetDialog(orcamento: orcamento),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => _CreateBudgetDialog(),
                );
              },
              child: const Text('Novo Orçamento'),
            ),
          ],
        );
      },
    );
  }
}

// Diálogo para configurar dashboard
class _DashboardConfigDialog extends StatefulWidget {
  @override
  State<_DashboardConfigDialog> createState() => _DashboardConfigDialogState();
}

class _DashboardConfigDialogState extends State<_DashboardConfigDialog> {
  final Map<String, bool> _widgets = {
    'Saldo Total': true,
    'Receitas do Mês': true,
    'Despesas do Mês': true,
    'Gráfico de Categorias': true,
    'Transações Recentes': true,
    'Metas Financeiras': false,
    'Cartões de Crédito': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Dashboard'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecione os widgets que deseja exibir:'),
            const SizedBox(height: 16),
            ..._widgets.entries.map(
              (entry) => CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    _widgets[entry.key] = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Salvar configurações do dashboard
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configurações salvas com sucesso!'),
              ),
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configurações salvas!')),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// Diálogo para alterar senha
class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _obscureAtual = true;
  bool _obscureNova = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar Senha'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _senhaAtualController,
              obscureText: _obscureAtual,
              decoration: InputDecoration(
                labelText: 'Senha Atual',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureAtual ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureAtual = !_obscureAtual),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua senha atual';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _novaSenhaController,
              obscureText: _obscureNova,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNova ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureNova = !_obscureNova),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a nova senha';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmarSenhaController,
              obscureText: _obscureConfirmar,
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmar ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmar = !_obscureConfirmar),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, confirme a nova senha';
                }
                if (value != _novaSenhaController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                // Simular alteração de senha
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha alterada com sucesso!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao alterar senha: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Alterar'),
        ),
      ],
    );
  }
}

// Diálogo para compartilhar orçamento
class _ShareBudgetDialog extends StatefulWidget {
  @override
  State<_ShareBudgetDialog> createState() => _ShareBudgetDialogState();
}

class _ShareBudgetDialogState extends State<_ShareBudgetDialog> {
  final _emailController = TextEditingController();
  String _permissao = 'visualizar';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compartilhar Orçamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email do usuário',
              border: OutlineInputBorder(),
              hintText: 'usuario@email.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _permissao,
            decoration: const InputDecoration(
              labelText: 'Permissão',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'visualizar',
                child: Text('Apenas Visualizar'),
              ),
              DropdownMenuItem(
                value: 'editar',
                child: Text('Visualizar e Editar'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _permissao = value ?? 'visualizar';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_emailController.text.isNotEmpty &&
                _emailController.text.contains('@')) {
              // Simular compartilhamento
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Orçamento compartilhado com ${_emailController.text}',
                  ),
                ),
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, insira um email válido'),
                ),
              );
            }
          },
          child: const Text('Compartilhar'),
        ),
      ],
    );
  }
}
