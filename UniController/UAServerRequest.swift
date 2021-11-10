//------------------------------------------------------------------------------
//  UAServerRequest.swift
//------------------------------------------------------------------------------
import Cocoa
class UAServerRequest: NSObject {
    //HTTPリクエストの送受信を同期的に行う
    class func postSync(urlString:String, param:String)->Any {
        //戻り値の定義（Anyの初期化は何を代入しても良さそう）
        //var list:[String:Any] = [:]
        var list:Any = []
        //パラメータをDataオブジェクトに変換
        guard let data = param.data(using: .utf8)  else {
            print("paramter missing")
            return list
        }
        //URLリクエストオブジェクトの作成
        let url:URL = URL.init(string: urlString)!
        var request:URLRequest = URLRequest(url: url)
        //リクエストヘッダの指定
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //パラメータの設定
        request.setValue(String(format:"%ld", data.count) , forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        //ネットワーク通信オブジェクトの生成（一時セッション）
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession.init(configuration: configuration)
        //同期用セマフォの作成
        let semaphore = DispatchSemaphore(value: 0)
        //データ送受信処理の定義
        let task = session.dataTask(with: request,
                                    completionHandler:
            {(data,response,error) in
                if let error = error{ //error=nil is OK
                    //エラー発生
                    print("HTTP request error occured \(error)")
                    semaphore.signal()
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    let data = data else {
                        //guardの評価を複数条件で行う
                        //受信データがnil または　responseがキャストできないときはエラー
                        print("response not received")
                        semaphore.signal()
                        return
                }
                if response.statusCode != 200{
                    //ステータスコード200(OK)以外はエラーとする
                    print("status error \(response.statusCode)")
                    semaphore.signal()
                    return
                }
                do{ //Json文字列をオブジェクトに変換する
                    let responseList = try JSONSerialization.jsonObject(with: data)
                    list = responseList
                }catch{
                    print("JSONSerialization fatal error")
                    semaphore.signal()
                    return
                }
                semaphore.signal()//処理の再開
                return
                
        })
        task.resume() //実行
        semaphore.wait() //送受信が終了するまで待機する
        return list
    }
}
