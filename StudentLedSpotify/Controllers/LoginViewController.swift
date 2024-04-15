//
//  LoginViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var loginButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  @IBAction func loginAction(_ sender: Any) {
    let vc = AuthViewController()
    vc.completionHandler = { [weak self] success in
      DispatchQueue.main.async {
        self?.handleSignIn(success: success)
      }
    }
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  private func handleSignIn(success: Bool){
    guard success else{
      let alert = UIAlertController(title: "Oops", message: "Something went wrong while signing in.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      present(alert, animated: true)
      return
    }

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainVC = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as! TabBarController
    navigationController?.pushViewController(mainVC, animated: true)
  }

}
