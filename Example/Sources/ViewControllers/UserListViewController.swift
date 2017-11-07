//
//  ViewController.swift
//  URLNavigatorExample
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import URLNavigator

class UserListViewController: UIViewController {

  // MARK: Properties

  private let navigator: NavigatorType
  let users = [
    User(name: "devxoul", urlString: "navigator://user/devxoul"),
    User(name: "apple", urlString: "navigator://user/apple"),
    User(name: "google", urlString: "navigator://user/google"),
    User(name: "facebook", urlString: "navigator://user/facebook"),
    User(name: "alert", urlString: "navigator://alert?title=Hello&message=World"),
    User(name: "fallback", urlString: "navigator://notMatchable"),
  ]


  // MARK: UI Properties

  let tableView = UITableView()


  // MARK: Initializing

  init(navigator: NavigatorType) {
    self.navigator = navigator
    super.init(nibName: nil, bundle: nil)
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
    let user = self.users[indexPath.row]
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.urlString
    cell.detailTextLabel?.textColor = .gray
    cell.accessoryType = .disclosureIndicator
    return cell
  }
}


// MARK: - UITableViewDelegate

extension UserListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)

    let user = self.users[indexPath.row]

    let isPushed = self.navigator.push(user.urlString) != nil
    if isPushed {
      print("[Navigator] push: \(user.urlString)")
    } else {
      print("[Navigator] open: \(user.urlString)")
      self.navigator.open(user.urlString)
    }
  }
}
