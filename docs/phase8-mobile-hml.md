# Fase 8 — Mobile HML (auditoria em 2026-10-09)

## Estado e limites da execução

- Base oficial revalidada: `github/main` em `9399d49908bb6973e64ea987dfe964ce52ca472e`. A branch `phase8/mobile-hml-main` foi criada dessa base e recebeu apenas o cherry-pick do delta da Fase 8 (`3ca727a`). A referência `phase8/backup-3ca727a` preserva o commit anterior. O commit exclusivo de `tracking` (`6314fa5`, detalhes de paradas) não foi incorporado; nenhuma alteração da Fase 8 depende dele.
- Flutter 3.47.2, Dart 3.13.2, SDK `^3.11.5`; Android `minSdk 24`, `compileSdk` e `targetSdk` do Flutter, Java 17 no projeto, Gradle 8.14, AGP 8.11.1. Não há flavors. CI original `checks-warning.yml` não bloqueia falhas; `mobile-hml.yml` adiciona gate e APK release.
- HML usa `BASE_URL=https://api.frota-contratada.hml.seara.com.br`, `TRIP_WEBAPP_URL=https://frota-contratada.hml.seara.com.br/acompanhamento`, `TRIP_SOCKET_URL=https://api.frota-contratada.hml.seara.com.br`, `TRIP_TRACKING_BASE_URL=https://api.frota-contratada.hml.seara.com.br/corridas`. São `dart-define`; não há credenciais no build.
- Paths conferidos no `RouterModule` e controllers do backend: `/autenticacao`, `/usuario/info/me`, `/motorista/viagens`, `/motorista/corridas`, `/motorista/perfil`, `/solicitacoes`, `/centro-de-custo` e `/corridas/:id/{tracking,tracking/positions/batch,tracking/passenger-position,route/reroute,waiting/start,waiting/resume,finish}`. Conferência de código, sem chamada HML autenticada.
- `TripTrackingMockDatasource` e `NoopTripTrackingSocketDatasource` são injetados apenas quando `kDebugMode && TRIP_TRACKING_MOCK`; release usa HTTP e Socket.IO reais. `CorridaRemoteDatasourceMock` e `AuthRemoteDatasourceMock` existem, mas a injeção usa implementações reais. Testes existentes cobrem bridge, join, idempotência e navegação; não comprovam HML.
- Tokens access, refresh, PIN e usuário são gravados em `SharedPreferences` (sem armazenamento criptografado). Logout das duas telas foi corrigido para chamar `LogoutUsecase`, que remove essas chaves e posições em buffer antes de limpar a pilha de navegação. A inicialização agora consulta `/usuario/info/me` quando há token salvo e restaura a home correspondente se o servidor confirmar a sessão. O comportamento real em HML ainda precisa de aparelho; armazenamento criptografado continua pendente.
- WebView usa `role=driver|passenger`, handshake de `tripId`, bloqueia navegação fora da mesma origem, recarrega após erro de documento principal e abre Waze/Google Maps por `url_launcher`. Fluxo real permanece pendente. Socket.IO usa transporte WebSocket, token no cabeçalho, join com confirmação e reconexão. Tracking usa buffer, posição de passageiro, idempotência em comandos e geolocalização. O manifesto declara localização fina, aproximada e background; o driver solicita rastreamento em background com notificação foreground. Permissões precisam ser verificadas em Android real.
- O fallback público `router.project-osrm.org` fica desativado em release. Sem `OSRM_BASE_URL` corporativo HTTPS, o mapa não calcula trajeto por ruas. **Bloqueio específico de roteirização:** fornecer endpoint OSRM corporativo ou decisão funcional; não usar serviço público com coordenadas HML.
- TLS: manifesto bloqueia cleartext e não há bypass de certificado. `curl` para API e Web HML expirou por timeout nesta sessão; confiança da cadeia no dispositivo não foi comprovada. Nenhum resultado TLS foi marcado PASS.
- Gates repetidos sobre `github/main` atual: `flutter pub get` passou, `flutter analyze` sem erros, `flutter test` 23/23. `scripts/build-hml.ps1` tentou release, mas não gerou APK: Gradle 8.14 não está em cache, o download expirou e o host tem Java 25. O workflow novo usa Java 17. `adb devices` também falhou antes de listar aparelhos por diretório `.android` inacessível.
- GitHub CLI retorna HTTP 401 (token inválido); branch/PR não puderam ser publicadas nesta sessão. O checkout original em `C:\FrotaContratada\work\frota-mobile` é somente leitura nesta sessão; alterações foram feitas em clone isolado no diretório temporário autorizado. Nenhum arquivo do backend, Web, IA, acompanhamento, infra ou do Caderno foi alterado.
- Assinatura Android: `android/app/build.gradle.kts` usa chave debug para `release`. É instalável para teste interno, mas upgrades entre ambientes/execuções com chaves debug distintas podem falhar. Não há chave HML estável fornecida nesta sessão.
- Caderno oficial somente lido: SHA256 `C58E48AE94806077EB3169DEC81041E8C710C07B168412F09560388CCE7C5F72`, 88.035 bytes; sem alteração nesta sessão.

