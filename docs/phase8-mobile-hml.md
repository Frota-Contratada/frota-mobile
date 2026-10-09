# Fase 8 — Mobile HML (auditoria em 2026-10-09)

## Estado e limites da execução

- Base oficial revalidada: `github/main` em `9399d49908bb6973e64ea987dfe964ce52ca472e`. A branch `phase8/mobile-hml-main` foi criada dessa base e recebeu apenas o cherry-pick do delta da Fase 8 (`3ca727a`). A referência `phase8/backup-3ca727a` preserva o commit anterior. O commit exclusivo de `tracking` (`6314fa5`, detalhes de paradas) não foi incorporado; nenhuma alteração da Fase 8 depende dele.
- Flutter 3.47.2, Dart 3.13.2, SDK `^3.11.5`; Android `minSdk 24`, `compileSdk` e `targetSdk` do Flutter, Java 17 no projeto, Gradle 8.14, AGP 8.11.1. Não há flavors. CI original `checks-warning.yml` não bloqueia falhas; `mobile-hml.yml` adiciona gate e APK release.
- HML usa `BASE_URL=https://api.frota-contratada.hml.seara.com.br`, `TRIP_WEBAPP_URL=https://frota-contratada.hml.seara.com.br/acompanhamento`, `TRIP_SOCKET_URL=https://api.frota-contratada.hml.seara.com.br`, `TRIP_TRACKING_BASE_URL=https://api.frota-contratada.hml.seara.com.br/corridas`. São `dart-define`; não há credenciais no build.
- Paths conferidos no `RouterModule` e controllers do backend: `/autenticacao`, `/usuario/info/me`, `/motorista/viagens`, `/motorista/corridas`, `/motorista/perfil`, `/solicitacoes`, `/centro-de-custo` e `/corridas/:id/{tracking,tracking/positions/batch,tracking/passenger-position,route/reroute,waiting/start,waiting/resume,finish}`. Conferência de código, sem chamada HML autenticada.
- `TripTrackingMockDatasource` e `NoopTripTrackingSocketDatasource` são injetados apenas quando `kDebugMode && TRIP_TRACKING_MOCK`; release usa HTTP e Socket.IO reais. `CorridaRemoteDatasourceMock` e `AuthRemoteDatasourceMock` existem, mas a injeção usa implementações reais. Testes existentes cobrem bridge, join, idempotência e navegação; não comprovam HML.
- Tokens access, refresh, PIN e usuário são gravados em `SharedPreferences` (sem armazenamento criptografado). Logout das duas telas foi corrigido para chamar `LogoutUsecase`, que remove essas chaves e posições em buffer antes de limpar a pilha de navegação. A inicialização agora consulta `/usuario/info/me` quando há token salvo e restaura a home correspondente se o servidor confirmar a sessão. O comportamento real em HML ainda precisa de aparelho; armazenamento criptografado continua pendente.
- WebView usa `role=driver|passenger`, handshake de `tripId`, bloqueia navegação fora da mesma origem, recarrega após erro de documento principal e abre Waze/Google Maps por `url_launcher`. Fluxo real permanece pendente. Socket.IO usa transporte WebSocket, token no cabeçalho, join com confirmação e reconexão. Tracking usa buffer, posição de passageiro, idempotência em comandos e geolocalização. O manifesto declara localização fina, aproximada e background; o driver solicita rastreamento em background com notificação foreground. Permissões precisam ser verificadas em Android real.
- Caderno oficial somente lido: SHA256 `C58E48AE94806077EB3169DEC81041E8C710C07B168412F09560388CCE7C5F72`, 88.035 bytes; sem alteração nesta sessão.

