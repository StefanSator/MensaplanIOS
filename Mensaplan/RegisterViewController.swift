//
//  RegisterViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import ValidationComponents

class RegisterViewController: UIViewController {
    var backendURL: String = "https://young-beyond-20476.herokuapp.com/customers"
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField1: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var registerButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        registerUser()
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
    
    private func registerUser() {
        checkIfUserIsAvailable()
        //performSegue(withIdentifier: "registerSuccessfulSegue", sender: self)
    }
    
    private func checkIfUserIsAvailable() {
        let session = URLSession.shared
        guard let url = URL(string: backendURL + "?email=\(emailTextField.text ?? "")") else {
            fatalError("The URL could not be resolved.")
        }
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
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
                        self.startRegistrationProcess()
                    }
                }
            } catch let error {
                fatalError("Failed to load: \(error.localizedDescription)")
            }
        })
        // Start the Task
        task.resume()
    }
    
    private func startRegistrationProcess() {
        let session = URLSession.shared
        let url = URL(string: backendURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let user = [
            "username": usernameTextField.text,
            "password": passwordTextField1.text,
            "email": emailTextField.text
        ]
        do {
            let json = try JSONSerialization.data(withJSONObject: user, options: [])
            let task = session.uploadTask(with: request, from: json) {
                (data, response, error) in
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
            task.resume()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
/* // Parse json response data to Dictionary
 do {
 if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
 print("Response: \(jsonResponse)")
 DispatchQueue.main.async {
 guard jsonResponse.count != 0 else {
 self.showAlertForIncorrectLogin(context: self)
 return;
 }
 guard let userPassword = jsonResponse[0]["password"] as? String else {
 fatalError("Could not read User Password from Server.")
 }
 guard let sessionToken = jsonResponse[0]["customerid"] as? Int else {
 fatalError("Could not retrieve Token for current Session.")
 }
 if (userPassword != self.password.text) {
 self.showAlertForIncorrectLogin(context: self)
 return;
 } else {
 print("Login correct.")
 UserSession.setSessionToken(sessionToken)
 self.performSegue(withIdentifier: "loginSuccessfulSegue", sender: self)
 }
 }
 }
 } catch let error {
 fatalError("Failed to load: \(error.localizedDescription)")
 } */
    
    private func showAlert(message: String, context: RegisterViewController) {
        let alertController = UIAlertController(title: nil, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        context.present(alertController, animated: true)
    }

}
