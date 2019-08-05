//
//  MessageViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 8/5/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class MessageViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    var traderId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func publishMessage() {
        apiPublishMessage()
            .done { json -> Void in
                self.textField.text = "Message published!"
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func apiPublishMessage() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.messageUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["id": traderId!, "message": textField.text!])
                .validate()
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendClicked(_ sender: Any) {
        publishMessage()
    }
    
}
