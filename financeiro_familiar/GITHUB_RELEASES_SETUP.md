# 📱 Configuração do Sistema de Atualizações via GitHub Releases

Este guia explica como configurar o sistema de atualizações automáticas usando GitHub Releases para distribuir APKs do seu app Flutter.

## 🚀 Configuração Inicial

### 1. Configurar o Repositório GitHub

1. **Crie um repositório no GitHub** (se ainda não tiver):
   ```bash
   # No terminal, dentro da pasta do projeto
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/financeiro-familiar.git
   git push -u origin main
   ```

2. **Configure as informações do repositório** em `lib/config/app_config.dart`:
   ```dart
   static const String githubOwner = 'seu-usuario-github'; // ⚠️ ALTERE AQUI
   static const String githubRepo = 'financeiro-familiar';  // ⚠️ ALTERE AQUI
   ```

### 2. Configurar Assinatura do APK (Recomendado)

1. **Gere uma keystore** (faça isso apenas uma vez):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure o arquivo `android/key.properties`**:
   ```properties
   storePassword=SUA_SENHA_STORE
   keyPassword=SUA_SENHA_KEY
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **Atualize `android/app/build.gradle`**:
   ```gradle
   // Adicione antes de android {
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... outras configurações
       
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       
       buildTypes {
           release {
               signingConfig signingConfigs.release
               // ... outras configurações
           }
       }
   }
   ```

### 3. Configurar Secrets no GitHub

1. **Vá para Settings > Secrets and variables > Actions** no seu repositório
2. **Adicione os seguintes secrets**:
   - `KEYSTORE_BASE64`: Conteúdo da keystore em base64
   - `KEYSTORE_PASSWORD`: Senha da keystore
   - `KEY_ALIAS`: Alias da chave (geralmente "upload")
   - `KEY_PASSWORD`: Senha da chave

   Para gerar o base64 da keystore:
   ```bash
   # Windows
   certutil -encode upload-keystore.jks keystore.base64
   
   # Linux/Mac
   base64 upload-keystore.jks > keystore.base64
   ```

## 🔄 Como Funciona

### Fluxo Automático

1. **Quando você faz push de uma tag** (ex: `v1.0.1`):
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

2. **GitHub Actions automaticamente**:
   - Faz build do APK
   - Cria uma release
   - Anexa o APK à release

3. **No app, quando o usuário abre**:
   - Verifica se há nova versão
   - Mostra dialog de atualização
   - Permite download e instalação automática

### Fluxo Manual

Você também pode disparar o build manualmente:
1. Vá para **Actions** no GitHub
2. Selecione **Build and Release APK**
3. Clique em **Run workflow**

## 📋 Checklist de Configuração

- [ ] Repositório criado no GitHub
- [ ] Código enviado para o repositório
- [ ] `app_config.dart` configurado com seu usuário/repo
- [ ] Keystore gerada e configurada
- [ ] Secrets configurados no GitHub
- [ ] Workflow testado com uma tag
- [ ] App testado com verificação de atualizações

## 🧪 Testando o Sistema

### 1. Teste Local
```bash
# Instalar dependências
flutter pub get

# Testar build
flutter build apk --release
```

### 2. Teste de Release
```bash
# Criar e enviar uma tag de teste
git tag v1.0.1-test
git push origin v1.0.1-test
```

### 3. Verificar no GitHub
1. Vá para **Actions** e verifique se o workflow executou
2. Vá para **Releases** e verifique se a release foi criada
3. Baixe o APK e teste a instalação

## 🔧 Personalização

### Modificar Mensagens de Release
Edite o arquivo `.github/workflows/build-release.yml` na seção `body:`

### Adicionar Mais Plataformas
O workflow atual gera APK para Android. Para iOS, você precisaria:
- Configurar certificados da Apple
- Adicionar steps para build iOS
- Configurar distribuição via TestFlight ou similar

### Configurar Notificações
Você pode configurar notificações do GitHub para ser avisado quando:
- O build falha
- Uma nova release é criada
- Alguém baixa o APK

## 🚨 Troubleshooting

### Erro: "Keystore not found"
- Verifique se o secret `KEYSTORE_BASE64` está configurado
- Verifique se o caminho da keystore está correto

### Erro: "Permission denied"
- Verifique se o token do GitHub tem permissões suficientes
- Verifique se os secrets estão configurados corretamente

### App não detecta atualizações
- Verifique se `app_config.dart` está configurado corretamente
- Verifique se a release foi criada no GitHub
- Verifique os logs do app para erros de rede

### APK não instala
- Verifique se "Fontes desconhecidas" está habilitado
- Verifique se o APK foi assinado corretamente
- Verifique se há espaço suficiente no dispositivo

## 📚 Recursos Adicionais

- [Documentação do GitHub Actions](https://docs.github.com/en/actions)
- [Documentação do Flutter Build](https://docs.flutter.dev/deployment/android)
- [Assinatura de APKs](https://developer.android.com/studio/publish/app-signing)

## 🎯 Próximos Passos

Após configurar o sistema básico, considere:

1. **Implementar rollback automático** em caso de erro
2. **Adicionar analytics** para acompanhar downloads
3. **Configurar diferentes canais** (beta, stable)
4. **Implementar delta updates** para economizar dados
5. **Adicionar verificação de integridade** do APK

---

**💡 Dica**: Mantenha sempre um backup da sua keystore em local seguro. Se você perder a keystore, não conseguirá mais atualizar o app para usuários existentes!