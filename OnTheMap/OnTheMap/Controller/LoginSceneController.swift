//
//  File.swift
//  OnTheMap
//
//  Created by Neri Quiroz on 11/22/20.
//

import Foundation
import UIKit

class LoginSceneController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    
    let signUpUrl = UdacityClient.Endpoints.udacitySignUp.url
    
    var emailTextFieldIsEmpty = true
    var passwordTextFieldIsEmpty = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.delegate = self
        passwordTextField.delegate = self
        buttonEnabled(false, button:loginButton)
        self.loadingIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    
    @IBAction func login(_ sender: UIButton) {
        setLoggingIn(true)
        UdacityClient.login(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    
    
    @IBAction func signUp(_ sender: Any) {
        setLoggingIn(true)
        UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
    }
    
    
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = false 
                self.loadingIndicator.startAnimating()
                self.loginButton.isEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.loginButton.isEnabled = true
            }
        }
        DispatchQueue.main.async {
            self.emailTextField.isEnabled = !loggingIn
            self.passwordTextField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
            self.signUpButton.isEnabled = !loggingIn
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currenText = emailTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                emailTextFieldIsEmpty = true
            } else {
                emailTextFieldIsEmpty = false
            }
        }
        
        if textField == passwordTextField {
            let currenText = passwordTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                passwordTextFieldIsEmpty = true
            } else {
                passwordTextFieldIsEmpty = false
            }
        }
        
        if emailTextFieldIsEmpty == false && passwordTextFieldIsEmpty == false {
            buttonEnabled(true, button: loginButton)
        } else {
            buttonEnabled(false, button: loginButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: loginButton)
        if textField == emailTextField {
            emailTextFieldIsEmpty = true
        }
        if textField == passwordTextField {
            passwordTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login(loginButton)
        }
        return true
    }
    
}
