# app-frota-seara

App mobile em Flutter para o passageiro e motorista.

## Configuração HML

O workflow `Mobile HML` (somente disparo manual na `main`) e `scripts/build-hml.ps1` usam os mesmos `dart-define`:

| Variável | Valor HML |
| --- | --- |
| `BASE_URL` | `https://api-frota-contratada-hml.seara.com.br` |
| `TRIP_WEBAPP_URL` | `https://frota-contratada-hml.seara.com.br/acompanhamento` |
| `TRIP_SOCKET_URL` | `https://api-frota-contratada-hml.seara.com.br` |
| `TRIP_TRACKING_BASE_URL` | `https://api-frota-contratada-hml.seara.com.br/corridas` |

Esses valores são para builds HML futuros. Não gerar nem distribuir APK antes da liberação do ambiente.
