# Configuração de Atualizações Automáticas via GitHub Releases

Este aplicativo agora suporta atualizações automáticas via GitHub Releases. Siga as instruções abaixo para configurar completamente o sistema.

## 1. Configure o Repository Owner (OBRIGATÓRIO)

Edite o arquivo `lib/config/app_config.dart` e altere:

```dart
static const String githubOwner = 'SEU_USUARIO_GITHUB'; // ⚠️ ALTERE para seu usuário GitHub
static const String githubRepo = 'financeiro-familiar'; // ⚠️ Se o nome do repo for diferente, altere
```

**Exemplo:**
```dart
static const String githubOwner = 'pedrodev'; // Seu username do GitHub
static const String githubRepo = 'financeiro-familiar'; // Nome do seu repositório
```

## 2. Configure Secrets do GitHub (Para assinatura de releases)

No seu repositório GitHub, vá em `Settings > Secrets and variables > Actions` e adicione:

### Secrets necessários:
- `KEYSTORE_BASE64`: Sua keystore convertida para base64
- `KEYSTORE_PASSWORD`: Senha da keystore
- `KEY_PASSWORD`: Senha da chave
- `KEY_ALIAS`: Alias da chave

### Como gerar os secrets:

1. **Criar keystore (se não tiver):**
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Converter keystore para base64:**
```bash
# No Windows (PowerShell):
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File keystore-base64.txt

# No Linux/Mac:
base64 upload-keystore.jks > keystore-base64.txt
```

3. **Adicionar secrets no GitHub:**
- `KEYSTORE_BASE64`: Conteúdo do arquivo `keystore-base64.txt`
- `KEYSTORE_PASSWORD`: Senha que você usou ao criar a keystore
- `KEY_PASSWORD`: Senha da chave (geralmente a mesma da keystore)
- `KEY_ALIAS`: "upload" (ou o alias que você definiu)

## 3. Como funciona o sistema de atualizações

### Automático (no startup do app):
- O app verifica automaticamente se há uma nova versão disponível
- Se houver, mostra um dialog com as novidades
- O usuário pode baixar e instalar a atualização

### Manual (nas configurações):
- O usuário pode verificar manualmente por atualizações
- Acessível através do menu de configurações

### GitHub Actions Workflow:
- A cada tag de versão (ex: `v1.1.0`), o workflow executa automaticamente
- Gera APK e AAB assinados
- Cria um release no GitHub com os arquivos
- O app detecta e oferece a atualização

## 4. Como criar uma nova release

1. **Atualize a versão no `pubspec.yaml`:**
```yaml
version: 1.1.0+2  # Incremente a versão
```

2. **Commit e push das alterações:**
```bash
git add .
git commit -m "chore: bump version to 1.1.0"
git push origin main
```

3. **Crie e push uma tag:**
```bash
git tag v1.1.0
git push origin v1.1.0
```

4. **O GitHub Actions automaticamente:**
- Executa o build
- Gera APK e AAB assinados
- Cria um release público
- Disponibiliza os arquivos para download

## 5. Estrutura dos arquivos de release

O sistema irá gerar:
- `financeiro-familiar-v1.1.0.apk` - Para instalação direta
- `financeiro-familiar-v1.1.0.aab` - Para upload na Play Store

## 6. Permissões necessárias

O app solicita automaticamente as permissões:
- `INTERNET` - Para verificar atualizações
- `REQUEST_INSTALL_PACKAGES` - Para instalar APKs

## 7. Testando o sistema

Para testar se está funcionando:

1. Configure o `githubOwner` corretamente
2. Crie uma tag de teste: `git tag v1.0.1 && git push origin v1.0.1`
3. Verifique se o release foi criado no GitHub
4. Execute o app e veja se detecta a atualização

## Troubleshooting

### "Configuração não está correta"
- Verifique se `githubOwner` foi alterado de `'SEU_USUARIO_GITHUB'`
- Confirme que o nome do repositório está correto

### "Erro ao verificar atualizações"
- Verifique sua conexão com a internet
- Confirme se o repositório é público ou se tem as permissões corretas

### "Não foi possível baixar/instalar"
- Verifique se as permissões foram concedidas
- Certifique-se de que há espaço suficiente no dispositivo
- No Android, habilite "Fontes desconhecidas" se necessário

### "APK não assinado"
- Configure os secrets do GitHub corretamente
- Verifique se a keystore foi convertida para base64 corretamente