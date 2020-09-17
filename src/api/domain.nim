import
    httpclient,
    options


const MaxOrderbookDepth*: int = 20


type CustomResponse* = object
    headers*: HttpHeaders
    code*: HttpCode
    status*: string
    body*: string


type Error* = object
    message*: string
    code*: string


type Currency* = string

const
    RUB*: Currency = "RUB"
    USD*: Currency = "USD"
    EUR*: Currency = "EUR"
    TRY*: Currency = "TRY"
    JPY*: Currency = "JPY"
    CNY*: Currency = "CNY"
    CHF*: Currency = "CHF"
    GBP*: Currency = "GBP"
    HKD*: Currency = "HKD"


type TradingStatus = string

const
    BreakInTrading*: TradingStatus = "break_in_trading"
    NormalTrading*: TradingStatus = "normal_trading"
    NotAvailableForTrading*: TradingStatus = "not_available_for_trading"
    ClosingAuction*: TradingStatus = "closing_auction"
    ClosingPeriod*: TradingStatus = "closing_period"
    DarkPoolAuction*: TradingStatus = "dark_pool_auction"
    DiscreteAuction*: TradingStatus = "discrete_auction"
    OpeningPeriod*: TradingStatus = "opening_period"
    OpeningAuctionPeriod*: TradingStatus = "opening_auction_period"
    TradingAtClosingAuctionPrice*: TradingStatus = "trading_at_closing_auction_price"


type CandleInterval* = string

const
    CandleInterval1Min*: CandleInterval = "1min"
    CandleInterval2Min*: CandleInterval = "2min"
    CandleInterval3Min*: CandleInterval = "3min"
    CandleInterval5Min*: CandleInterval = "5min"
    CandleInterval10Min*: CandleInterval = "10min"
    CandleInterval15Min*: CandleInterval = "15min"
    CandleInterval30Min*: CandleInterval = "30min"
    CandleInterval1Hour*: CandleInterval = "hour"
    CandleInterval2Hour*: CandleInterval = "2hour"
    CandleInterval4Hour*: CandleInterval = "4hour"
    CandleInterval1Day*: CandleInterval = "day"
    CandleInterval1Week*: CandleInterval = "week"
    CandleInterval1Month*: CandleInterval = "month"


type OperationType* = string

const
    BUY*: OperationType = "Buy"
    SELL*: OperationType = "Sell"
    OperationTypeBrokerCommission*: OperationType = "BrokerCommission"
    OperationTypeExchangeCommission*: OperationType = "ExchangeCommission"
    OperationTypeServiceCommission*: OperationType = "ServiceCommission"
    OperationTypeMarginCommission*: OperationType = "MarginCommission"
    OperationTypeOtherCommission*: OperationType = "OtherCommission"
    OperationTypePayIn*: OperationType = "PayIn"
    OperationTypePayOut*: OperationType = "PayOut"
    OperationTypeTax*: OperationType = "Tax"
    OperationTypeTaxLucre*: OperationType = "TaxLucre"
    OperationTypeTaxDividend*: OperationType = "TaxDividend"
    OperationTypeTaxCoupon*: OperationType = "TaxCoupon"
    OperationTypeTaxBack*: OperationType = "TaxBack"
    OperationTypeRepayment*: OperationType = "Repayment"
    OperationTypePartRepayment*: OperationType = "PartRepayment"
    OperationTypeCoupon*: OperationType = "Coupon"
    OperationTypeDividend*: OperationType = "Dividend"
    OperationTypeSecurityIn*: OperationType = "SecurityIn"
    OperationTypeSecurityOut*: OperationType = "SecurityOut"
    OperationTypeBuyCard*: OperationType = "BuyCard"


type OrderStatus = string

