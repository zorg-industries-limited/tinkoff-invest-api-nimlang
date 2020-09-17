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
    echo ti.remove(accountId)
