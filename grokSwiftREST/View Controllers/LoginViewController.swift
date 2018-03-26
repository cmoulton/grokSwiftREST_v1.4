//
//  LoginViewController.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-26.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
  func didTapLoginButton()
}

class LoginViewController: UIViewController {
  weak var delegate: LoginViewDelegate?

  @IBAction func tappedLoginButton() {
    delegate?.didTapLoginButton()
  }
}
