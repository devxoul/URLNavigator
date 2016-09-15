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
    "devxoul",
    "apple",
    "google",
    "facebook",
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
    let username = self.users[indexPath.row]
    cell.textLabel?.text = username
    cell.detailTextLabel?.text = "navigator://user/\(username)"
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
    let username = self.users[indexPath.row]
    let URL = "navigator://user/\(username)"
    Navigator.push(URL)
    NSLog("Navigator: Push \(URL)")
  }

}
