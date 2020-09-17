import
    json,
    httpclient

import
    domain,
    rest_api


proc newSandboxClient*(token: string): RestClient =
    return newRestClientCustom(token, "/sandbox")


proc newSandboxRestClientCustom*(token, apiURL: string): RestClient =
    return newRestClientCustom(token, apiURL)


proc register*(c: var RestClient, accountType: AccountType): (Account, Error) =
    let path = RestapiUrl & c.apiUrl & "/sandbox/register"
    let body = %*{"brokerAccountType": accountType}
    let response = c.doRequest(path, HttpPost, $body)
    let payload = parseJson(response.body)["payload"]

    var resp: Account
    var err: Error

    if response.status != $Http200:
        return (resp, to(payload, Error))
    try:
        return (to(payload, Account), err)
    except ValueError as e:
        raise MyException.newException("Unmarshal error to Account" & ": " &
                e.msg & "\n" & pretty(payload))


proc clear*(c: var RestClient, accountID: string): Error =
    var path = RestApiUrl & c.apiUrl & "/sandbox/clear"

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    var err: Error

    let response = c.doRequest(path, HttpPost)
    let payload = parseJson(response.body)["payload"]

    if response.status != $Http200:
        err = to(payload, Error)
        return err

    return err


proc remove*(c: var RestClient, accountID: string): Error =
    var path = RestApiUrl & c.apiUrl & "/sandbox/remove"

    if accountID != DefaultAccount:
        path = path & "?brokerAccountId=" & accountID

    var err: Error

    let response = c.doRequest(path, HttpPost)
    let payload = parseJson(response.body)["payload"]

    if response.status != $Http200:
        err = to(payload, Error)
        return err

    return err


proc setCurrencyBalance*(c: var RestClient, accountID: string,
        currency: Currency, balance: float64): Error =
    var path = RestApiUrl & c.apiUrl & "/sandbox/currencies/balance"
    let post = %* {
            "brokerAccountId": DefaultAccount,
            "currency": currency,
            "balance": balance
    }

    if accountID != DefaultAccount:
        post["brokerAccountId"] = newJString(accountID)

    let response = c.doRequest(path, HttpPost, $ post)
    let payload = parseJson(response.body)["payload"]

    var err: Error

    if response.status != $Http200:
        err = to(payload, Error)
        return err

    return err


proc setPositionsBalance*(c: var RestClient, accountID, figi: string,
        balance: float64): Error =
    var path = RestApiUrl & c.apiUrl & "/sandbox/positions/balance"
    let post = %* {
            "figi": figi,
            "balance": balance,
            "brokerAccountId": DefaultAccount
    }

    if accountID != DefaultAccount:
        post["brokerAccountId"] = newJString(accountID)

    var err: Error

    let response = c.doRequest(path, HttpPost, $ post)
    let payload = parseJson(response.body)["payload"]

    if response.status != $Http200:
        err = to(payload, Error)
        return err

    return err
