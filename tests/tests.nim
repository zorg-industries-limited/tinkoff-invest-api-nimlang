import parsecfg

import 
    ../src/api/domain,
    ../src/api/sandbox_api,
    ../src/api/rest_api

import api/test_api


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

    # Создаем тест-клиента
    var tests: TestClient
    tests.createClient(token, "/sandbox")

    # Операции заявок
    tests.assertOrders()
    tests.assertMarketOrder("", "BBG00PNLY692", 1, BUY)
    tests.assertLimitOrder("", "BBG00PNLY692", 1, BUY, 1)
    tests.assetsOrderCancel("WRONGORDERID")

    # Получение информации по бумагам
    tests.assertInstrumentByFIGI("BBG00PNLY692") # тестировать только на Бондах
    tests.assertInstrumentByFIGI("WRONGFIGI")
    tests.assertInstrumentByTicker("RU000A100DC4")
    tests.assertStocks()
    tests.assertETFs()
    tests.assertBonds()
    tests.assertCurrencies()
    tests.assertCandles("2020-04-17T18:38:33.131642+03:00",
                        "2020-06-19T18:38:33.131642+03:00",
                        CandleInterval1Month,
                        "BBG00PNLY692")

    tests.assertOrderbook("BBG00PNLY692", 1)

    # Получение информации по операциям
    tests.assertOperations("",
                           "2020-04-17T18:38:33.131642+03:00",
                           "2020-06-19T18:38:33.131642+03:00",
                           "BBG00PNLY692")

    # Получение информации по брокерским счетам
    tests.assertAccounts()

    # Удаление счета
    echo ti.remove(accountId)