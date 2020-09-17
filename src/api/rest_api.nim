import
    httpclient,
    json,
    strformat,
    strutils,
    uri

import domain


const RestApiUrl*: string = "https://api-invest.tinkoff.ru/openapi"


type MyException* = object of CatchableError


type RestClient* = object
    token*: string
    httpClient: HttpClient
    httpTimeout: int
    apiUrl*: string


proc newRestClientCustom*(token, apiUrl: string = ""): RestClient =
    var restClient: RestClient
    restClient = RestClient()
    restClient.token = token
    restClient.apiUrl = apiUrl
    restClient.httpTimeout = 30
    return restClient


proc newRestClient*(token: string): RestClient =
    return newRestClientCustom(token, RestApiUrl)


proc doRequest*(c: var RestClient, path: string = RestApiUrl,
        httpMethod: HttpMethod = HttpGet, body = ""): CustomResponse =
    c.httpClient = newHttpClient()
    c.httpClient.headers["Authorization"] = "Bearer " & c.token

    try:
        let rawResponse: Response = c.httpClient.request(path, httpMethod, body)
        echo path
        echo rawResponse.code
        var response: CustomResponse
        response.headers = rawResponse.headers
        response.code = rawResponse.code
        response.status = rawResponse.status
        response.body = rawResponse.body
        return response
    except ValueError as e:
        raise MyException.newException("\nInvalid response: " & e.msg)


proc instrumentByFIGI*(c: var RestClient, figi: string): (Instrument, Error) =
    let path = RestApiUrl & c.apiUrl & "/market/search/by-figi?figi=" & figi
    let response = c.doRequest(path)
    let payload = parseJson(response.body)["payload"]

    var resp: Instrument
    var err: Error

    if response.status != $Http200:
        return (resp, to(payload, Error))

    try:
        return (to(payload, Instrument), err)
    except ValueError as e:
        raise MyException.newException("Unmarshal error to Instrument" & ": " &
                e.msg & "\n" & pretty(payload))


proc instrumentByTicker*(c: var RestClient, ticker: string): (seq[Instrument], Error) =
    let path = RestApiUrl & c.apiUrl & "/market/search/by-ticker?ticker=" & ticker
    let response = c.doRequest(path)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Instruments: seq[Instrument]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Instruments, err)

    for elem in payload["instruments"]:
        try:
            resp.Instruments.add(to(elem, Instrument))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Instrument" &
                    ": " & e.msg & "\n" & pretty(elem))

    return (resp.Instruments, err)


proc instruments(c: var RestClient, path: string): (seq[Instrument], Error) =
    let response = c.doRequest(path)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Instruments: seq[Instrument]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Instruments, err)

    for elem in payload["instruments"]:
        try:
            resp.Instruments.add(to(elem, Instrument))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Instrument" &
                    ": " & e.msg & "\n" & pretty(elem))

    return (resp.Instruments, err)

proc currencies*(c: var RestClient): (seq[Instrument], Error) =
    let path = RestApiUrl & c.apiUrl & "/market/currencies"
    return c.instruments(path)

proc etfs*(c: var RestClient): (seq[Instrument], Error) =
    let path = RestApiUrl & c.apiUrl & "/market/etfs"
    return c.instruments(path)

proc stocks*(c: var RestClient): (seq[Instrument], Error) =
    let path = RestApiUrl & c.apiUrl & "/market/stocks"
    return c.instruments(path)

proc bonds*(c: var RestClient): (seq[Instrument], Error) =
    let path = RestApiUrl & c.apiUrl & "/market/bonds"
    return c.instruments(path)


