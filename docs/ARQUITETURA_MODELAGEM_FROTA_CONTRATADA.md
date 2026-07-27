# Gestao de Frota Contratada

> Guia de Arquitetura, Modelagem e Desenvolvimento

---

## Sumario

- [1. Arquitetura do Software](#1-arquitetura-do-software)
- [2. Estrutura de Pastas](#2-estrutura-de-pastas)
- [3. Comunicacao entre Componentes](#3-comunicacao-entre-componentes)
- [4. Responsabilidades das Camadas](#4-responsabilidades-das-camadas)
- [5. Infraestrutura e Hospedagem](#5-infraestrutura-e-hospedagem)
- [6. Dependencias Externas](#6-dependencias-externas)
- [7. Modelagem de Dados](#7-modelagem-de-dados)
- [8. Especificacao Tecnica das Funcionalidades](#8-especificacao-tecnica-das-funcionalidades)
- [9. Cronograma de Sprints](#9-cronograma-de-sprints)

---

## 1. Arquitetura do Software

**Modelo adotado:** Monolito Modular (Backend) + Feature-First (Mobile)

O backend centraliza o codigo em um unico repositorio estruturado, dividindo as regras de negocio em modulos independentes e isolados (precificacao, corridas, usuarios, IA scanner, etc).

O mobile (Flutter) agrupa o codigo por funcionalidades de negocio (features), cada uma com suas proprias camadas de dominio, dados e apresentacao.

**Por que essa escolha:**
- Simplicidade de deploy e monitoramento
- Organizacao modular que facilita manutencao
- Preparado para transicao futura a microsservicos se necessario

---

## 2. Estrutura de Pastas

### Backend (NestJS)

```
api/
├── test/
│   ├── buscar-usuario.service.spec.ts
│   ├── buscar-usuario.controller.spec.ts
│   ├── criar-usuario.service.spec.ts
│   ├── criar-usuario.controller.spec.ts
│   └── usuario.e2e.spec.ts
├── src/
│   ├── modules/
│   │   └── user/
│   │       ├── controllers/
│   │       │   ├── criar-usuario.controller.ts
│   │       │   └── buscar-usuario.controller.ts
│   │       ├── dtos/
│   │       │   ├── criar-usuario-request.dto.ts
│   │       │   ├── criar-usuario-response.dto.ts
│   │       │   ├── usuario-summary.dto.ts
│   │       │   ├── usuario-details.dto.ts
│   │       │   └── usuario.dto.ts
│   │       ├── domain/
│   │       │   ├── usuario.repository.ts
│   │       │   └── usuario.ts
│   │       ├── services/
│   │       │   ├── criar-usuario.service.ts
│   │       │   └── buscar-usuario.service.ts
│   │       └── usuario.module.ts
│   ├── core/
│   │   ├── database/
│   │   │   ├── interfaces/
│   │   │   │   └── repository.interface.ts
│   │   │   └── database.module.ts
│   │   └── storage/
│   │       ├── storage.interface.ts
│   │       └── storage.module.ts
│   ├── common/
│   │   └── interfaces/
│   │       ├── response.interface.ts
│   │       └── pagination.interface.ts
│   ├── integrations/
│   │   └── aws/
│   │       ├── cognito-auth.service.ts
│   │       └── s3-storage.service.ts
│   ├── app.module.ts
│   └── main.ts
└── prisma/
```

| Pasta | Responsabilidade |
|-------|-----------------|
| `src/modules/` | Modulos de dominio (user, rides, contracts, suppliers, ai, auth). Cada um com controllers, dtos, domain e services |
| `src/core/` | Infraestrutura compartilhada (database, storage) |
| `src/common/` | Interfaces genericas (response, pagination) |
| `src/integrations/` | Servicos externos isolados (Cognito, S3) |
| `prisma/` | Schemas e migracoes do ORM |
| `test/` | Testes unitarios e E2E |

---

### Mobile (Flutter)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_string.dart
│   │   └── app_colors.dart
│   ├── error/
│   │   ├── excecoes.dart
│   │   └── falhas.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── usecases/
│   │   └── usecase.dart
│   └── widgets/
│       ├── loading_widget.dart
│       └── error_widget.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── usuario.dart
│   │   │   ├── usecases/
│   │   │   │   ├── login_usecase.dart
│   │   │   │   ├── logout_usecase.dart
│   │   │   │   └── buscar_usuario_atual_usecase.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── usuario_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart
│   │       ├── widgets/
│   │       │   └── auth_form_widget.dart
│   │       └── pages/
│   │           └── login_page.dart
│   └── home/
│       ├── domain/
│       ├── data/
│       └── presentation/
├── injection_container/
│   ├── injection_container.dart
│   ├── auth_injection.dart
│   └── home_injection.dart
├── config/
│   ├── env.dart
│   ├── themes.dart
│   └── routes.dart
├── main.dart
└── app.dart
```

| Pasta | Responsabilidade |
|-------|-----------------|
| `lib/core/` | Infraestrutura base: rede, erros, widgets compartilhados |
| `lib/features/` | Cada feature (auth, ride, history, profile) com domain/data/presentation |
| `lib/injection_container/` | Injecao de dependencias por feature |
| `lib/config/` | Ambiente, temas e rotas |

---

### Frontend Web (React + TypeScript)

```
src/
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
├── components/
│   ├── common/
│   │   ├── Button/
│   │   ├── Input/
│   │   └── Modal/
│   └── layout/
│       ├── Header/
│       ├── Sidebar/
│       └── Footer/
├── hooks/
│   ├── useAuth.ts
│   ├── useFetch.ts
│   └── useDebounce.ts
├── routes/
│   ├── index.tsx
│   ├── PrivateRoute.tsx
│   └── paths.ts
├── services/
│   ├── api/
│   │   ├── auth.service.ts
│   │   └── user.service.ts
│   └── http/
│       ├── client.ts
│       └── interceptors.ts
├── styles/
│   ├── global.css
│   ├── theme.ts
│   └── variables.css
├── App.tsx
└── main.tsx
```

| Pasta | Responsabilidade |
|-------|-----------------|
| `src/components/common/` | Componentes reutilizaveis (Button, Input, Modal) |
| `src/components/layout/` | Estrutura de navegacao (Header, Sidebar, Footer) |
| `src/hooks/` | Custom Hooks (auth, fetch, debounce) |
| `src/routes/` | Navegacao, guardas de rota e paths |
| `src/services/` | Cliente HTTP, interceptors e chamadas a API |
| `src/styles/` | Estilos globais, tema e variaveis CSS |

---

## 3. Comunicacao entre Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                              │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTPS / WebSocket
                            ▼
┌───────────────────────────────────────────────────────────┐
│              PROXY REVERSO (DMZ - portas 80/443)           │
└───────────────────────────┬───────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────┐
│                    API NestJS (Rede Interna)               │
│                                                           │
│  Modulos comunicam via injecao de dependencias interna    │
│  (sem latencia de rede entre modulos)                     │
└──────────┬────────────────────────────┬───────────────────┘
           │                            │
           ▼                            ▼
┌────────────────────┐      ┌────────────────────────┐
│   SQL Server (SRP) │      │   Redis (Cache/Filas)  │
│   TCP/IP + Prisma  │      │   BullMQ               │
└────────────────────┘      └────────────────────────┘
```

| Protocolo | Uso |
|-----------|-----|
| **HTTPS (REST)** | Comunicacao padrao entre clientes (Web/Mobile) e API |
| **WebSocket (Socket.io)** | Telemetria GPS em tempo real (baixa latencia) |
| **TCP/IP via Prisma** | Conexao backend -> SQL Server |
| **Injecao de dependencias** | Comunicacao interna entre modulos NestJS |

---

## 4. Responsabilidades das Camadas

| Camada | Tecnologia | Responsabilidade |
|--------|-----------|-----------------|
| **Apresentacao** | React.js / Flutter | Renderizacao, captura de interacoes, estado local, consumo de endpoints, persistencia offline (mobile) |
| **Proxy** | Nginx (DMZ) | Terminacao SSL, filtragem de requisicoes, ocultacao da rede interna |
| **Aplicacao** | NestJS | RBAC, Row-Level Security por filial, motor de precificacao, tarefas em background, comunicacao com IA |
| **Persistencia** | SQL Server | Integridade referencial, isolamento de tabelas, logs de auditoria imutaveis |

---

## 5. Infraestrutura e Hospedagem

**Modelo:** On-Premise (servidores locais da Seara)

### Topologia de Producao

| Componente | Localizacao | Funcao |
|------------|-------------|--------|
| Maquina Externa | DMZ | Proxy Reverso (portas 80/443) |
| Maquina Interna | Rede corporativa | API NestJS + Frontend estatico + File Server (PDFs/logs) |
| SQL Server | Servidor SRP dedicado | Banco relacional com backup nativo |

### Ambientes

| Ambiente | Maquinas | Objetivo |
|----------|----------|----------|
| Desenvolvimento | 7 VMs (1 por dev) | Codificacao e testes locais isolados |
| Homologacao | 2 VMs | QA, testes integrados, demos ao cliente |
| Producao | 2 VMs (DMZ + interna) | Sistema em operacao |

### Processamento em Background

Tarefas pesadas sao gerenciadas fora do fluxo principal da API via **BullMQ + Redis**:
- Envio em massa de e-mails (autenticacao 2FA)
- Calculos de roteirizacao
- Extracao de contratos via IA/OCR

---

## 6. Dependencias Externas

| Servico | Uso | Detalhes |
|---------|-----|----------|
| **Tesseract.js** | OCR de contratos | Leitura optica de PDFs para extrair texto bruto |
| **Google Gemini API** | Interpretacao de contratos | Converte texto OCR em JSON estruturado (taxas, valores, regras) |
| **Nominatim (OpenStreetMap)** | Geocodificacao | Converte enderecos em coordenadas (rate-limit: 1 req/s) |
| **OSRM (Docker)** | Calculo de rotas | Rota otimizada e distancia rodoviaria |
| **Mensageria corporativa Seara** | Envio de OTP (2FA) | Disparo de tokens via Stored Procedure ou executavel local |
| **Redis** | Cache e filas | Sessoes de usuario + filas BullMQ |

---

## 7. Modelagem de Dados

### Banco Relacional (SQL Server)

Modelo logico disponivel em: [dbdiagram.io - Gestao Frota Contratada](https://dbdiagram.io/d/Gestao-Frota-Contratada-6a0d0fad697f99c167b90622)

Principais entidades:
- **Usuarios** (perfis: Admin Master, Admin Filial, Fornecedor, Aprovador, Solicitante, Motorista)
- **Filiais** (isolamento de dados por unidade)
- **Fornecedores** (vinculados a filiais)
- **Contratos** (regras de precificacao por fornecedor)
- **Motoristas/Veiculos** (vinculados a fornecedores)
- **Corridas** (ciclo: solicitacao -> aprovacao -> atribuicao -> execucao -> conclusao)
- **Coordenadas GPS** (telemetria do trajeto)
- **Paradas** (esperas e pedagios durante corrida)
- **Logs de Auditoria** (operacoes sensiveis, imutaveis)

### Banco Nao-Relacional (Redis)

Modelo disponivel em: [Canva - Redis](https://canva.link/p85wpr23r0oip68)

Uso:
- Sessoes de usuario (JWT refresh)
- Filas de processamento (BullMQ)
- Cache de rotas calculadas

---

## 8. Especificacao Tecnica das Funcionalidades

### 8.1 Login e Autenticacao 2FA

| Item | Descricao |
|------|-----------|
| **Objetivo** | Acesso seguro via dupla validacao (credencial AD + token OTP por e-mail) |
| **Usuarios** | Todos os perfis (Web e Mobile) |
| **Dados** | E-mail corporativo, senha (hash), Token OTP |

**Fluxo:**
1. Usuario insere credenciais
2. Backend valida no SQL Server
3. API aciona mensageria corporativa (Stored Procedure)
4. E-mail com token OTP enviado ao usuario
5. Usuario insere token na interface
6. Sistema libera sessao JWT

**Regras:** Token OTP expira em 5 minutos. 3 tentativas erradas = bloqueio temporario.

---

### 8.2 Processamento de Contratos via IA/OCR

| Item | Descricao |
|------|-----------|
| **Objetivo** | Automatizar leitura de tabelas de precos em PDFs de contratos |
| **Usuarios** | Admin da Filial |
| **Dados** | PDF de entrada -> JSON estruturado (taxa/km, taxa espera, valores fixos) |

**Fluxo:**
1. Admin faz upload do contrato PDF
2. Backend envia ao Tesseract.js (OCR)
3. Texto bruto vai para Google Gemini (interpretacao)
4. Gemini retorna JSON com valores financeiros
5. Valores exibidos para revisao humana
6. Apos confirmacao, dados persistidos no banco

**Regras:** Processamento em ate 15s. Revisao manual obrigatoria antes da gravacao.

---

### 8.3 Solicitacao de Corrida e Precificacao

| Item | Descricao |
|------|-----------|
| **Objetivo** | Calcular rota, distancia e custo estimado baseado no contrato da filial |
| **Usuarios** | Solicitantes e Aprovadores |
| **Dados** | Enderecos (origem/destino), coordenadas, centro de custo, distancia (km), valor (R$) |

**Fluxo:**
1. Usuario digita enderecos
2. API consome Nominatim para geocodificacao
3. OSRM calcula rota e distancia rodoviaria
4. Backend cruza distancia com tabela do contrato (Prisma)
5. Valor estimado exibido para aprovacao

**Regras:** Calculo completo em menos de 2s. Valor deve refletir o contrato vigente da filial.

---

### 8.4 Rastreamento em Tempo Real (Live Tracking)

| Item | Descricao |
|------|-----------|
| **Objetivo** | Monitorar deslocamento do veiculo garantindo que trajeto planejado = executado |
| **Usuarios** | Motorista (transmissor) / Aprovador e Solicitante (receptores) |
| **Dados** | Coordenadas GPS, timestamp, status da corrida |

**Fluxo:**
1. App Flutter captura GPS em background
2. Dados emitidos via Socket.io para Proxy na DMZ
3. API transmite em broadcast para paineis conectados
4. Interfaces Web/Mobile movem marcador no mapa

**Regras:** Atraso maximo de 3-5s em conexao 4G/5G. Offline-first: coordenadas armazenadas localmente e enviadas em lote ao reconectar.

---

### 8.5 Dashboard de Auditoria e Faturamento

| Item | Descricao |
|------|-----------|
| **Objetivo** | Consolidar gastos reais para analise e liberacao de pagamento aos fornecedores |
| **Usuarios** | Admin da Filial |
| **Dados** | Historico de corridas, KM planejado vs real, justificativas de desvios, valor consolidado |

**Fluxo:**
1. Admin acessa aba de faturamento (portal React)
2. Filtra por periodo e fornecedor
3. Sistema compara rota OSRM com telemetria gravada
4. Discrepancias de KM destacadas visualmente
5. Admin valida justificativas e aprova lote financeiro

**Regras:** Paginacao assincrona. Desvios > 10% destacados em vermelho. Aprovacao bloqueada se houver desvios sem justificativa.

---

## 9. Cronograma de Sprints

### Visao Geral

| Sprint | Periodo | Foco |
|--------|---------|------|
| 0 | 18/05 - 25/05 | Configuracao de ambientes e padroes |
| 1 | 25/05 - 08/06 | Autenticacao e controle de acesso |
| 2 | 08/06 - 22/06 | Admin: Filiais, colaboradores, permissoes |
| 3 | 22/06 - 06/07 | Admin: Fornecedores e contratos |
| 4 | 06/07 - 20/07 | Fornecedor: Motoristas e veiculos |
| 5 | 20/07 - 03/08 | Corridas: Solicitacao, aprovacao, atribuicao |
| 6 | 03/08 - 14/08 | Execucao da corrida, GPS e rastreamento |
| 7 | 17/08 - 28/08 | Historicos, metricas e relatorios |
| 8 | 31/08 - 11/09 | Testes integrados, ajustes finais e validacao |

---

### Sprint 0 - Configuracao de Ambientes
**Periodo:** 18/05 a 25/05 (1 semana)

| Tarefa | Responsavel |
|--------|-------------|
| Estrutura inicial do Backend (NestJS + modulos base) | Karina, Theo |
| Estrutura inicial do Portal Web (React + navegacao) | Breno |
| Estrutura inicial do App Mobile (Flutter + camadas) | Filipi, Maria Eduarda |
| Criacao do banco de dados (tabelas, relacionamentos) | Sofia, Isaac |
| Configuracao dos ambientes de dev | Todos |
| Definicao dos padroes de desenvolvimento | Todos |

**Entregavel:** Bases web, mobile e backend configuradas + padroes definidos.

---

### Sprint 1 - Autenticacao e Controle de Acesso
**Periodo:** 25/05 a 08/06 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Autenticacao via Active Directory | Theo |
| Regras de autorizacao por perfil (RBAC) | Theo |
| Isolamento de dados por filial e fornecedor | Karina |
| Estrutura de auditoria (logs de operacoes sensiveis) | Sofia, Isaac |
| Tela de login Web + navegacao + protecao de rotas | Breno |
| Tela de login Mobile + navegacao + sessao | Filipi, Maria Eduarda |
| Integracao completa do fluxo de auth | Todos |

**Entregavel:** Login funcional (Web + Mobile), perfis diferenciados, isolamento por filial, auditoria.

---

### Sprint 2 - Admin: Filiais, Colaboradores e Permissoes
**Periodo:** 08/06 a 22/06 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Consulta de filiais (API) | Karina |
| Consulta de colaboradores via SRP | Karina |
| Gestao de admins de filiais (CRUD) | Karina |
| Atribuicao de permissoes | Karina |
| Telas Web: filiais, colaboradores, admins, permissoes | Breno |
| Componentes Flutter: listagem/filtro + formulario | Filipi, Maria Eduarda |
| Mapeamento de campos contratuais para IA/OCR | Karina |
| Integracao e validacao | Karina |

**Entregavel:** Gestao administrativa funcional com telas web integradas.

---

### Sprint 3 - Admin: Fornecedores e Contratos
**Periodo:** 22/06 a 06/07 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| CRUD de fornecedores | Karina |
| Cadastro inicial de contratos | Karina |
| Processamento de contratos (acionar IA/OCR) | Karina |
| Primeira versao da leitura automatizada (OCR + Gemini) | Karina |
| Telas Web: fornecedores e contratos | Breno |
| Telas Mobile: Home do Solicitante, Solicitacao de Corrida, Status | Filipi, Maria Eduarda |
| Integracao modulo fornecedores/contratos | Karina |

**Entregavel:** Cadastro de fornecedores, upload de contratos com OCR funcional, telas mobile (layout estatico).

---

### Sprint 4 - Fornecedor: Motoristas e Veiculos
**Periodo:** 06/07 a 20/07 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Cadastro de veiculos/motoristas | Karina |
| Controle de disponibilidade | Karina |
| Visualizacao de contratos pelo fornecedor | Karina |
| Revisao manual + confirmacao dos dados extraidos por IA | Karina |
| Tela Web: veiculos/motoristas + contratos do fornecedor | Breno |
| Telas Mobile: Home do Motorista, Registro de Paradas | Maria Eduarda |

**Entregavel:** Gestao de frota pelo fornecedor, fluxo de revisao de contratos, telas do Motorista (layout).

---

### Sprint 5 - Corridas: Solicitacao, Aprovacao e Atribuicao
**Periodo:** 20/07 a 03/08 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Solicitacao de corrida (Solicitante) | Filipi |
| Solicitacao de corrida (Aprovador - direta) | Filipi |
| Cancelamento de solicitacao | Filipi |
| Calculo de rota (OSRM) | Karina |
| Calculo de preco estimado (contrato vigente) | Karina |
| Tela Mobile: revisao de rota/preco antes de confirmar | Maria Eduarda |
| Telas Web: fila de aprovacao, aprovacao/recusa, atribuicao | Breno |
| Integracao mobile Solicitante com API real | Filipi |

**Entregavel:** Fluxo completo: solicitacao -> aprovacao -> atribuicao de motorista.

---

### Sprint 6 - Execucao, GPS e Rastreamento
**Periodo:** 03/08 a 14/08 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Tela Web: acompanhamento em tempo real (Aprovador) | Breno |
| Tela Mobile: detalhes da corrida para Motorista (aceite/recusa) | Maria Eduarda |
| Registro de inicio e fim da corrida (GPS) | Filipi, Maria Eduarda |
| Estrategia offline-first para GPS | Isaac |
| Visualizacao em tempo real (Solicitante, Aprovador, Fornecedor) | Maria Eduarda, Filipi, Breno |
| Registro de paradas (API) | Karina |
| Testes de execucao e GPS offline | Filipi |

**Entregavel:** Corrida executavel de ponta a ponta com rastreamento em tempo real e offline-first.

---

### Sprint 7 - Historicos, Metricas e Relatorios
**Periodo:** 17/08 a 28/08 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Conferencia de corridas (estimado vs realizado) | Karina, Theo, Isaac, Breno |
| Dashboard Admin (gastos por filial/fornecedor/periodo) | Karina, Theo, Isaac, Breno |
| Dashboard Fornecedor (custo por frota) | Karina, Theo, Isaac, Breno |
| Dashboard Aprovador (gasto por centro de custo) | Karina, Theo, Isaac, Breno |
| Filtros avancados (periodo, filial, centro de custo, motorista) | Karina, Theo, Isaac, Breno |
| Historico por perfil (Solicitante, Fornecedor, Aprovador) | Todos |
| Exportacao PDF e CSV/Excel | Karina, Theo, Isaac, Breno |
| Telas Mobile: historico e dashboards | Maria Eduarda, Filipi |

**Entregavel:** Dashboards, historicos e exportacao de relatorios funcionais.

---

### Sprint 8 - Testes Integrados e Validacao Final
**Periodo:** 31/08 a 11/09 (2 semanas)

| Tarefa | Responsavel |
|--------|-------------|
| Fechamento mensal (consolidacao financeira) | Karina, Theo, Isaac, Breno |
| Testes E2E (fluxos criticos) | Todos |
| Testes por perfil | Todos |
| Testes de permissoes e isolamento | Karina, Theo, Isaac |
| Testes IA/OCR (precisao com contratos reais) | Sofia, Isaac |
| Testes de calculo de preco | Karina, Theo, Sofia, Isaac |
| Testes de rastreamento offline | Maria Eduarda, Filipi |
| Ajustes finais Web e Mobile | Breno, Maria Eduarda, Filipi |
| Correcao de bugs | Todos |
| Validacao final com o cliente (Seara) | Todos |
| Preparacao para apresentacao do TCC | Todos |

**Entregavel:** Sistema validado, testado e pronto para producao.

---

## Links Uteis

| Recurso | Link |
|---------|------|
| Modelo logico do banco | [dbdiagram.io](https://dbdiagram.io/d/Gestao-Frota-Contratada-6a0d0fad697f99c167b90622) |
| Diagramas de infraestrutura/contexto/agentes | [Canva](https://canva.link/j6i2hp30hv7i423) |
| Modelo Redis | [Canva](https://canva.link/p85wpr23r0oip68) |
