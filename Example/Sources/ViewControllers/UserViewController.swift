//
//  UserViewController.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import URLNavigator

final class UserViewController: UIViewController {

  // MARK: Properties

  let username: String
  var repos = [Repo]()


  // MARK: UI Properties

  let tableView = UITableView()


  // MARK: Initializing

  init(username: String) {
    self.username = username
    super.init(nibName: nil, bundle: nil)
    self.title = "\(username)'s Repositories"
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
    self.tableView.register(RepoCell.self, forCellReuseIdentifier: "repo")

    API.repos(username: self.username) { [weak self] result in
      guard let `self` = self else { return }
      self.repos = (result.value ?? []).sorted { $0.starCount > $1.starCount }
      self.tableView.reloadData()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if self.navigationController?.viewControllers.count ?? 0 > 1 { // pushed
      self.navigationItem.leftBarButtonItem = nil
    } else if self.presentingViewController != nil { // presented
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(doneButtonDidTap)
      )
    }
  }


  // MARK: Layout

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.tableView.frame = self.view.bounds
  }


  // MARK: Actions

  dynamic func doneButtonDidTap() {
    self.dismiss(animated: true, completion: nil)
  }

}


// MARK: - UITableViewDataSource

extension UserViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.repos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "repo", for: indexPath) as! RepoCell
    let repo = self.repos[indexPath.row]
    cell.textLabel?.text = repo.name
    cell.detailTextLabel?.text = repo.descriptionText
    cell.detailTextLabel?.textColor = .gray
    cell.accessoryType = .disclosureIndicator
    return cell
  }

}


// MARK: - UITableViewDelegate

extension UserViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let repo = self.repos[indexPath.row]
    let webViewController = Navigator.present(repo.URLString, wrap: true)
    webViewController?.title = "\(self.username)/\(repo.name)"
    NSLog("Navigator: Present \(repo.URLString)")
  }

}


// MARK: - URLNavigable

extension UserViewController: URLNavigable {
  convenience init?(navigation: Navigation) {
    guard let vcLink = navigation.values["username"] as? String else {
      return nil
    }
    self.init(username: vcLink)
    
  }
}
