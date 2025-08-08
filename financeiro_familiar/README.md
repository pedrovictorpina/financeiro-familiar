# financeiro_familiar

Aplicativo pessoal de controle financeiro multiusuário desenvolvido em Flutter.

## Como Executar

### Execução Padrão
```bash
flutter run -d chrome
```

### Execução com Porta Específica

#### Usando Script Batch (Windows)
```cmd
# Executar na porta padrão (8080)
run_with_port.bat

# Executar em uma porta específica
run_with_port.bat 3000
```

#### Usando Script PowerShell (Windows)
```powershell
# Executar na porta padrão (8080)
.\run_with_port.ps1

# Executar em uma porta específica
.\run_with_port.ps1 -Port 3000
```

#### Comando Flutter Direto
```bash
# Executar em uma porta específica
flutter run -d chrome --web-port=3000
```

## Funcionalidades

- 📊 Dashboard financeiro personalizado
- 💰 Controle de transações (receitas e despesas)
- 🎯 Planejamento e metas financeiras
- 💳 Gestão de contas e cartões
- 📈 Relatórios e gráficos
- 👥 Suporte multiusuário
- 🔐 Autenticação Firebase
- ☁️ Sincronização em nuvem

## Tecnologias

- **Flutter** - Framework de desenvolvimento
- **Firebase** - Backend e autenticação
- **Provider** - Gerenciamento de estado
- **FL Chart** - Gráficos e visualizações
- **Material Design** - Interface do usuário

## Getting Started

Para começar com o desenvolvimento Flutter, consulte a
[documentação online](https://docs.flutter.dev/), que oferece tutoriais,
exemplos, orientações sobre desenvolvimento mobile e uma referência completa da API.
