//
//  RegisterViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import ValidationComponents
import MaterialComponents.MDCTextField

class RegisterViewController: UIViewController, UITextFieldDelegate {
    var arrayOfTextFieldControllerFloating = [MDCTextInputControllerOutlined]()
    let backendURL: String = "https://young-beyond-20476.herokuapp.com/customers"
    @IBOutlet weak var emailTextField: MDCTextField!
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var passwordTextField1: MDCTextField!
    @IBOutlet weak var passwordTextField2: MDCTextField!
    @IBOutlet weak var registerButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField1.delegate = self
        passwordTextField2.delegate = self
        arrayOfTextFieldControllerFloating.append(MDCTextInputControllerOutlined(textInput: emailTextField))
        arrayOfTextFieldControllerFloating.append(MDCTextInputControllerOutlined(textInput: usernameTextField))
        arrayOfTextFieldControllerFloating.append(MDCTextInputControllerOutlined(textInput: passwordTextField1))
        arrayOfTextFieldControllerFloating.append(MDCTextInputControllerOutlined(textInput: passwordTextField2))
    }
    
    // MARK: Actions
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        checkRegistration()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "registerBackSegue", sender: self)
    }
    
    // Private Functions
    private func checkRegistration() {
        if (!checkEmail()) {
            return
        }
        if (!checkUsername()) {
            return
        }
        if (!checkPasswords()) {
            return
        }
        checkIfUserIsAvailable()
    }
    
    private func checkEmail() -> Bool {
        let rule = EmailValidationPredicate()
        let correct = rule.evaluate(with: emailTextField.text)
        if (!correct) {
            showAlert(message: "Not a valid Email.", context: self)
            return false
        }
        return true
    }
    
    private func checkUsername() -> Bool {
        let usernameRegex = "^[a-zA-Z0-9]+$";
        let usernamePredicate = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
        let correct = usernamePredicate.evaluate(with: usernameTextField.text)
        if (!correct) {
            showAlert(message: "Not a valid Username.", context: self)
            return false
        }
        return true
    }
    
    private func checkPasswords() -> Bool {
        if (passwordTextField1.text != passwordTextField2.text) {
            showAlert(message: "Passwords are different.", context: self)
            return false
        }
        if (passwordTextField1.text == "" || passwordTextField2.text == "") {
            showAlert(message: "No Password Input.", context: self)
            return false
        }
        return true
    }
    
    /* Checks if User is already in System */
    private func checkIfUserIsAvailable() {
        NetworkingManager.shared.GETRequestToBackend(route: "/customers", queryParams: "?email=\(emailTextField.text ?? "")", completionHandler: checkIfUserIsAvailableHandler)
    }
    
    /* Register User in Backend */
    private func registerUser() {
        let user = [
            "username": usernameTextField.text,
            "password": passwordTextField1.text,
            "email": emailTextField.text
        ]
        NetworkingManager.shared.POSTRequestToBackend(route: "/customers", body: user as! [String : String], completionHandler: registrationProcessHandler)
    }
    
    private func checkIfUserIsAvailableHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        // Check for error on client side
        guard error == nil else {
            fatalError("An Error occured on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        // Check for error on server side
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occured on server side, while executing REST Call.")
        }
        // Parse json response data to Dictionary
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                DispatchQueue.main.async {
                    guard jsonResponse.count == 0 else {
                        self.showAlert(message: "User already available in System.", context: self)
                        return;
                    }
                    self.registerUser()
                }
            }
        } catch let error {
            fatalError("Failed to load: \(error.localizedDescription)")
        }
    }
    
    private func registrationProcessHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        // Check for error on client side
        guard error == nil else {
            fatalError("An Error occured on client side, while executing REST Call. Error: \(error!.localizedDescription)")
        }
        // Check for error on server side
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            fatalError("An Error occured on server side, while executing REST Call.")
        }
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                guard let sessionToken = jsonResponse["customerid"] as? Int else {
                    fatalError("Unknown Session Token.")
                }
                UserSession.setSessionToken(sessionToken)
                print(UserSession.getSessionToken())
            }
        } catch {
            fatalError("Failed to retrieve Session Token from Server.");
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "registerSuccessfulSegue", sender: self)
        }
    }
    
    private func showAlert(message: String, context: RegisterViewController) {
        let alertController = UIAlertController(title: nil, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        context.present(alertController, animated: true)
    }

}
