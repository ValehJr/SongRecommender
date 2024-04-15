//
//  AuthViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import UIKit
import WebKit


class AuthViewController: UIViewController,WKNavigationDelegate {

  private let webView: WKWebView = {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    let webView = WKWebView(frame: .zero, configuration: config)
    return webView
  }()

  public var completionHandler: ((Bool) ->Void)?


  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Sign In"
    view.backgroundColor = .systemBackground
    webView.navigationDelegate = self
    view.addSubview(webView)
    guard let url = AuthManger.shared.signInURL else{
      print("Invalid URL")
      return
    }
    webView.load(URLRequest(url: url))
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    webView.frame = view.bounds
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    guard let url = webView.url else{
      print("webView Url is wrong")
      return
    }

    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard let code = components?.queryItems?.first(where: {$0.name == "code"})?.value else{
      return
    }

    AuthManger.shared.getCodeForToken(code: code) { [weak self] success in
      DispatchQueue.main.async {
        self?.navigationController?.popViewController(animated: true)
        self?.completionHandler?(success)
      }

    }
  }

}
