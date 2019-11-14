//
//  LoginViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        NetworkingManager.shared.GETRequestToBackend(route: "/customers", queryParams: "?email=\(email.text ?? "")", completionHandler: loginRequestHandler)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "loginBackSegue", sender: self)
    }
    
    
    // MARK: Private Functions
    private func showAlertForIncorrectLogin(context: LoginViewController) {
        let alertController = UIAlertController(title: nil, message:
            "Incorrect Login", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        context.present(alertController, animated: true)
    }
    
    /* Completion Handler for Login Request to Backend */
    private func loginRequestHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
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
        }
    }
}
