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
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getId() {
        apiGetId()
            .done { json -> Void in
                if !json.isEmpty {
                    let userId = json["user_id"]
                    UserDefaults.standard.set(userId, forKey: "user_id")
                    #if targetEnvironment(simulator)
                        self.performSegue(withIdentifier: "loginSuccess", sender: self)
                    #else
                        self.postDevice()
                    #endif
                }
            }
            .catch { error in
                print(error.localizedDescription)
            }
    }
    
    func postDevice() {
        apiPostDevice()
            .done { json -> Void in
                if !json.isEmpty {
                    self.login()
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func login() {
        apiLogin()
            .done { json -> Void in
                if !json.isEmpty {
                    print(json)
                    self.performSegue(withIdentifier: "loginSuccess", sender: self)
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    // MARK: - API Calls
    func apiGetId() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.getIdUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["email": emailBox.text!])
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
    
    func apiPostDevice() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.deviceUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["token": UserDefaults.standard.string(forKey: "APNSToken")!,
                                                                "user_id": UserDefaults.standard.string(forKey: "user_id")!,
                                                                "platform": "APNS_SANDBOX"])
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
    
    func apiLogin() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.loginUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["token": UserDefaults.standard.string(forKey: "APNSToken")!,
                                                                "user_id": UserDefaults.standard.string(forKey: "user_id")!])
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
    
    //MARK: - Actions
    @IBAction func buttonClick(_ sender: Any) {
        if emailBox.text!.isEmpty {
            self.emailBox.text = ""
            self.emailBox.placeholder = "Try again"
            return
        }
        getId()
    }
}
