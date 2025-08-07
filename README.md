# 💰 Financeiro Familiar

Um aplicativo Flutter moderno e intuitivo para gerenciamento de finanças pessoais e familiares, com interface elegante e funcionalidades completas para controle financeiro.

## 🚀 Funcionalidades

### 📊 Dashboard Principal
- **Visão geral do saldo** com opção de ocultar/mostrar valores
- **Filtro de mês interativo** com navegação entre anos
- **Resumo de receitas e despesas** do mês selecionado
- **Lista de transações recentes** com detalhes
- **Botões de ação rápida** para adicionar transações

### 💳 Gestão de Transações
- **Adicionar Receitas**: Formulário completo com validação
- **Adicionar Despesas**: Categorização e controle de gastos
- **Transferências**: Entre contas com validação de saldo
- **Validação de formulários** em tempo real
- **Integração com Firebase** para persistência de dados

### 🏦 Cartões de Crédito
- **Gerenciamento de múltiplos cartões**
- **Controle de faturas mensais**
- **Acompanhamento de limites**
- **Histórico de gastos por cartão**

### 📱 Interface Moderna
- **Design responsivo** para web e mobile
- **Tema escuro elegante**
- **Animações suaves**
- **UX intuitiva** e acessível

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.x** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Firebase Firestore** - Banco de dados NoSQL
- **Provider** - Gerenciamento de estado
- **Material Design 3** - Sistema de design

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  provider: ^6.1.1
  intl: ^0.19.0
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.0 ou superior)
- Dart SDK
- Android Studio / VS Code
- Conta Firebase configurada

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/pedrovictorpina/financeiro-familiar.git
cd financeiro-familiar/financeiro_familiar
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Firebase**
- Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
- Adicione o arquivo `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
- Configure as regras do Firestore conforme `firestore.rules`

4. **Execute o aplicativo**
```bash
# Para web
flutter run -d chrome

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── transaction.dart
│   ├── card.dart
│   └── account.dart
├── providers/                # Gerenciamento de estado
│   └── finance_provider.dart
├── screens/                  # Telas da aplicação
│   ├── dashboard/
│   ├── transactions/
│   ├── cards/
│   ├── accounts/
│   └── categories/
├── services/                 # Serviços externos
│   └── firebase_service.dart
├── utils/                    # Utilitários
│   ├── formatters.dart
│   └── bank_utils.dart
└── widgets/                  # Componentes reutilizáveis
    └── custom_widgets.dart
```

## 🎯 Funcionalidades Implementadas Recentemente

### ✅ Filtro de Mês na Dashboard
- Navegação entre meses e anos
- Seleção visual do mês atual
- Botão "Mês Atual" para retorno rápido
- Atualização dinâmica dos dados

### ✅ Telas de Transação
- **Tela de Receitas**: Formulário completo com validação
- **Tela de Despesas**: Categorização e controle
- **Tela de Transferências**: Validação de saldo e contas
- Integração com `FinanceProvider`
- Design consistente com o tema do app

## 🔧 Configuração do Firebase

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Coleções do Banco
- `transactions` - Transações financeiras
- `cards` - Cartões de crédito
- `accounts` - Contas bancárias
- `categories` - Categorias de transações

## 🎨 Design System

### Cores Principais
- **Primary**: `#8B5CF6` (Roxo)
- **Background**: `#1A1A1A` (Preto)
- **Surface**: `#2A2A2A` (Cinza escuro)
- **Text**: `#FFFFFF` (Branco)

### Tipografia
- **Fonte**: System default (Roboto/SF Pro)
- **Tamanhos**: 12px, 14px, 16px, 18px, 20px, 24px

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Pedro Victor Pina**
- GitHub: [@pedrovictorpina](https://github.com/pedrovictorpina)

## 🙏 Agradecimentos

- Flutter Team pelo excelente framework
- Firebase pela infraestrutura robusta
- Comunidade Flutter pelas contribuições e suporte

---

⭐ Se este projeto te ajudou, considere dar uma estrela no repositório!