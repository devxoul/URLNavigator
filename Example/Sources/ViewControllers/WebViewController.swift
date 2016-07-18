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
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)


    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        self.view.addSubview(self.activityIndicatorView)
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
        self.webView.frame = self.view.bounds
        self.activityIndicatorView.center.x = self.view.frame.width / 2
        self.activityIndicatorView.center.y = self.view.frame.height / 2
    }


    // MARK: Actions

    dynamic func doneButtonDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


// MARK: - URLNavigable

extension WebViewController: URLNavigable {

    convenience init?(URL: URLConvertible, values: [String: AnyObject]) {
        guard let URLVaue = URL.URLValue else { return nil }
        self.init()
        let request = NSURLRequest(URL: URLVaue)
        self.webView.loadRequest(request)
    }

}


// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicatorView.startAnimating()
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.activityIndicatorView.stopAnimating()
    }

    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        self.activityIndicatorView.stopAnimating()
    }

}
