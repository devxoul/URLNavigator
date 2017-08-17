//
//  ViewController.swift
//  Example
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import URLNavigator

class UserListViewController: UIViewController {

  // MARK: Properties

  let users = [
    DataModel(title: "devxoul", router: "navigator://user/devxoul"),
    DataModel(title: "apple", router: "navigator://user/apple"),
    DataModel(title: "google", router: "navigator://user/google"),
    DataModel(title: "facebook", router: "navigator://user/facebook"),
    DataModel(title: "fallback", router: "navigator://notMatchable"),
    ]


  // MARK: UI Properties

  let tableView = UITableView()


  // MARK: Initializing

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.title = "GitHub Users"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.tableView)
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(UserCell.self, forCellReuseIdentifier: "user")
  }


  // MARK: Layout

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.tableView.frame = self.view.bounds
  }

}


// MARK: - UITableViewDataSource

extension UserListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.users.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! UserCell
    let model = self.users[indexPath.row]
    cell.textLabel?.text = model.title
    cell.detailTextLabel?.text = model.router
    cell.detailTextLabel?.textColor = .gray
    cell.accessoryType = .disclosureIndicator
    return cell
  }

}


// MARK: - UITableViewDelegate

extension UserListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)

    // This is just an example. Don't use like this. Create a new `UserViewController` instance instead.
    let model = self.users[indexPath.row]
    
    if(model.title == "fallback"){
        Navigator.open(model.router)
    }
    
    let URL = model.router
    Navigator.push(URL)
    print("Navigator: Push \(URL)")
  }

}
