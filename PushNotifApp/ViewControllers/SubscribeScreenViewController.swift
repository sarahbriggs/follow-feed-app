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

class SubscribeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    
    @IBOutlet weak var unsubscibeButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var traderLabel: UILabel!
    @IBOutlet weak var popOver: UIView!
    @IBOutlet weak var tableView: UITableView!
    var allTraders = [String]()
    var allTraderIds = [Int]()
    var currentSubs = [Int]()
    let userId = UserDefaults.standard.string(forKey: "user_id")!
    var traderId = -1
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        popOver.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllSubs()
    }
    
    func getAllTraders() {
        allTraders.removeAll()
        apiGetAllTraders()
            .done { json -> Void in
                for dict in json {
                    let name = dict["name"] as! String
                    let id = dict["id"] as! Int
                    self.allTraders.append(name)
                    self.allTraderIds.append(id)
                }
                self.tableView.reloadData()
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
                    print(dict)
                    self.currentSubs.append(dict["trader_id"] as! Int)
                }
                self.getAllTraders()
            }
            .catch { error in
                print(error.localizedDescription)
            }
    }
    
    func subscribe() {
        apiSubscribe()
            .done { json -> Void in
                if !json.isEmpty { // on success, we get the subscription ARN back
                    print("Subscribed")
                    print(json["subscription_arn"]!)
                    self.getAllSubs()
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    // MARK: - API Calls
    func apiGetAllTraders() -> Promise<[[String: Any]]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.tradersUrl)!
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
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.subscriptionsUrl)!
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
    
    func apiSubscribe() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.subscribeUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["trader_id": traderId, "user_id": userId]) // include device token here, string
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
    
    //MARK: - Tableview funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTraders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell")
        cell?.textLabel?.text = allTraders[indexPath.row]
        if currentSubs.contains(allTraderIds[indexPath.row]) {
            cell?.detailTextLabel?.text = "Subscribed"
        }
        else {
            cell?.detailTextLabel?.text = "Not Subscribed"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popOver.isHidden = false
        traderLabel.text = allTraders[indexPath.row] + "?"
        traderId = allTraderIds[indexPath.row]
        if currentSubs.contains(allTraderIds[indexPath.row]) { // allow unsubscribe
            subscribeLabel.text = "Unsubscribe from:"
            subscribeButton.isHidden = true
            unsubscibeButton.isHidden = false
        }
        else { // allow subscribe
            subscribeLabel.text = "Subscribe to:"
            subscribeButton.isHidden = false
            unsubscibeButton.isHidden = true
        }
    }

    //MARK: Actions
    @IBAction func subscribeClicked(_ sender: Any) {
        subscribe()
        popOver.isHidden = true
    }
    
    @IBAction func unsubscribeClicked(_ sender: Any) {
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        popOver.isHidden = true
    }
    @IBAction func logoutClicked(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "user_id")
        self.performSegue(withIdentifier: "logout", sender: self)
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
