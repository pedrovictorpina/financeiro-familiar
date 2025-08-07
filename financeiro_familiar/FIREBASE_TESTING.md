# Teste de Conexão Firebase - Financeiro Familiar

Este documento descreve como testar a conexão com o Firebase e verificar se o banco de dados está estruturado corretamente para o projeto.

## 🔧 Configuração Atual

O projeto está configurado com as seguintes credenciais Firebase:
- **Project ID**: `financeiro-familiar-11f38`
- **Auth Domain**: `financeiro-familiar-11f38.firebaseapp.com`
- **Storage Bucket**: `financeiro-familiar-11f38.firebasestorage.app`

## 🧪 Como Executar os Testes

### 1. Através da Interface da Aplicação

1. Execute a aplicação:
   ```bash
   flutter run -d chrome
   ```

2. Faça login ou registre-se na aplicação

3. Navegue para **Configurações** (ícone de engrenagem na barra inferior)

4. Na seção "Dados", clique em **"Teste Firebase"**

5. Clique no botão **"Executar Testes Firebase"**

6. Observe os resultados dos testes no console da tela

### 2. Através do Código (Para Desenvolvedores)

Você pode executar os testes programaticamente:

```dart
import 'package:financeiro_familiar/test_firebase_connection.dart';

// Executar todos os testes
final logs = await FirebaseConnectionTest.runAllTests();
for (final log in logs) {
  print(log);
}
```

## 📊 Estrutura do Banco de Dados

O projeto utiliza o Firestore com a seguinte estrutura:

### Coleções Principais

#### 1. `usuarios`
```
usuarios/
├── {uid}/
│   ├── uid: string
│   ├── nome: string
│   ├── email: string
│   ├── orcamentos: array
│   └── dataCriacao: timestamp
```

#### 2. `orcamentos`
```
orcamentos/
├── {orcamentoId}/
│   ├── nome: string
│   ├── descricao: string
│   ├── usuariosVinculados: array
│   ├── dataCriacao: timestamp
│   ├── ativo: boolean
│   └── subcoleções:
│       ├── transacoes/
│       ├── categorias/
│       ├── contas/
│       ├── cartoes/
│       ├── metas/
│       ├── planejamentos/
│       └── config_dashboard/
```

### Subcoleções

#### `transacoes`
- Armazena todas as transações financeiras
- Campos: valor, tipo, categoria, conta, data, descrição, etc.

#### `categorias`
- Categorias personalizadas para classificar transações
- Campos: nome, cor, ícone, tipo (receita/despesa)

#### `contas`
- Contas bancárias e carteiras
- Campos: nome, tipo, saldo, banco, etc.

#### `cartoes`
- Cartões de crédito
- Campos: nome, limite, fechamento, vencimento, etc.

#### `metas`
- Metas financeiras
- Campos: nome, valor, prazo, progresso, etc.

#### `planejamentos`
- Planejamento mensal
- Campos: mês, categorias, valores planejados vs realizados

#### `config_dashboard`
- Configurações de layout do dashboard
- Campos: cardId, visível, ordem, etc.

## ✅ Testes Realizados

O sistema de testes verifica:

1. **Inicialização do Firebase**
   - ✅ Conexão estabelecida
   - ✅ Configurações carregadas

2. **Conexão com Firestore**
   - ✅ Operações de leitura/escrita
   - ✅ Regras de segurança

3. **Firebase Authentication**
   - ✅ Serviço disponível
   - ✅ Estado do usuário atual

4. **Estrutura do Banco**
   - ✅ Coleções principais existem
   - ✅ Subcoleções configuradas
   - ✅ Documentos acessíveis

5. **Operações CRUD**
   - ✅ CREATE: Criar documentos
   - ✅ READ: Ler documentos
   - ✅ UPDATE: Atualizar documentos
   - ✅ DELETE: Deletar documentos

## 🚨 Possíveis Problemas

### Erro de Conexão
- Verifique sua conexão com a internet
- Confirme se as credenciais Firebase estão corretas
- Verifique se o projeto Firebase está ativo

### Erro de Permissão
- Verifique as regras de segurança do Firestore
- Confirme se o usuário está autenticado (quando necessário)

### Coleções Vazias
- É normal que as coleções estejam vazias em um projeto novo
- Use a aplicação para criar dados de teste

## 📝 Logs de Exemplo

```
🚀 Iniciando testes de conexão Firebase...
==================================================
✅ Firebase inicializado com sucesso
✅ Conexão com Firestore estabelecida
✅ Firebase Auth disponível. Usuário atual: Nenhum

📊 Verificando estrutura do banco de dados...
📁 Coleção "usuarios": Vazia
📁 Coleção "orcamentos": Vazia

🧪 Testando operações CRUD...
✅ CREATE: Usuário criado
✅ READ: Usuário lido com sucesso
✅ UPDATE: Usuário atualizado
✅ DELETE: Usuário deletado

==================================================
🏁 Testes concluídos!
```

## 🔗 Links Úteis

- [Console Firebase](https://console.firebase.google.com/project/financeiro-familiar-11f38)
- [Documentação Firestore](https://firebase.google.com/docs/firestore)
- [Documentação Firebase Auth](https://firebase.google.com/docs/auth)

---

**Nota**: Este sistema de testes foi criado para facilitar a verificação da conectividade e estrutura do Firebase durante o desenvolvimento e manutenção do projeto.