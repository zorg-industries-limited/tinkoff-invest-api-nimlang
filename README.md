## Реализация для [Тинькофф Инвестиции OpenAPI](https://tinkoffcreditsystems.github.io/invest-openapi/ "Тинькофф Инвестиции") на языке [Nim](https://nim-lang.org/ "Nim")

#### ⚠️ Внимание

- Покрытие тестами не полное.
- Работоспособность проверялалсь только на Windows.
- Автор ничего на языке Nim до этого не писал, так что "вы держитесь здесь, вам всего доброго..."

Данный код написан на основе официальной [реализации на языке Go](https://github.com/TinkoffCreditSystems/invest-openapi-go-sdk "реализации на языке Go").
Поддерживается пока только rest, без streams.

#### Установка

Клонируйте репо:

```bash
git clone https://github.com/keshon/tinkoff-nimfest-api.git
```

Переименуйте **example.token.conf** в **token.conf** и укажите в нем свой API токен от Тинькофф Ивестиции в следующем формате (о получении токена можно узнать [здесь](https://tinkoffcreditsystems.github.io/invest-openapi/auth/)

Для запуска примера выполните следующую команду в терминале (в корне проекта):
```bash
nimble erun
```

Для тестов:
```bash
nimble trun
```

#### Методы

[Официальный OpenAPI](https://tinkoffcreditsystems.github.io/invest-openapi/swagger-ui/ "Официальный OpenAPI")


| Описание | Метод (без типов) |
| - | - |
| Создание клиента | newRestClient(token) |
| Создание клиента в sandbox | newSandboxClient(token) |
| Регистрация клиента в sandbox | register(accountType) |
| Выставление баланса по валютным позициям | setCurrencyBalance(accountID, currency, balance) |
| Выставление баланса по инструментным позициям | setPositionsBalance(accountID, figi, balance) |
| Удаление счета | remove(accountID) |
| Удаление всех позиций | clear(accountID) |
| Получение инструмента по FIGI | instrumentByFIGI(figi) |
| Получение инструмента по тикеру | instrumentByTicker(ticker) |
| Получение списка валютных пар | currencies() |
| Получение списка ETF | etfs() |
| Получение списка акций | stocks() |
| Получение списка облигаций | bonds() |
| Получение списка операций | operations(accountID, fromTime, toTime, figi) |
| Получение портфеля клиента | positionsPortfolio(accountID) |
| Получение валютных активов клиента | currenciesPortfolio(accountID) |
| Получение портфеля и валютных активов клиента | portfolio(accountID) |
| Отмена заявки | orderCancel(id, accountID) |
| Создание лимитной заявки | limitOrder(accountID, figi, lots, operation, price) |
| Создание рыночной заявки | marketOrder(accountID, figi, lots, operation) |
| Получение списка активных заявок | orders(accountID) |
| Получение исторических свечей по FIGI | candles(fromTime, toTime, interval, figi) |
| Получение стакана по FIGI | orderbook(figi, depth) |
| Получение брокерских счетов клиента | accounts() |

#### Пример
```
import parsecfg

import
    api/domain,
    api/sandbox_api,
    api/rest_api


when isMainModule:

    # Считываем токен из конфига:
    let config = loadConfig("token.conf")
    let token = config.getSectionValue("", "TOKEN")

    # Создаем клиента
    var ti: RestClient
    ti = newSandboxClient(token)

    # Регистрация клиента в sandbox
    var (resp, err) = ti.register(AccountTinkoff)
    let accountId = resp.brokerAccountId

    # Получение брокерских счетов клиента
    echo ti.accounts()[0] # [0] - содержимое ответа, [1] - содержимое ошибки

    # Выставление баланса по валютным позициям
    echo ti.setCurrencyBalance(accountId, RUB, 1000.0)

    # Выставление баланса по инструментным позициям
    echo ti.setPositionsBalance(accountId, "BBG00PNLY692", 10.0)

    # Получение портфеля клиента
    echo ti.positionsPortfolio(accountId)[0]

    # Удаление всех позиций
    echo ti.clear(accountId)

    # Удаление счета
    #echo ti.remove(accountId)
```

### Дополнительно
Во время запуска (примера или тестов) создается тестовый счет, который после завершения удаляется автоматически.