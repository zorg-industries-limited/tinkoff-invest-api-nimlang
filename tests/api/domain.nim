import json

#[
type CandleInterval* = string

const CandleInterval1Month*: CandleInterval = "month"


type OperationType* = string

const BUY*: OperationType = "Buy"
]#

var errorEmpty*: JsonNode = parseJson("""
    {
        "message":"",
        "code":""
    }
""")

var errorFigiNotFound*: JsonNode = parseJson("""
    {
        "message": "Cannot find market instrument by figi",
        "code": "NOT_FOUND"
    }
""")

var errorInstrumentNotFound*: JsonNode = parseJson("""
    {
        "message": "[figi]: Instrument not found by figi=WRONGFIGI",
        "code": "VALIDATION_ERROR"
    }
""")

var errorLimitOrder*: JsonNode = parseJson("""
    {
        "message": "[price]: 1.0 has invalid scale, minPriceIncrement=0.095834",
        "code": "VALIDATION_ERROR"
    }
""")


var errorWrongOrderId*: JsonNode = parseJson("""
    {
        "message":"Cannot find order by id WRONGORDERID",
        "code":"ORDER_ERROR"
    }
""")


var errorNotEnoughBalance*: JsonNode = parseJson("""
    {
        "message": "Cannot process request, not enough balance on security=RUB",
        "code": "NOT_ENOUGH_BALANCE"
    }
""")


var emptyPayload*: JsonNode = parseJson("""
    []
""")

var refEmptyInstrument*: JsonNode = parseJson("""
    {
        "figi":"",
        "ticker":"",
        "isin":null,
        "name":"",
        "minPriceIncrement":null,
        "lot":0,
        "faceValue":null,
        "currency":"",
        "type":""
    }
""")

var refInstrument*: JsonNode = parseJson("""
    {
        "figi": "BBG00PNLY692",
        "ticker": "RU000A100DC4",
        "isin": "RU000A100DC4",
        "minPriceIncrement": 0.095834,
        "faceValue": 958.34,
        "lot": 1,
        "currency": "RUB",
        "name": "МСБ-Лизинг 002P выпуск 2",
        "type": "Bond"
    }
""")

var refStocks*: JsonNode = parseJson("""
    [
        {
            "figi": "BBG000HLJ7M4",
            "ticker": "IDCC",
            "isin": "US45867G1013",
            "minPriceIncrement": 0.01,
            "lot": 1,
            "currency": "USD",
            "name": "InterDigItal Inc",
            "type": "Stock"
        },
        {
            "figi": "BBG002293PJ4",
            "ticker": "RH",
            "isin": "US74967X1037",
            "minPriceIncrement": 0.01,
            "lot": 1,
            "currency": "USD",
            "name": "RH",
            "type": "Stock"
        },
        {
            "figi": "BBG000BPL8G3",
            "ticker": "MTSC",
            "isin": "US5537771033",
            "minPriceIncrement": 0.01,
            "lot": 1,
            "currency": "USD",
            "name": "MTS Systems Corp",
            "type": "Stock"
        }
    ]
""")

var refEtfs*: JsonNode = parseJson("""
    [
        {
            "figi": "BBG005DXDPK9",
            "ticker": "FXGD",
            "isin": "IE00B8XB7377",
            "minPriceIncrement": 0.2,
            "lot": 1,
            "currency": "RUB",
            "name": "FinEx Золото",
            "type": "Etf"
        },
        {
            "figi": "BBG00NB6KGN0",
            "ticker": "SBCB",
            "isin": "RU000A1000Q6",
            "minPriceIncrement": 0.01,
            "lot": 1,
            "currency": "USD",
            "name": "Сбербанк Индекс Еврооблигаций",
            "type": "Etf"
        },
        {
            "figi": "BBG00PVNWQ15",
            "ticker": "VTBE",
            "isin": "RU000A100HQ5",
            "minPriceIncrement": 0.01,
            "lot": 1,
            "currency": "USD",
            "name": "ВТБ Акции развивающихся рынков",
            "type": "Etf"
        }
    ]
"""
)

var refBonds*: JsonNode = parseJson("""
    [
        {
            "figi": "BBG00R05JT04",
            "ticker": "RU000A1013Y3",
            "isin": "RU000A1013Y3",
            "minPriceIncrement": 0.1,
            "faceValue": 1000.0,
            "lot": 1,
            "currency": "RUB",
            "name": "Черкизово выпуск 2",
            "type": "Bond"
        },
        {
            "figi": "BBG00PNLY692",
            "ticker": "RU000A100DC4",
            "isin": "RU000A100DC4",
            "minPriceIncrement": 0.095834,
            "faceValue": 958.34,
            "lot": 1,
            "currency": "RUB",
            "name": "МСБ-Лизинг 002P выпуск 2",
            "type": "Bond"
        },
        {
            "figi": "BBG00KHGQP89",
            "ticker": "RU000A0ZZ1F6",
            "isin": "RU000A0ZZ1F6",
            "minPriceIncrement": 0.1,
            "faceValue": 1000.0,
            "lot": 1,
            "currency": "RUB",
            "name": "КарМани выпуск 2",
            "type": "Bond"
        }
    ]
""")

var refCurrencies*: JsonNode = parseJson("""
    [
        {
            "figi": "BBG0013HGFT4",
            "ticker": "USD000UTSTOM",
            "minPriceIncrement": 0.0025,
            "lot": 1000,
            "currency": "RUB",
            "name": "Доллар США",
            "type": "Currency"
        },
        {
            "figi": "BBG0013HJJ31",
            "ticker": "EUR_RUB__TOM",
            "minPriceIncrement": 0.0025,
            "lot": 1000,
            "currency": "RUB",
            "name": "Евро",
            "type": "Currency"
        }
    ]
""")

var refOrderbook*: JsonNode = parseJson("""
    {
        "figi": "BBG00PNLY692",
        "depth": 1,
        "tradeStatus": "NotAvailableForTrading",
        "minPriceIncrement": 0.095834,
        "faceValue": 958.34,
        "lastPrice": 958.148332,
        "closePrice": 958.148332,
        "bids": [],
        "asks": []
    }
""")

var refAccounts*: JsonNode = parseJson("""
    [
        {
            "brokerAccountType": "Tinkoff",
            "brokerAccountId": "12345"
        }
    ]
""")

var refCandle*: JsonNode = parseJson("""
    [
        {
            "o": 919.431396,
            "c": 939.077366,
            "h": 955.369146,
            "l": 892.406208,
            "v": 16769,
            "time": "2020-05-01T07:00:00Z",
            "interval": "month",
            "figi": "BBG00PNLY692"
        },
        {
            "o": 940.323208,
            "c": 945.88158,
            "h": 957.38166,
            "l": 920.0064,
            "v": 13453,
            "time": "2020-06-01T07:00:00Z",
            "interval": "month",
            "figi": "BBG00PNLY692"
        }
    ]
""")

# Пустое значение, тк зависит от конкретного аккаунта
var refOrders*: JsonNode = parseJson("""
    [

    ]
""")