- Entrega CI: APK `frota-mobile-hml-09b8ecee1f72.apk`, source SHA `09b8ecee1f72228981207aecb9347d66f271b8d0`, release, 89.215.019 bytes, SHA256 `273094fc04916faa742b74a93419ef225c6ad378277a34f52f924cd8f97ae22a` (recalculado do APK extraído). Flutter 3.47.2, Dart 3.13.2, Java 17. Mobile Checks e Mobile HML passaram: pub get, analyze 0 problemas, test 23/23 e build release. O build local expirou no download do Gradle; o CI produziu o APK.
- Assinatura: `android/app/build.gradle.kts` seleciona `signingConfigs.getByName("debug")` para `buildTypes.release`. O workflow usa a chave debug padrão do Android no runner; não há keystore HML dedicada. Uma versão futura assinada com outra chave não poderá atualizar esta instalação diretamente e poderá exigir desinstalação. Nenhuma chave nova foi criada/versionada.
- Segurança release: `TRIP_TRACKING_MOCK` só ativa mocks em debug. Release usa datasources HTTP e Socket.IO reais. `AndroidManifest.xml` principal define `usesCleartextTraffic="false"`; a permissão de cleartext existe só no manifesto debug. `Env.validateRelease` exige HTTPS nos quatro endpoints; não há bypass TLS. Confiança da cadeia no aparelho JBS permanece pendente; timeout de rede nesta estação não comprova falha TLS.
- OSRM: sem `OSRM_BASE_URL` corporativo HTTPS, `Env.osrmBaseUrl` retorna vazio em release e nenhuma coordenada vai para `router.project-osrm.org`. O `AppMapWidget` liga os pontos por linhas retas quando não recebe geometria de rota. Assim, a prévia de rota por ruas em M7/M11 fica pendente, embora cadastro/envio não dependa desse cálculo local. Solução corporativa fica para a Fase 9 e não bloqueia o APK.
- PR #16 publicou o código base `09b8ecee1f72228981207aecb9347d66f271b8d0`. Os quatro endpoints HML estão nos `dart-define` do workflow/script, sem secrets.

## Matriz dos 26 testes oficiais

Estados: `PASS_STATIC` = cenário completo comprovado por inspeção; `PASS_UNIT` = cenário completo coberto por teste; `JBS_NETWORK_REQUIRED` = API/Web HML real necessária; `DEVICE_REQUIRED` = GPS, background, WebView ou navegação física; `BLOCKED_EMAIL` = caixa real necessária; `KNOWN_LIMITATION` = divergência conhecida. Nenhum cenário HML completo recebe PASS sem execução real. Testes unitários de partes do fluxo não tornam o cenário oficial PASS. API é contrato esperado, não chamada HML observada.

| ID | Perfil | Pré-condição / ação | API esperada | Classe | Status | Resultado e causa |
|---|---|---|---|---|---|---|
| M1 | Passageiro/Motorista | Contas cadastradas; login válido | `GET /autenticacao/primeiro-acesso/:email`, `POST /autenticacao/login`, `GET /usuario/info/me` | Emulador | JBS_NETWORK_REQUIRED | Sem acesso HML/credencial nesta sessão. |
| M2 | Passageiro/Motorista | Conta cadastrada; senha incorreta | `GET /autenticacao/primeiro-acesso/:email`, `POST /autenticacao/login` | Emulador | JBS_NETWORK_REQUIRED | Erro real ainda não observado. |
| M3 | Passageiro/Motorista | Email inexistente | `GET /autenticacao/primeiro-acesso/:email` | Emulador | JBS_NETWORK_REQUIRED | Erro real ainda não observado. |
| M4 | Passageiro/Motorista | Email vazio; avançar | nenhuma | Emulador | KNOWN_LIMITATION | Inspeção de código: email vazio retorna sem mostrar erro de campo obrigatório. Diverge do esperado; correção Mobile posterior. |
| M5 | Passageiro/Motorista | Senha vazia; avançar | nenhuma | Emulador | KNOWN_LIMITATION | Inspeção de código: senha vazia é enviada sem validação local de campo obrigatório. Resposta HML não observada; correção Mobile posterior. |
| M6 | Passageiro/Motorista | Primeiro acesso; confirmação diferente | `POST /autenticacao/pin/enviar`, `POST /autenticacao/pin/confirmar` | Emulador | BLOCKED_EMAIL | Contas fictícias @frota.com.br não recebem PIN em caixa real; nenhum bypass. |
| M7 | Passageiro | Autenticado; solicitar pelo mapa | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Criação real pendente; mapa sem traçado por ruas enquanto não houver OSRM corporativo. |
| M8 | Passageiro | Autenticado; solicitar pelo widget | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Criação real pendente. |
| M9 | Passageiro | Autenticado; transporte de objetos | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Criação real pendente. |
| M10 | Passageiro | Viagens futuras; filtrar semana | `GET /solicitacoes/viagens` | Emulador | JBS_NETWORK_REQUIRED | Requer fixture transacional da Fase 7. |
| M11 | Passageiro | Formulário válido; várias paradas | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Persistência real pendente; prévia do mapa sem traçado por ruas. |
| M12 | Passageiro | Permissão de emergência; solicitar | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Permissão/regra de emergência da conta Passageiro precisa ser confirmada antes do teste; não presumir autorização. |
| M13 | Passageiro | Formulário válido; acompanhantes | catálogos e `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Criação real pendente. |
| M14 | Passageiro | Formulário válido; múltiplos centros de custo | `GET /centro-de-custo`, `POST /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Criação real pendente. |
| M15 | Passageiro | Solicitações existentes; filtrar | `GET /solicitacoes` | Emulador | JBS_NETWORK_REQUIRED | Requer fixture transacional da Fase 7. |
| M16 | Passageiro | Autenticado; alterar notificações | nenhuma | Emulador | KNOWN_LIMITATION | Toggles só mudam em memória; preferência não persiste após reabrir. Melhoria pós-MVP aprovada. |
| M17 | Passageiro | Autenticado; sair | limpeza local | Emulador | JBS_NETWORK_REQUIRED | Limpeza de sessão coberta por teste unitário; fluxo autenticado completo no aparelho JBS ainda pendente. |
| M18 | Passageiro/Motorista | Corrida iniciada; localização em tempo real | `GET /corridas/:id/tracking`, Socket.IO, posições | Aparelho físico | DEVICE_REQUIRED | Exige corrida real, GPS e celular na rede JBS. |
| M19 | Motorista | Autenticado; cards agendados | `GET /motorista/viagens` | Emulador | JBS_NETWORK_REQUIRED | Requer fixture transacional da Fase 7. |
| M20 | Motorista | Corrida alocada; iniciar | `POST /motorista/corridas/:id/iniciar`, tracking | Emulador | JBS_NETWORK_REQUIRED | Corrida real pendente; não há botão separado de aceitar no app. |
| M21 | Motorista | Corrida em andamento; pausa | `POST /corridas/:id/waiting/start` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real, WebView e celular na rede JBS. |
| M22 | Motorista | Corrida em espera; retomar | `POST /corridas/:id/waiting/resume` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real, WebView e celular na rede JBS. |
| M23 | Motorista | Corrida em andamento; finalizar | `POST /corridas/:id/finish` | Aparelho físico | DEVICE_REQUIRED | Exige corrida real, WebView e celular na rede JBS. |
| M24 | Motorista | Autenticado; perfil | `GET /motorista/perfil` | Emulador | JBS_NETWORK_REQUIRED | Resposta real pendente. |
| M25 | Motorista | Corridas finalizadas; filtrar histórico | `GET /motorista/viagens` | Emulador | JBS_NETWORK_REQUIRED | Requer fixture transacional da Fase 7. |
| M26 | Motorista | Disponível; fluxo completo | iniciar, tracking, finish | Aparelho físico | DEVICE_REQUIRED | Exige corrida real, GPS e rede JBS. “Aceitar” é termo do Caderno; o app usa iniciar, sem botão separado. Caderno preservado. |

