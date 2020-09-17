# std (sys)
import
    marshal,
    json,
    strutils

# api (local)
import ../../src/api/domain as api_domain
import
    ../../src/api/rest_api,
    ../../src/api/sandbox_api

# tests (local)
import domain as test_domain


type TestClient* = RestClient

const
    isReference: string = "референс"
    isResponse: string = "фактическое"


proc createClient*(c: var TestClient, token: string, path: string): void =
    c = newRestClientCustom(token, path)

proc notifAssertion(c: var TestClient, target: JsonNode, reference: JsonNode,
        typeMatch: bool = false): void =
    if typeMatch == false:
        echo "Сравнение значений: " & $target &
                " равно референсу " & $reference
    else:
        echo "Сравнение типов: " & $target &
                " равно референсу " & $reference

proc notifChecking(c: var TestClient, target: auto, label: string = ""): void =
    echo "Источник: " & label & "\n" & $target & "\n"

proc notifTitle(c: var TestClient, title: string): void =
    echo "\n=====================================\n" & title & "\n====================================="

proc notifDivider(c: var TestClient): void =
    echo "-------------------------------------"

proc assertInstrumentByFIGI*(c: var TestClient, figi: string,
        negative: bool = false): void =
    var (resp, error) = c.instrumentByFIGI(figi)

    var refPayload: JsonNode
    var refError: JsonNode

    if error.message != "":
        refPayload = refEmptyInstrument
        refError = errorFigiNotFound
    else:
        refPayload = refInstrument
        refError = errorEmpty

    c.notifTitle("Получение инструмента по FIGI: \n/market/search/by-figi")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    for key, elem in %*resp:
        if key == "faceValue" or key == "minPriceIncrement":
            c.notifAssertion(elem, refPayload[key], true)
            doAssert elem.kind == refPayload[key].kind
        else:
            c.notifAssertion(elem, refPayload[key])
            doAssert elem == refPayload[key]

    c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertInstrumentByTicker*(c: var TestClient, figi: string): void =
    var (resp, error) = c.instrumentByTicker(figi)

    var refPayload: JsonNode = refInstrument
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение инструмента по тикеру: \n/market/search/by-ticker")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    for arrElem in %*resp:
        #c.notifChecking(arrElem, isResponse)
        for key, elem in arrElem:
            if key == "faceValue" or key == "minPriceIncrement":
                c.notifAssertion(elem, refPayload[key], true)
                doAssert elem.kind == refPayload[key].kind
            else:
                c.notifAssertion(elem, refPayload[key])
                doAssert elem == refPayload[key]

    c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertStocks*(c: var TestClient): void =
    var (resp, error) = c.stocks()

    var refPayload: JsonNode = refStocks
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка акций: \n/market/stocks")

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            # Пропускаем faceValue
            if k == "faceValue":
                echo "Пропускаем " & $k
                continue
            c.notifAssertion(elem[k], e, true)
            #doAssert elem[k] == e
            doAssert elem[k].kind == e.kind # Проверяем только типы
        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertEtfs*(c: var TestClient): void =
    var (resp, error) = c.etfs()

    var refPayload: JsonNode = refEtfs
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка ETF: \n/market/etfs")

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            # Пропускаем faceValue
            if k == "faceValue":
                echo "Пропускаем " & $k
                continue
            c.notifAssertion(elem[k], e, true)
            #doAssert elem[k] == e
            doAssert elem[k].kind == e.kind # Проверяем только типы
        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertBonds*(c: var TestClient): void =
    var (resp, error) = c.bonds()

    var refPayload: JsonNode = refBonds
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка облигаций: \n/market/bonds")

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            if k == "faceValue" or k == "minPriceIncrement":
                c.notifAssertion(elem[k], e, true)
                doAssert e.kind == elem[k].kind
            else:
                c.notifAssertion(elem[k], e)
                doAssert e == elem[k]

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertCurrencies*(c: var TestClient): void =
    var (resp, error) = c.currencies()

    var refPayload: JsonNode = refCurrencies
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка валютных пар: \n​/market​/currencies")

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:

            # Игнорируем isin и faceValue
            if k == "isin" or
            k == "faceValue":
                echo "Пропускаем " & $k
                continue

            c.notifAssertion(elem[k], e)
            doAssert elem[k] == e

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertOrderbook*(c: var TestClient, figi: string, depth: int = 1): void =
    var (resp, error) = c.orderbook(figi, depth)

    var refPayload: JsonNode = refOrderbook
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение стакана по FIGI: \n/market/orderbook")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    for key, elem in %*resp:

        # Пропускаем непостоянные значения
        if $key == "limitUp" or
        $key == "limitDown":
            echo "Пропускаем " & $key
            continue


        if key != "figi":
            c.notifAssertion(elem, refPayload[key], true)
            doAssert elem.kind == refPayload[key].kind
        else:
            c.notifAssertion(elem, refPayload[key])
            doAssert elem == refPayload[key]

    c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertAccounts*(c: var TestClient): void =
    var (resp, error) = c.accounts()

    var refPayload: JsonNode = refAccounts
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение брокерских счетов клиента: \n​/user/accounts")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            # Пропускаем непостоянные значения
            if $k == "brokerAccountId":
                echo "Пропускаем " & $k
                continue

            c.notifAssertion(elem[k], e)
            doAssert elem[k] == e

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertCandles*(c: var TestClient, fromTime, toTime: string,
        interval: CandleInterval, figi: string): void =
    var (resp, error) = c.candles(fromTime, toTime, interval, figi)

    var refPayload: JsonNode = refCandle
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение исторических свечей по FIGI: \n​/market/candles")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            if k == "o" or k == "c" or k == "h" or k == "l" or k == "v":
                c.notifAssertion(elem[k], e, true)
                doAssert e.kind == elem[k].kind
            else:
                c.notifAssertion(elem[k], e)
                doAssert elem[k] == e

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertOrders*(c: var TestClient, accountID: string = ""): void =
    var (resp, error) = c.orders(accountID)

    var refPayload: JsonNode = refOrders
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка активных заявок: \n​/orders")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            c.notifAssertion(elem[k], e)
            doAssert elem[k] == e

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertOperations*(c: var TestClient, accountID: string = "",
        fromTime: string, toTime: string, figi: string): void =
    var (resp, error) = c.operations(accountID, fromTime, toTime, figi)

    var refPayload: JsonNode = emptyPayload
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение списка операций: \n​​/operations")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    var i: int = 0
    for elem in refPayload:

        c.notifChecking(elem, isReference)
        c.notifChecking(%*resp[i], isResponse)

        for k, e in %*resp[i]:
            c.notifAssertion(elem[k], e)
            doAssert elem[k] == e

        i = i + 1
        c.notifDivider()

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]


