//
//  WebViewController.swift
//  URLNavigator
//
//  Created by Suyeol Jeon on 7/13/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit
import WebKit

import URLNavigator

final class WebViewController: UIViewController {

  // MARK: UI Properties

  let webView = WKWebView()
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)


  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.navigationDelegate = self
    self.view.addSubview(self.webView)
    self.view.addSubview(self.activityIndicatorView)
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
    self.webView.frame = self.view.bounds
    self.activityIndicatorView.center.x = self.view.frame.width / 2
    self.activityIndicatorView.center.y = self.view.frame.height / 2
  }


  // MARK: Actions

  dynamic func doneButtonDidTap() {
    self.dismiss(animated: true, completion: nil)
  }

}


// MARK: - URLNavigable

extension WebViewController: URLNavigable {

  convenience init?(navigation: Navigation) {
    guard let URLVaue = navigation.url.urlValue else { return nil }
    self.init()
    let request = URLRequest(url: URLVaue)
    self.webView.load(request)
  }

}


// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
    self.activityIndicatorView.startAnimating()
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.activityIndicatorView.stopAnimating()
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
    self.activityIndicatorView.stopAnimating()
  }

}
