//
//  LoginViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 07.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var backendURL: String = "https://young-beyond-20476.herokuapp.com/customers"
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        // Set up the http request with URLSession
        let session = URLSession.shared
        // Check the Request URL
        guard let url = URL(string: backendURL + "?email=\(email.text ?? "")") else {
            fatalError("The URL could not be resolved.")
        }
        // Make the request with URLSessionDataTask
        print("Start Connection to Backend to verify user.")
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
                    print("Response: \(jsonResponse)")
                    DispatchQueue.main.async {
                        guard jsonResponse.count != 0 else {
                            showAlertForIncorrectLogin(context: self)
                            return;
                        }
                        guard let userPassword = jsonResponse[0]["password"] as? String else {
                            fatalError("Could not read User Password from Server.")
                        }
                        if (userPassword != self.password.text) {
                            showAlertForIncorrectLogin(context: self)
                            return;
                        } else {
                            print("Login correct.")
                            self.performSegue(withIdentifier: "loginSuccessfulSegue", sender: self)
                        }
                    }
                }
            } catch let error {
                fatalError("Failed to load: \(error.localizedDescription)")
            }
        })
        // Start the Task
        task.resume()
    }
}

private func showAlertForIncorrectLogin(context: LoginViewController) {
    let alertController = UIAlertController(title: nil, message:
        "Incorrect Login", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    context.present(alertController, animated: true)
}
