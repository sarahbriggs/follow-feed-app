//
//  ConfirmedSubViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/24/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class ConfirmedSubViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var traderLabel: UILabel!
    var traderId: Int!
    var traderName: String!
    let userId = UserDefaults.standard.string(forKey: "user_id")!

    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        traderLabel.text = traderName
        subscribe()
    }
    
    func subscribe() {
        apiSubscribe()
            .done { json -> Void in
                if !json.isEmpty { // on success, we get the subscription ARN back
                    print("Subscribed")
                    print(json["subscription_arn"]!)
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    // MARK: - API Calls
    func apiSubscribe() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.subscribeUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["trader_id": traderId!, "user_id": userId])
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        promise.fulfill(json as! [String : Any])
                    case .failure(let error):
                        promise.reject(error)
                    }
                }
        }
    }
    
}
