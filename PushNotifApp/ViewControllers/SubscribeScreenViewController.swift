//
//  SubscribeScreenViewController.swift
//  PushNotifApp
//
//  Created by Sarah Briggs on 7/19/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import UserNotifications

class SubscribeScreenViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var stackView: UIStackView!
    let tradersUrl = "/trader.json"
    let subscriptionsUrl = "/subscription.json"
    var nameToId = [String:Int]()
    var currentSubs = [Int]()
    let userId = UserDefaults.standard.string(forKey: "user_id")!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllSubs()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "traderClicked" {
            let buttonSender = sender as! UIButton
            let name = buttonSender.titleLabel?.text
            let id = nameToId[name!]
            let vc = segue.destination as! ConfirmedSubViewController
            vc.traderId = id
            vc.traderName = name
        }
    }
    
    func getAllTraders() {
        stackView.removeAllArrangedSubviews()
        apiGetAllTraders()
            .done { json -> Void in
                var index = 0
                for dict in json {
                    let name = dict["name"] as! String
                    let id = dict["id"] as! Int
                    let button = self.colorButton(withColor: UIColor.white, title: name)
                    if self.currentSubs.contains(id) {
                        button.isEnabled = false
                    }
                    else {
                        button.isEnabled = true
                    }
                    self.nameToId[name] = id
                    self.stackView.insertArrangedSubview(button, at: index)
                    index = index + 1
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func getAllSubs() {
        self.currentSubs.removeAll()
        apiGetAllSubs()
            .done { json -> Void in
                for dict in json {
                    self.currentSubs.append(dict["trader_id"] as! Int)
                }
                self.getAllTraders()
            }
            .catch { error in
                print(error.localizedDescription)
            }
    }
    
    func colorButton(withColor color:UIColor, title:String) -> UIButton {
        let newButton = UIButton(type: .system)
        newButton.backgroundColor = color
        newButton.setTitle(title, for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        return newButton
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    // MARK: - API Calls
    func apiGetAllTraders() -> Promise<[[String: Any]]> {
        let url = URL(string: ConstantsEnum.baseUrl+tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .get)
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        promise.fulfill(json as! [[String : Any]])
                    case .failure(let error):
                        promise.reject(error)
                    }
            }
        }
    }
    
    func apiGetAllSubs() -> Promise<[[String: Any]]> {
        let url = URL(string: ConstantsEnum.baseUrl+subscriptionsUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .get, parameters: ["id":userId])
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        promise.fulfill(json as! [[String : Any]])
                    case .failure(let error):
                        promise.reject(error)
                    }
            }
        }
    }
    
    //MARK: - Actions
    @objc
    func buttonAction(sender: UIButton!) {
        self.performSegue(withIdentifier: "traderClicked", sender: sender)
    }

}

//MARK: - Extensions
extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