proc assertMarketOrder*(c: var TestClient, accountID: string = "", figi: string,
        lots: int, operation: OperationType): void =
    var (resp, error) = c.marketOrder(accountID, figi, lots, operation)

    var refPayload: JsonNode = refAccounts
    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение брокерских счетов клиента: \n​/user/accounts")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    if error.code == "NOT_ENOUGH_BALANCE":
        refError = errorNotEnoughBalance
    else:
        refError = errorEmpty

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]

    #TODO: доделать resp


proc assertLimitOrder*(c: var TestClient, accountID: string = "", figi: string,
        lots: int, operation: OperationType, price: float64): void =
    var (resp, error) = c.limitOrder(accountID, figi, lots, operation, price)

    var refPayload: JsonNode = refAccounts
    var refError: JsonNode

    c.notifTitle("Создание лимитной заявки: \n/orders/limit-order")

    c.notifChecking(refPayload, isReference)
    c.notifChecking(%*resp, isResponse)

    if error.code == "VALIDATION_ERROR":
        refError = errorLimitOrder
    else:
        refError = errorEmpty

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        if key == "message":
            c.notifAssertion(elem, refError[key])
            doAssert elem.kind == refError[key].kind
        else:
            doAssert elem == refError[key]

    #TODO: доделать resp


proc assetsOrderCancel*(c: var TestClient, id: string,
        accountID: string = ""): void =
    var error = c.orderCancel(id, accountID)

    var refError: JsonNode = errorEmpty

    c.notifTitle("Получение брокерских счетов клиента: \n​/user/accounts")

    if error.code == "ORDER_ERROR":
        refError = errorWrongOrderId
    else:
        refError = errorEmpty

    c.notifChecking(refError, isReference)
    c.notifChecking(%*error, isResponse)

    for key, elem in %*error:
        c.notifAssertion(elem, refError[key])
        doAssert elem == refError[key]
