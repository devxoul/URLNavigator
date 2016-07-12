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
        self.tableView.registerClass(RepoCell.self, forCellReuseIdentifier: "repo")

        API.repos(self.username) { [weak self] result in
            guard let `self` = self else { return }
            self.repos = (result.value ?? []).sort { $0.starCount > $1.starCount }
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.viewControllers.count > 1 { // pushed
            self.navigationItem.leftBarButtonItem = nil
        } else if self.presentingViewController != nil { // presented
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Done,
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


// MARK: - UITableViewDataSource

extension UserViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repo", forIndexPath: indexPath) as! RepoCell
        let repo = self.repos[indexPath.row]
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.descriptionText
        cell.detailTextLabel?.textColor = .grayColor()
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

}


// MARK: - UITableViewDelegate

extension UserViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let repo = self.repos[indexPath.row]
        let webViewController = Navigator.presentURL(repo.URLString, wrap: true)
        webViewController?.title = "\(self.username)/\(repo.name)"
        NSLog("Navigator: Present \(repo.URLString)")
    }

}


// MARK: - URLNavigable

extension UserViewController: URLNavigable {

    convenience init?(URL: URLConvertible, values: [String: AnyObject]) {
        guard let username = values["username"] as? String else { return nil }
        self.init(username: username)
    }

}
