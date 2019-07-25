//
//  LoginViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/19/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class LoginViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var emailBox: UITextField!
    let LOGIN_URL = "/sessions"
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func login() {
        apiLogin()
            .done { json -> Void in
                if !json.isEmpty {
                    let userId = json["user_id"]
                    UserDefaults.standard.set(userId, forKey: "user_id")
                    self.performSegue(withIdentifier: "loginSuccess", sender: self)
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    // MARK: - API Calls
    func apiLogin() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+LOGIN_URL)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["email": emailBox.text!])
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
    
    //MARK: - Actions
    @IBAction func buttonClick(_ sender: Any) {
        if emailBox.text!.isEmpty {
            self.emailBox.text = ""
            self.emailBox.placeholder = "Try again"
            return
        }
        login()
    }
}