## Roteiro curto para o cliente no celular JBS

**Dependência de rede JBS:** o celular precisa acessar API e Web HML pela rede/VPN corporativa. Registrar erros sem expor senha ou token.

1. Conferir SHA256 acima, instalar o APK em Android API 24+ e abrir; verificar tela de login e ausência de erro TLS.
2. Entrar como Passageiro; listar dados, criar uma solicitação e confirmar a listagem e os detalhes.
3. Fazer logout; entrar como Motorista; visualizar corrida alocada, permitir GPS preciso e iniciar corrida.
4. Conferir tracking e acompanhamento/WebView nos dois perfis. Colocar em background, retomar e observar reconexão/notificação foreground.
5. Abrir Google Maps ou Waze pelo app e conferir o destino; finalizar corrida.
6. Fazer logout em ambos os perfis; fechar/reabrir e verificar que a sessão encerrada não reaparece. Confirmar que Back não volta à área autenticada.
7. Se testar upgrade, usar APK com a mesma assinatura; outra chave poderá exigir desinstalação.

**Limitações conhecidas:** M4/M5 não validam campo obrigatório localmente; M16 não persiste preferências; M6 depende de caixa real; sem OSRM corporativo, mapa local não traça por ruas. **Pendente no aparelho:** TLS, login, GPS/background, tracking, WebView, navegação externa e logout completo. M12 depende da regra/permissão de emergência da conta.

## Dependências e melhorias

- **DEPENDÊNCIA FASE 7 / BACKEND:** fixtures de corridas e solicitações para M10, M15, M18–M23, M25 e M26. Não houve resposta HML observada que permita afirmar bug backend ou descrever request/response de falha.
- **Roteirização:** endpoint OSRM corporativo HTTPS ausente; em release não há chamada pública, e a prévia local de rota por ruas em M7/M11 mostra apenas segmentos retos. Não bloqueia o APK.
- **Melhorias adiadas:** persistência de toggles de notificação (M16), telefone do motorista. O Caderno não foi editado.
- **Pendências Mobile adicionais:** comprovar restauração de sessão no HML; migrar tokens de `SharedPreferences` para armazenamento seguro; validar comportamento de background location e assinatura de distribuição em aparelho.
