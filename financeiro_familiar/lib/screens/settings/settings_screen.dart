import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/formatters.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Consumer3<AuthProvider, FinanceProvider, ThemeProvider>(
        builder: (context, authProvider, financeProvider, themeProvider, child) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    authProvider.userData?.nome.substring(0, 1).toUpperCase() ?? 'U',
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

  Widget _buildBudgetSection(BuildContext context, FinanceProvider financeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orçamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (financeProvider.orcamentoAtual != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(financeProvider.orcamentoAtual!.nome),
                subtitle: Text(
                  'Criado em ${Formatters.formatDate(financeProvider.orcamentoAtual!.dataCriacao)}',
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

  Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aparência',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildDataSection(BuildContext context, FinanceProvider financeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              title: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info),
              title: const Text('Versão'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarSobre(),
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
    // TODO: Implementar edição de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _gerenciarOrcamento(FinanceProvider financeProvider) {
    // TODO: Implementar gerenciamento de orçamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _gerenciarCategorias() {
    // TODO: Implementar gerenciamento de categorias
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _gerenciarContas() {
    // TODO: Implementar gerenciamento de contas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _gerenciarCartoes() {
    // TODO: Implementar gerenciamento de cartões
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
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

  void _configurarDashboard() {
    // TODO: Implementar configuração do dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _fazerBackup() {
    // TODO: Implementar backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _restaurarBackup() {
    // TODO: Implementar restauração
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _exportarDados() {
    // TODO: Implementar exportação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sincronizar: $e')),
        );
      }
    }
  }

  void _alterarSenha() {
    // TODO: Implementar alteração de senha
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _compartilharOrcamento() {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
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
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  void _mostrarPrivacidade() {
    // TODO: Implementar política de privacidade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _mostrarTermos() {
    // TODO: Implementar termos de uso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _mostrarAjuda() {
    // TODO: Implementar ajuda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }
}