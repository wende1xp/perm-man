# 🔐 Gerenciador de Permissões

Script Bash interativo para aplicação de **perfis de permissão** em arquivos e diretórios, com menu intuitivo, resumo da operação e registro em log.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Requisitos](#-requisitos)
- [Como Usar](#-como-usar)
- [Perfis de Permissão](#-perfis-de-permissão)
- [Fluxo de Execução](#-fluxo-de-execução)
- [Log de Alterações](#-log-de-alterações)
- [Exemplos](#-exemplos)
- [Avisos Importantes](#-avisos-importantes)

---

## 📖 Visão Geral

O **Gerenciador de Permissões** é um script Bash que permite aplicar perfis predefinidos de permissões a todos os arquivos e diretórios de um caminho escolhido. Ele diferencia automaticamente as permissões aplicadas a **arquivos** e **diretórios**, exibe um resumo antes de agir e registra cada operação em um arquivo de log.

**Funcionalidades:**

- Menu interativo com 4 perfis de permissão
- Permissões distintas para arquivos e diretórios
- Resumo completo antes de aplicar qualquer alteração
- Confirmação obrigatória do usuário
- Registro detalhado das operações em log
- Suporte a caminhos relativos, absolutos e variáveis de ambiente (`$HOME`, `$PWD`, etc.)

---

## ⚙️ Requisitos

| Requisito | Versão Mínima |
|-----------|---------------|
| Bash | 4.0+ |
| `find` | GNU findutils |
| `chmod` | GNU coreutils |
| `realpath` | GNU coreutils |
| `whoami` | GNU coreutils |

> Todos os utilitários acima estão presentes por padrão em distribuições Linux modernas (Ubuntu, Debian, Fedora, Arch, etc.) e no macOS com Homebrew.

---

## 🚀 Como Usar

### 1. Tornar o script executável

```bash
chmod +x perm-man.sh
```

### 2. Executar o script

```bash
./perm-man.sh
```

### 3. Seguir o fluxo interativo

1. **Informe o caminho** do diretório alvo
2. **Escolha um perfil** de permissão no menu
3. **Revise o resumo** da operação
4. **Confirme** para aplicar (ou cancele para voltar ao menu)

---

## 🔑 Perfis de Permissão

| Opção | Perfil | Arquivos | Diretórios | Descrição |
|-------|--------|----------|------------|-----------|
| `1` | Somente leitura | `444` | `555` | Nenhum usuário pode escrever ou modificar |
| `2` | Leitura e escrita | `664` | `775` | Dono e grupo podem ler e escrever |
| `3` | Restrito | `600` | `700` | Acesso exclusivo ao dono do arquivo |
| `4` | Executável | `755` | `755` | Dono tem controle total; outros podem ler e executar |
| `9` | —  | — | — | Alterar o diretório alvo |
| `0` | — | — | — | Sair do script |

### Detalhamento das permissões

```
444  →  r--r--r--   (leitura para todos, sem escrita ou execução)
555  →  r-xr-xr-x   (leitura e execução para todos)
600  →  rw-------   (leitura e escrita só para o dono)
664  →  rw-rw-r--   (leitura e escrita para dono e grupo; leitura para outros)
700  →  rwx------   (acesso total só para o dono)
755  →  rwxr-xr-x   (acesso total para o dono; leitura e execução para outros)
775  →  rwxrwxr-x   (acesso total para dono e grupo; leitura e execução para outros)
```

---

## 🔄 Fluxo de Execução

```
Início
  │
  ▼
Informa o caminho do diretório
  │
  ▼
Seleciona o perfil de permissão
  │
  ▼
Exibe o resumo da operação
  │  (quantidade de arquivos e diretórios afetados,
  │   permissões que serão aplicadas, caminho alvo)
  ▼
Confirmação do usuário (s/n)
  │
  ├── [n] → Volta ao menu de perfis
  │
  └── [s] → Aplica permissões
               │
               ▼
           Registra no log
               │
               ▼
           Exibe resultado final
```

---

## 📄 Log de Alterações

Cada operação confirmada é registrada automaticamente no arquivo `alteracoes_permissoes.log`, criado no mesmo diretório em que o script é executado.

### Formato do log

```
[ INFORMAÇÃO ]
Timestamp...........: 2025-10-01 14:32:07
Usuário.............: seu_usuario
Diretório alvo......: /home/seu_usuario/projetos

[ CONFIGURAÇÃO ]
Perfil..............: Leitura e escrita
Permissão arquivos..: 664
Permissão diretórios: 775

[ RESULTADO ]
Arquivos alterados..: 42
Diretórios alterados: 8
==================================================
```

> O log é acumulativo — cada execução **adiciona** uma nova entrada sem apagar as anteriores.

---

## 💡 Exemplos

### Aplicar "Somente leitura" em um projeto

```
Digite o caminho do diretório: /var/www/html

Perfis disponíveis:
[1] Somente leitura     ← escolha esta opção
[2] Leitura e escrita
[3] Restrito
[4] Executável

Opção: 1

===============================================
              RESUMO DA OPERAÇÃO
===============================================

Perfil                  :   Somente leitura
Diretório               :   /var/www/html
Permissão de arquivos   :   444
Permissão de diretórios :   555
Diretórios encontrados  :   12
Arquivos encontrados    :   87

===============================================
Deseja continuar? (s/n): s

Aplicando permissões...
```

### Usar variável de ambiente como caminho

```
Digite o caminho do diretório: $HOME/documentos
```

O script expande automaticamente a variável e valida o caminho resultante.

---

## ⚠️ Avisos Importantes

> **Atenção ao perfil Restrito (`600`/`700`):** arquivos com permissão `600` não poderão ser lidos por outros usuários, incluindo servidores web. Certifique-se de saber o impacto antes de aplicar.

> **Permissão de execução em arquivos:** o perfil "Executável" (`755`) marca **todos** os arquivos como executáveis, inclusive arquivos de texto e imagens. Use apenas quando isso for intencional.

> **Operação irreversível:** o script não faz backup das permissões originais. Se precisar restaurar o estado anterior, consulte o log para referência e reverta manualmente.

> **Permissões de sistema:** evite executar o script em diretórios do sistema (como `/etc`, `/usr`, `/bin`). Alterar permissões nesses locais pode tornar o sistema inoperante.

> **Execução como root:** ao executar com `sudo`, as permissões serão aplicadas com privilégios de superusuário, afetando até arquivos protegidos.

---

## 📁 Estrutura de Arquivos

```
.
├── perm-man.sh                  # Script principal
└── alteracoes_permissoes.log    # Gerado automaticamente após a primeira execução
```

---

## 🪪 Licença

Este projeto é distribuído para uso livre. Sinta-se à vontade para modificar e adaptar conforme sua necessidade.
