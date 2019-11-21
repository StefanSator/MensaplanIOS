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
        let body = [
            "email": email.text,
            "password": password.text
        ]
        NetworkingManager.shared.POSTRequestToBackend(route: "/customers/validate", body: body as [String : Any], completionHandler: loginRequestHandler)
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
            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                print("Response: \(jsonResponse)")
                DispatchQueue.main.async {
                    guard let successful = jsonResponse["successful"] as? Int else {
                        fatalError("Could not retrieve from JSON if Request was successful.")
                    }
                    guard let sessionToken = jsonResponse["sessiontoken"] as? Int else {
                        fatalError("Could not retrieve session token from JSON of request.")
                    }
                    if (successful == 0) {
                        self.showAlertForIncorrectLogin(context: self)
                        return;
                    } else {
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