proc operations*(c: var RestClient, accountID: string = "", fromTime: string,
        toTime: string, figi: string): (seq[Operation], Error) =
    var path: string = RestApiUrl & c.apiUrl & "/operations?"
    var query: seq[string] = @["", "", "", ""]

    if fromTime != "":
        query[0] = encodeQuery({"from": fromTime})

    if toTime != "":
        query[1] = encodeQuery({"to": toTime})

    if figi != "":
        query[2] = encodeQuery({"figi": figi})

    if accountID != DefaultAccount:
        query[3] = encodeQuery({"brokerAccountId": accountID})

    for key, elem in query:
        if elem.len != 0:
            if key == 0:
                path = path & elem
            else:
                path = path & "&" & elem

    let response = c.doRequest(path)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Operations: seq[Operation]
        Error: Error

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Operations, err)

    for elem in payload["operations"]:
        try:
            resp.Operations.add(to(elem, Operation))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Operation" &
                    ": " & e.msg & "\n" & pretty(elem))

    return (resp.Operations, err)


proc positionsPortfolio*(c: var RestClient, accountID: string): (seq[
        PositionBalance], Error) =
    var path = RestApiUrl & c.apiUrl & "/portfolio"

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Positions: seq[PositionBalance]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Positions, err)

    for elem in payload["positions"]:
        try:
            resp.Positions.add(to(elem, PositionBalance))
        except ValueError as e:
            raise MyException.newException(
                    "Unmarshal error to PositionBalance" & ": " & e.msg & "\n" &
                    pretty(elem))

    return (resp.Positions, err)

proc currenciesPortfolio*(c: var RestClient, accountID: string): (seq[
        CurrencyBalance], Error) =
    var path = RestApiUrl & c.apiUrl & "/portfolio/currencies"

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Currencies: seq[CurrencyBalance]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Currencies, err)

    for elem in payload["currencies"]:
        try:
            resp.Currencies.add(to(elem, CurrencyBalance))
        except ValueError as e:
            raise MyException.newException(
                    "Unmarshal error to CurrencyBalance" & ": " & e.msg & "\n" &
                    pretty(elem))

    return (resp.Currencies, err)

proc portfolio*(c: var RestClient, accountID: string): (Portfolio, Error) =
    let (positions, positionsErr) = c.positionsPortfolio(accountID)
    let (currencies, currenciesErr) = c.currenciesPortfolio(accountID)

    var portfolio: Portfolio
    var err: Error

    if positionsErr.code != "" and positionsErr.code != "200":
        #return (portfolio, positionsErr)
        err.code = positionsErr.code
        err.message = "positions error " & "(" & positionsErr.code & ") " &
                positionsErr.message

    portfolio.positions = positions

    if currenciesErr.code != "" and currenciesErr.code != "200":
        #return (portfolio, currenciesErr)
        err.message = err.message & " currencies error " & "(" &
                currenciesErr.code & ") " & currenciesErr.message

    if err.code != "" and err.code != "200":
        return (portfolio, err)

    portfolio.currencies = currencies

    return (portfolio, err)


proc orderCancel*(c: var RestClient, id: string,
        accountID: string = ""): Error =
    var path = RestApiUrl & c.apiUrl & "/orders/cancel?orderId=" & id

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    var err: Error

    let response = c.doRequest(path, HttpPost)
    let payload = parseJson(response.body)["payload"]

    if response.status != $Http200:
        err = to(payload, Error)
        return err

    return err


proc limitOrder*(c: var RestClient, accountID: string = "", figi: string,
        lots: int, operation: OperationType, price: float64): (PlacedOrder, Error) =
    var path = RestApiUrl & c.apiUrl & "/orders/limit-order?figi=" & figi

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    type OperationPayload = object
        lots: int
        operation: OperationType
        price: float64

    var operationPayload: OperationPayload
    operationPayload.lots = lots
    operationPayload.operation = operation
    operationPayload.price = price

    let response = c.doRequest(path, HttpPost, $(%operationPayload))
    let payload = parseJson(response.body)["payload"]

    var resp: PlacedOrder
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp, err)

    try:
        return (to(payload, PlacedOrder), err)
    except ValueError as e:
        raise MyException.newException("Unmarshal error to PlacedOrder" & ": " &
                e.msg & "\n" & pretty(payload))