## Matriz dos 26 testes oficiais

`DEVICE_REQUIRED` indica execução pendente em emulador/aparelho com acesso HML; testes unitários citados nas observações não substituem a evidência do cenário oficial. API é o path esperado, não uma chamada HML observada. A senha de homologação só deve ser solicitada quando o ambiente permitir o teste autenticado.

| ID | Perfil | Pré-condição / ação | API esperada | Classe | Status | Resultado e causa |
|---|---|---|---|---|---|---|
| M1 | Passageiro/Motorista | Contas cadastradas; login válido | `GET /autenticacao/primeiro-acesso/:email`, `POST /autenticacao/login`, `GET /usuario/info/me` | Emulador | DEVICE_REQUIRED | Sem acesso HML/credencial nesta sessão. |
| M2 | Passageiro/Motorista | Conta cadastrada; senha incorreta | `GET /autenticacao/primeiro-acesso/:email`, `POST /autenticacao/login` | Emulador | DEVICE_REQUIRED | Erro real ainda não observado. |
| M3 | Passageiro/Motorista | Email inexistente | `GET /autenticacao/primeiro-acesso/:email` | Emulador | DEVICE_REQUIRED | Erro real ainda não observado. |
| M4 | Passageiro/Motorista | Email vazio; avançar | nenhuma | Emulador | DEVICE_REQUIRED | Validação visual pendente. |
| M5 | Passageiro/Motorista | Senha vazia; avançar | nenhuma | Emulador | DEVICE_REQUIRED | Validação visual pendente. |
| M6 | Passageiro/Motorista | Primeiro acesso; confirmação diferente | `POST /autenticacao/pin/enviar`, `POST /autenticacao/pin/confirmar` | Emulador | BLOCKED | Caixa de email real necessária para chegar à confirmação; contas `@frota.com.br` são fictícias. |
| M7 | Passageiro | Autenticado; solicitar pelo mapa | catálogos e `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Criação real pendente. |
| M8 | Passageiro | Autenticado; solicitar pelo widget | catálogos e `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Criação real pendente. |
| M9 | Passageiro | Autenticado; transporte de objetos | catálogos e `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Criação real pendente. |
| M10 | Passageiro | Viagens futuras; filtrar semana | `GET /solicitacoes/viagens` | Emulador | DEVICE_REQUIRED | Requer fixture transacional da Fase 7. |
| M11 | Passageiro | Formulário válido; várias paradas | catálogos e `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Persistência de paradas não observada. |
| M12 | Passageiro | Permissão de emergência; solicitar | catálogos e `POST /solicitacoes` | Emulador | BLOCKED | Pré-condição de autorização específica não comprovada para conta Passageiro. |
| M13 | Passageiro | Formulário válido; acompanhantes | catálogos e `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Criação real pendente. |
| M14 | Passageiro | Formulário válido; múltiplos centros de custo | `GET /centro-de-custo`, `POST /solicitacoes` | Emulador | DEVICE_REQUIRED | Criação real pendente. |
| M15 | Passageiro | Solicitações existentes; filtrar | `GET /solicitacoes` | Emulador | DEVICE_REQUIRED | Requer fixture transacional da Fase 7. |
| M16 | Passageiro | Autenticado; alterar notificações | nenhuma | Emulador | FAIL | Toggles mudam apenas em memória; o resultado esperado “Configuração salva” não persiste após reabrir. Melhoria pós-MVP decidida; Caderno intacto. |
| M17 | Passageiro | Autenticado; sair | limpeza local | Emulador | DEVICE_REQUIRED | Correção e teste de limpeza local PASS; fluxo autenticado em aparelho pendente. |
| M18 | Passageiro/Motorista | Corrida iniciada; localização em tempo real | `GET /corridas/:id/tracking`, Socket.IO, posições | Aparelho físico | DEVICE_REQUIRED | Exige GPS, conexão e corrida real. |
| M19 | Motorista | Autenticado; cards agendados | `GET /motorista/viagens` | Emulador | DEVICE_REQUIRED | Requer fixture transacional da Fase 7. |
| M20 | Motorista | Corrida alocada; iniciar | `POST /motorista/corridas/:id/iniciar`, tracking | Emulador | DEVICE_REQUIRED | “Corrida aceita” é terminologia do Caderno; app não tem botão aceitar. |
| M21 | Motorista | Corrida em andamento; pausa | `POST /corridas/:id/waiting/start` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real e WebView. |
| M22 | Motorista | Corrida em espera; retomar | `POST /corridas/:id/waiting/resume` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real e WebView. |
| M23 | Motorista | Corrida em andamento; finalizar | `POST /corridas/:id/finish` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real e WebView. |
| M24 | Motorista | Autenticado; perfil | `GET /motorista/perfil` | Emulador | DEVICE_REQUIRED | Resposta real pendente. |
| M25 | Motorista | Corridas finalizadas; filtrar histórico | `GET /motorista/viagens` | Emulador | DEVICE_REQUIRED | Requer fixture transacional da Fase 7. |
| M26 | Motorista | Disponível; fluxo completo | iniciar, tracking, finish | Aparelho físico | DEVICE_REQUIRED | “Aceitar” diverge do app; fluxo real e fixtures pendentes. |

## Roteiro para aparelho físico

1. Em Android compatível (API 24+), conferir SHA256 do APK, instalar limpo e abrir. Confirmar que aparece login e que requisições API/WebView usam HTTPS com certificado confiável. Não instalar CA improvisada nem desabilitar verificação.
2. Fazer login com Passageiro e Motorista em execuções separadas, sem registrar senhas ou JWT. Reiniciar app e confirmar restauração de sessão. Expirar/revogar token para verificar refresh e 401.
3. Validar home, solicitação de viagem/objeto, paradas, centro de custo, acompanhantes, revisão, criação, listagem, detalhe e cancelamento do Passageiro. Usar fixtures da Fase 7; registrar request/response sanitizados em falhas.
4. Validar home, viagem, detalhe, iniciar, recusar, perfil e histórico do Motorista. Usar corrida alocada; não procurar botão “aceitar”.
5. Durante corrida real, conceder localização precisa, validar tracking para os dois papéis, Socket.IO, interrupção de rede, reconexão, WebView/reload, espera, retomada e finalização. Levar app a background e voltar; observar notificação foreground do Motorista e permissões solicitadas.
6. Acionar Google Maps e Waze pela WebView; conferir destino, abertura externa e mensagem de falha quando app terceiro indisponível.
7. Sair pelas Configurações dos dois papéis; confirmar retorno ao login, botão Back sem sessão, tokens removidos e API protegida sem autenticação. Reinstalar e testar upgrade do APK com a mesma assinatura para confirmar comportamento de dados e assinatura.
8. Primeiro acesso com PIN só deve receber PASS quando houver uma caixa de email real e autorizada. Não usar bypass.

## Dependências e melhorias

- **DEPENDÊNCIA FASE 7 / BACKEND:** fixtures de corridas e solicitações para M10, M15, M18–M23, M25 e M26. Não houve resposta HML observada que permita afirmar bug backend ou descrever request/response de falha.
- **Roteirização:** endpoint OSRM corporativo HTTPS ausente; em release a chamada externa fica desativada e o traçado por ruas permanece pendente.
- **Melhorias adiadas:** persistência de toggles de notificação (M16), telefone do motorista. O Caderno não foi editado.
- **Pendências Mobile adicionais:** comprovar restauração de sessão no HML; migrar tokens de `SharedPreferences` para armazenamento seguro; validar comportamento de background location e assinatura de distribuição em aparelho.