const
    OrderStatusNew*: OrderStatus = "New"
    OrderStatusPartiallyFill*: OrderStatus = "PartiallyFill"
    OrderStatusFill*: OrderStatus = "Fill"
    OrderStatusCancelled*: OrderStatus = "Cancelled"
    OrderStatusReplaced*: OrderStatus = "Replaced"
    OrderStatusPendingCancel*: OrderStatus = "PendingCancel"
    OrderStatusRejected*: OrderStatus = "Rejected"
    OrderStatusPendingReplace*: OrderStatus = "PendingReplace"
    OrderStatusPendingNew*: OrderStatus = "PendingNew"


type OperationStatus = string

const
    OperationStatusDone*: OperationStatus = "Done"
    OperationStatusDecline*: OperationStatus = "Decline"
    OperationStatusProgress*: OperationStatus = "Progress"


type InstrumentType = string

const
    InstrumentTypeStock*: InstrumentType = "Stock"
    InstrumentTypeCurrency*: InstrumentType = "Currency"
    InstrumentTypeBond*: InstrumentType = "Bond"
    InstrumentTypeEtf*: InstrumentType = "Etf"


type OrderType = string

const
    OrderTypeLimit*: OrderType = "Limit"
    OrderTypeMarket*: OrderType = "Market"


type MoneyAmount* = object
    currency: Currency
    value: float64


type PlacedOrder* = object
    orderId: string
    operation: OperationType
    status: OrderStatus
    rejectReason: string
    requestedLots: int
    executedLots: int
    commission: MoneyAmount
    message: string


type Order* = object
    orderId: string
    figi: string
    operation: OperationType
    status: OrderStatus
    requestedLots: int
    executedLots: int
    `type`: OrderType
    price: float64


type PositionBalance* = object
    figi: string
    ticker: string
    isin: string
    instrumentType: InstrumentType
    balance: float64
    blocked: float64
    lots: int
    expectedYield: Option[MoneyAmount]
    averagePositionPrice: Option[MoneyAmount]
    averagePositionPriceNoNkd: Option[MoneyAmount]
    name: string

type CurrencyBalance* = object
    currency: Currency
    balance: float64
    blocked: float64

type Portfolio* = object
    positions*: seq[PositionBalance]
    currencies*: seq[CurrencyBalance]


type Instrument* = object
    figi: string
    ticker: string
    isin: Option[string]
    faceValue: Option[float64]
    name: string
    minPriceIncrement: Option[float64]
    lot: int
    currency: Currency
    `type`: InstrumentType


type Trade* = object
    tradeId: string
    date: string
    price: float64
    quantity: int


type Operation* = object
    id: string
    status: OperationStatus
    trades: seq[Trade]
    commission: MoneyAmount
    currency: Currency
    payment: float64
    price: float64
    quantity: int
    figi: string
    instrumentType: InstrumentType
    isMarginCall: bool
    date: string
    operationType: OperationType


type RestPriceQuantity* = object
    price: float64
    quantity: float64


type RestOrderBook* = object
    figi: string
    depth: int
    bids: seq[RestPriceQuantity]
    asks: seq[RestPriceQuantity]
    tradeStatus: TradingStatus
    minPriceIncrement: float64
    lastPrice: float64
    closePrice: float64
    limitUp: Option[float64]
    limitDown: Option[float64]
    faceValue: float64


type AccountType* = string

const
    AccountTinkoff*: AccountType = "Tinkoff"
    AccountTinkoffIIS*: AccountType = "TinkoffIis"

type Account* = object
    brokerAccountType*: AccountType
    brokerAccountId*: string

const DefaultAccount* = "" # Номер счета по умолчанию - Тинькофф


type Candle* = object
    figi: string
    interval: CandleInterval
    o: float64
    c: float64
    h: float64
    l: float64
    v: int
    time: string


type InstrumentInfo* = object
    figi: string
    trade_status: TradingStatus
    min_price_increment: float64
    lot: float64
    accrued_interest: float64
    limit_up: float64
    limit_down: float64


type PriceQuantity* = array[1, float64] # 0 - price, 1 - quantity


type OrderBook* = object
    figi: string
    depth: int
    bids: seq[PriceQuantity]
    asks: seq[PriceQuantity]


# TODO: events
