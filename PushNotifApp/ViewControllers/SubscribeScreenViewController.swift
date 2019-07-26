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
    @IBOutlet weak var popOver: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    let tradersUrl = "/trader.json"
    let subscriptionsUrl = "/subscription.json"
    var allTraders = [String]()
    var allTraderIds = [Int]()
    var currentSubs = [Int]()
    let userId = UserDefaults.standard.string(forKey: "user_id")!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        popOver.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        configureStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllSubs()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "traderClicked" {
//            let buttonSender = sender as! UIButton
//            let name = buttonSender.titleLabel?.text
//            let id = nameToId[name!]
//            let vc = segue.destination as! ConfirmedSubViewController
//            vc.traderId = id
//            vc.traderName = name
        }
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
        // here, we check if the selected trader (id) is contained in current subs... if so:
        // label says "Unsubscribe?" and unsubscribes
        // if not:
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
