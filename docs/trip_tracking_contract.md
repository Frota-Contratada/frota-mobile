# Contrato mobile ↔ frota-acompanhamento

O mobile é a fonte de autenticação, snapshot da corrida, GPS e eventos em tempo
real. O webapp continua estático e não recebe JWT, chaves, coordenadas ou dados
pessoais pela URL. A única query string adicionada pelo mobile é `role`, com
valor `driver` ou `passenger`.

## Bootstrap e transporte

Ao terminar o carregamento, o Flutter define `window.FrotaNativeContext` e
dispara `flutter.context` contendo somente `{ schemaVersion, tripId }`. Isso
permite que a página estática monte o envelope de readiness sem expor o ID na
URL. Em seguida, o webapp deve publicar no canal JavaScript do Flutter:

```js
FlutterTripBridge.postMessage(JSON.stringify({
  schemaVersion: 1,
  type: 'web.ready',
  eventId: crypto.randomUUID(),
  tripId: window.FrotaNativeContext.tripId,
  sentAt: new Date().toISOString(),
  payload: {}
}));
```

O `tripId` é obtido desse contexto nativo; ele não deve ser lido da URL. Depois
de `web.ready`, o Flutter despacha `CustomEvent` no nome
`flutter.trip`, com o envelope em `event.detail`. Como compatibilidade, também
chama `window.FrotaTripBridge.onMessage(envelope)` quando a função existir.

Todos os envelopes usam `schemaVersion`, `type`, UUID em `eventId`, `tripId`,
`sentAt` UTC e `payload`. O mobile rejeita versões, tipos, corridas e payloads
inválidos. O webapp deve fazer a mesma validação.

Tipos Flutter → Web: `trip.bootstrap`, `vehicle.location`,
`passenger.location`, `route.replaced`, `trip.statusChanged`,
`waiting.changed`, `connection.changed`, `command.succeeded` e
`command.failed`.

Tipos Web → Flutter: `web.ready`, `route.rerouteRequested`,
`waiting.confirmed`, `waiting.resumeRequested`, `trip.finishRequested` e
`web.log`.

## Regras de papel

- Somente `driver` pode solicitar recálculo, iniciar/encerrar espera e finalizar.
- `passenger.location` nunca move o veículo, avança rota ou altera heading.
- O passageiro recebe o veículo somente por `vehicle.location` do backend.
- `route.replaced` só é aplicado quando `version` for maior que a atual.
- `vehicle.location` atrasada é descartada pelo timestamp.

A rota canônica sempre inclui `instructions`. Cada item contém `id`, texto em
`instruction`, `streetName`, `distanceMeters`, `durationSeconds`, `type`,
`modifier`, `icon`, `location { lat, lng }` e `coordinateIndex`. Assim, desenho,
manobra ativa, voz e recálculo usam exatamente a mesma rota versionada; o
webapp não deve consultar outro provedor de rotas.

O GPS nativo alimenta a WebView entre 500 ms e 1 segundo, inclusive com um
heartbeat periódico quando o veículo está parado. O envio REST/Socket ao
backend é reduzido para um ponto mais recente a cada 4 segundos, e posições
offline continuam sendo persistidas para envio em lote.

## Contrato esperado do backend

Os caminhos abaixo estão isolados em `TripTrackingRemoteDatasource` e podem ser
adaptados quando a API real for publicada:

- `GET /corridas/:id/tracking`: snapshot completo, no formato do payload de
  `trip.bootstrap` (sem o campo `role`, que é definido pelo mobile).
- `POST /corridas/:id/tracking/positions/batch`: `{ positions: [...] }`.
- `POST /corridas/:id/tracking/passenger-position`: posição local auxiliar.
- `POST /corridas/:id/route/reroute`: posição atual; retorna rota canônica já
  persistida com `routeId` e `version` incrementada.
- `POST /corridas/:id/waiting/start` e `/waiting/resume`: retornam
  `{ active, startedAt }`.
- `POST /corridas/:id/finish`: finalização idempotente.

Todos os quatro endpoints de comando (`reroute`, `waiting/start`,
`waiting/resume` e `finish`) recebem o mesmo UUID do envelope web no header
`Idempotency-Key`. O backend deve guardar o resultado por corrida/chave e
devolver o mesmo resultado em uma repetição, sem executar o efeito novamente.

Socket.io usa autenticação no header `Authorization` durante o handshake e entra
na corrida por `trip.join { tripId, role }`. O mobile só considera a conexão
pronta depois do acknowledgement desse comando ou do evento
`trip.joined { tripId }`; a simples conexão do transporte não é suficiente.
Depois disso, publica `vehicle.location` ou `passenger.location` e recebe
envelopes em `trip.event`. O backend deve aplicar autorização por
usuário/corrida, ordenar posições, distribuir a mesma rota aos dois papéis e
tornar comandos idempotentes por `eventId`.

No início, o mobile registra os listeners e entra em `trip.join` antes de buscar
o snapshot. Eventos recebidos durante essa busca ficam em memória e são
reaplicados após o snapshot. Quando a conexão é recuperada, um novo snapshot é
carregado e reconciliado com posições e versões mais recentes, fechando a
janela entre REST e Socket.io.

Enquanto esses endpoints/eventos não existem, `TRIP_TRACKING_MOCK=true` ativa
snapshot, rota versionada, espera e recálculo locais. O mock serve apenas para
desenvolvimento; produção deve configurar `false`.

## Desenvolvimento e segurança

`TRIP_WEBAPP_URL` aceita `http://10.0.2.2:5173` no emulador Android ou o IP da
máquina em aparelho físico. Cleartext é liberado somente no manifest Android
debug e na configuração iOS Debug; release exige HTTPS. A navegação permanece
restrita à mesma origem (scheme, host e porta) configurada.

O aplicativo empacota somente os padrões não sensíveis de `.env.example`.
Ambientes de CI/release devem substituir URLs com `--dart-define`, por exemplo
`--dart-define=TRIP_WEBAPP_URL=https://acompanhamento.exemplo.com`; tokens e
chaves nunca devem ser incluídos nesse arquivo.

Em debug, o ícone de inseto na `TripWebViewPage` abre controles de posição,
velocidade, heading, desvio, recálculo, espera, conexão, afastamento do
passageiro e uma lista de tipos de mensagens sem payloads sensíveis.
