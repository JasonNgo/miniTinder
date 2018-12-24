//
//  LoginController.swift
//  Tinder
//
//  Created by Jason Ngo on 2018-12-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

protocol RegisterAndLoginDelegate {
  func userLoggedIn()
}

class LoginController: UIViewController {
  
  var loginView = LoginView()
  var loginViewModel = LoginViewModel()
  var delegate: RegisterAndLoginDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    setupGestures()
    setupSubviewTargets()
    setupLoginViewModelBindables()
  }
  
  fileprivate func setupLayout() {
    view.addSubview(loginView)
    loginView.fillSuperview()
    navigationController?.isNavigationBarHidden = true
  }
  
  fileprivate func setupGestures() {
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
  }
  
  fileprivate func setupSubviewTargets() {
    let fields = [loginView.emailTextField, loginView.passwordTextField]
    fields.forEach { $0.addTarget(self, action: #selector(handleTextChange), for: .editingChanged) }
    loginView.loginButton.addTarget(self, action: #selector(handleLoginTapped), for: .touchUpInside)
    loginView.goToRegistrationButton.addTarget(self, action: #selector(handleGoToRegistrationTapped), for: .touchUpInside)
  }
  
  fileprivate func setupLoginViewModelBindables() {
    loginViewModel.bindableIsFormValid.bind { [weak self] (isFormValid) in
      guard let self = self else { return }
      guard let isFormValid = isFormValid else { return }
      
      self.loginView.loginButton.isEnabled = isFormValid
      if isFormValid {
        self.loginView.loginButton.backgroundColor = #colorLiteral(red: 0.8273344636, green: 0.09256268293, blue: 0.324395299, alpha: 1)
        self.loginView.loginButton.setTitleColor(.white, for: .normal)
      } else {
        self.loginView.loginButton.backgroundColor = .gray
        self.loginView.loginButton.setTitleColor(.darkGray, for: .normal)
      }
    }
  }
  
  @objc fileprivate func handleTextChange(textField: UITextField) {
    if textField == loginView.emailTextField {
      loginViewModel.email = textField.text
    } else {
      loginViewModel.password = textField.text
    }
  }
  
  @objc fileprivate func handleLoginTapped() {
    handleTapGesture()
    loginView.loginButton.isEnabled = false
    let loginHUD = JGProgressHUD(style: .dark)
    loginHUD.textLabel.text = "Attempting to login"
    loginHUD.show(in: view)
    
    loginViewModel.performLogin { [weak self] (error) in
      loginHUD.dismiss()
      guard let self = self else { return }
      
      if let error = error {
        print(error)
        self.showHUDWithError(error)
        self.loginView.loginButton.isEnabled = true
        self.loginViewModel.bindableIsLoggingIn.value = false
      }
      
      self.dismiss(animated: true, completion: {
        self.delegate?.userLoggedIn()
      })
    }
  }
  
  @objc fileprivate func handleTapGesture() {
    view.endEditing(true)
  }
  
  @objc fileprivate func handleGoToRegistrationTapped() {
    navigationController?.popViewController(animated: true)
  }
  
  fileprivate func showHUDWithError(_ error: Error) {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Failed Registration"
    hud.detailTextLabel.text = error.localizedDescription
    hud.show(in: view)
    hud.dismiss(afterDelay: 2.5)
  }
  
}
