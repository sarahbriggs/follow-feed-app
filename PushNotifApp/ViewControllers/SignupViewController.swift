//
//  SignupViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/17/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class SignupViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func signup() {
        apiSignup()
            .done { json -> Void in
                if !json.isEmpty {
                    let userId = json["user_id"]
                    UserDefaults.standard.set(userId, forKey: "user_id")
                    #if targetEnvironment(simulator)
                        self.performSegue(withIdentifier: "signupSuccess", sender: self)
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
                    self.performSegue(withIdentifier: "signupSuccess", sender: self)
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    // MARK: - API Calls
    func apiSignup() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.signupUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["name": nameBox.text!, "email": emailBox.text!])
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
    
    //MARK: - Actions
    @IBAction func goClicked(_ sender: Any) {
        if (nameBox.text!.isEmpty || emailBox.text!.isEmpty) {
            if nameBox.text!.isEmpty {
                nameBox.placeholder = "Enter name"
            }
            if emailBox.text!.isEmpty {
                emailBox.placeholder = "Enter email"
            }
            return
        }
        signup()
    }
}

