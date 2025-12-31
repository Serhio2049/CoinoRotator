import Foundation

// Твои данные из coino.conf
let RPC_USER     = "user1"
let RPC_PASSWORD = "wY6MMqqqqqq"

let RPC_URL = "http://127.0.0.1:29299"
let AMOUNT  = 1.0
let INTERVAL: DispatchTimeInterval = .seconds(60)  // 1 минут

var cycle = 0

// JSON-RPC функция
func rpc(_ method: String, _ params: [Any] = [], _ completion: @escaping (Any?) -> Void) {
    let payload: [String: Any] = [
        "jsonrpc": "1.0",
        "id": "coino-rotator",
        "method": method,
        "params": params
    ]
    
    guard let url = URL(string: RPC_URL),
          let body = try? JSONSerialization.data(withJSONObject: payload) else {
        completion(nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body
    request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic " + Data("\(RPC_USER):\(RPC_PASSWORD)".utf8).base64EncodedString(),
                     forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        if error != nil {
            completion(nil)
            return
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] else {
            completion(nil)
            return
        }
        completion(result)
    }.resume()
}

// Запуск
print("Coino Rotator запущен — каждые 1 минут по 1 CNO")
print("Баланс ≈2000 CNO остаётся навсегда\n")

let timer = DispatchSource.makeTimerSource(queue: .global())
timer.schedule(deadline: .now(), repeating: INTERVAL)

timer.setEventHandler {
    cycle += 1
    
    rpc("getnewaddress", ["rotate_\(cycle)"]) { result in
        guard let address = result as? String else { return }
        
        rpc("sendtoaddress", [address, AMOUNT]) { txResult in
            let time = Date().formatted(.dateTime.hour().minute().second())
            if let txid = txResult as? String {
                print("[\(time)] #\(String(format: "%04d", cycle)) → \(address.prefix(15))… +1 CNO | \(txid.prefix(14))…")
            } else {
                print("[\(time)] #\(String(format: "%04d", cycle)) → ошибка отправки")
            }
        }
    }
}

// ─────────────────────── СТАРТ — РАБОТАЕТ В 2025 ГОДУ ───────────────────────
timer.resume()

// Делаем первую транзакцию сразу (вместо несуществующего eventHandler)
cycle += 1
rpc("getnewaddress", ["rotate_\(cycle)"]) { addr in
    guard let address = addr as? String else { return }
    rpc("sendtoaddress", [address, AMOUNT]) { tx in
        let t = Date().formatted(.dateTime.hour().minute().second())
        if let txid = tx as? String {
            print("[First] #\(String(format:"%04d", cycle)) → \(address.prefix(15))… +1 CNO | \(txid.prefix(14))…")
        }
    }
}

CFRunLoopRun()          // программа живёт вечно
// ─────────────────────────────────────────────────────────────────────