proc marketOrder*(c: var RestClient, accountID: string = "", figi: string,
        lots: int, operation: OperationType): (PlacedOrder, Error) =
    var path = RestApiUrl & c.apiUrl & "/orders/market-order?figi=" & figi

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    type OperationPayload = object
        lots: int
        operation: OperationType

    var operationPayload: OperationPayload
    operationPayload.lots = lots
    operationPayload.operation = operation

    let response = c.doRequest(path, HttpPost, $(%operationPayload))
    let payload = parseJson(response.body)["payload"]

    var resp: PlacedOrder
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp, err)

    try:
        return (to(payload, PlacedOrder), err)
    except ValueError as e:
        raise MyException.newException("Unmarshal error to PlacedOrder" & ": " &
                e.msg & "\n" & pretty(payload))


proc orders*(c: var RestClient, accountID: string = ""): (seq[Order], Error) =
    var path = RestApiUrl & c.apiUrl & "/orders"

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Orders: seq[Order]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Orders, err)

    for elem in payload:
        try:
            resp.Orders.add(to(elem, Order))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Order" & ": " &
                    e.msg & "\n" & pretty(elem))

    return (resp.Orders, err)


proc candles*(c: var RestClient, fromTime, toTime: string,
        interval: CandleInterval, figi: string): (seq[Candle], Error) =
    var query: seq[string] = @["", "", "", ""]

    if fromTime != "":
        query[0] = encodeQuery({"from": fromTime})

    if toTime != "":
        query[1] = encodeQuery({"to": toTime})

    if interval != "":
        query[2] = encodeQuery({"interval": interval})

    if figi != "":
        query[3] = encodeQuery({"figi": figi})

    var path = RestApiUrl & c.apiUrl & "/market/candles?" & query[3] & "&" &
            query[0] & "&" & query[1] & "&" & query[2]

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Candles: seq[Candle]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        return (resp.Candles, to(payload, Error))

    for elem in payload["candles"]:
        try:
            resp.Candles.add(to(elem, Candle))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Candle" & ": " &
                    e.msg & "\n" & pretty(elem))

    return (resp.Candles, err)


proc orderbook*(c: var RestClient, figi: string, depth: int = 1): (
        RestOrderBook, Error) =
    var resp: RestOrderBook
    var err: Error

    if depth < 1 or depth > MaxOrderbookDepth:
        err.message = "Depth for Orderbook is out of range"
        return (resp, err)

    var query: seq[string] = @["", ""]

    query[0] = encodeQuery({"depth": $depth})
    query[1] = encodeQuery({"figi": figi})

    let path = RestApiUrl & c.apiUrl & "/market/orderbook?" & query[1] & "&" &
            query[0]

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    if response.status != $Http200:
        return (resp, to(payload, Error))

    try:
        return (to(payload, RestOrderBook), err)
    except ValueError as e:
        raise MyException.newException("Unmarshal error to RestOrderBook" &
                ": " & e.msg & "\n" & pretty(payload))


proc accounts*(c: var RestClient): (seq[Account], Error) =
    var path = RestApiUrl & c.apiUrl & "/user/accounts"

    let response = c.doRequest(path, HttpGet)
    let payload = parseJson(response.body)["payload"]

    type ReturnPayload = object
        Accounts: seq[Account]

    var resp: ReturnPayload
    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return (resp.Accounts, err)

    for elem in payload["accounts"]:
        try:
            resp.Accounts.add(to(elem, Account))
        except ValueError as e:
            raise MyException.newException("Unmarshal error to Account" & ": " &
                    e.msg & "\n" & pretty(elem))

    return (resp.Accounts, err)


type Payload = object
    code: string
    message: string

type TradingError = object
    trackingId: string
    status: string
    hint: string
    payload: Payload

proc showError(t: var TradingError): string =
    return fmt"TrackingID: {t.trackingId}, Status: {t.status}, Message: {t.payload.message}, Code: {t.payload.code}, Hint: {t.hint}"

proc NotEnoughBalance(t: var TradingError): bool =
    return t.payload.code == "NOT_ENOUGH_BALANCE"

proc InvalidTokenSpace(t: var TradingError): bool =
    return t.payload.message == "Invalid token scopes"
