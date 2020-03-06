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

/// Contoller handling the Registration Process within the app.
class RegisterViewController: UIViewController, UITextFieldDelegate {
    /// Controllers for handling the floating labels for the MDCTextFields.
    var arrayOfTextFieldControllerFloating = [MDCTextInputControllerOutlined]()
    /// URL of the backend service.
    let backendURL: String = "https://young-beyond-20476.herokuapp.com/customers"
    /// Input Field for the email of the user.
    @IBOutlet weak var emailTextField: MDCTextField!
    /// Input Field for the username of the user.
    @IBOutlet weak var usernameTextField: MDCTextField!
    /// Input Field for the password of the user.
    @IBOutlet weak var passwordTextField1: MDCTextField!
    /// Input Field for the password confirmation of the user.
    @IBOutlet weak var passwordTextField2: MDCTextField!
    /// Registration Button.
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
    /// Action which is called automatically if registration button is clicked.
    /// It checks the registration of a user and if the registration is correct, a new user account gets registered.
    ///
    /// - Parameter sender: The Registration Button.
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        checkRegistration()
    }
    
    /// Action which is called automatically if back button is clicked.
    /// If executed the app returns to the Start Screen.
    ///
    /// - Parameter sender: The Back Button.
    @IBAction func backButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "registerBackSegue", sender: self)
    }
    
    // Private Functions
    /// Checks if the Registration Input of the user is correct.
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
    
    
    /// Checks if the Email has a valid format.
    ///
    /// - Returns: true, if the email is valid, else false.
    private func checkEmail() -> Bool {
        let rule = EmailValidationPredicate()
        let correct = rule.evaluate(with: emailTextField.text)
        if (!correct) {
            showAlert(message: "Not a valid Email.", context: self)
            return false
        }
        return true
    }
    
    /// Checks if the Username has a valid format.
    ///
    /// - Returns: true, if the username is valid, else false.
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
    
    /// Checks if both password inputs are correct.
    ///
    /// - Returns: true, if password inputs are valid, else false.
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
    
    /// Checks if user is available in System by asking the Backend.
    private func checkIfUserIsAvailable() {
        NetworkingManager.shared.GETRequestToBackend(route: "/customers", queryParams: "?email=\(emailTextField.text ?? "")", completionHandler: checkIfUserIsAvailableHandler)
    }
    
    /// Registers new User by sending registration request to the backend service.
    private func registerUser() {
        let user = [
            "username": usernameTextField.text,
            "password": passwordTextField1.text,
            "email": emailTextField.text
        ]
        NetworkingManager.shared.POSTRequestToBackend(route: "/customers", body: user as! [String : String], completionHandler: registrationProcessHandler)
    }
    
    
    /// Completion Handler for the Request send to the Backend in function checkIfUserIsAvailable().
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Completion Handler for the Request send to the Backend to register a new user in the system.
    ///
    /// - Parameters:
    ///   - data: The data returned from the backend service as response.
    ///   - response: Metadata associated with the request, e.g. the status code of the response.
    ///   - error: Contains the Error if an error has occurred.
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
    
    /// Shows Alert Dialog when user input is not valid or registration process failed.
    ///
    /// - Parameters:
    ///   - message: Message to show in Alert Dialog.
    ///   - context: Current application context.
    private func showAlert(message: String, context: RegisterViewController) {
        let alertController = UIAlertController(title: nil, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        context.present(alertController, animated: true)
    }

}
