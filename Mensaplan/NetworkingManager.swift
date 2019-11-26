//
//  NetworkingManager.swift
//  Mensaplan
//
//  Created by Stefan Sator on 14.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

/* Singleton class for Networking Functionality to Heroku Backend */
class NetworkingManager {
    static let shared = NetworkingManager()
    let backendURL = "https://young-beyond-20476.herokuapp.com"
    
    private init() {}
    
    //Private Functions
    /* Starts a GET Request to Heroku Backend */
    func GETRequestToBackend(route: String, queryParams: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: "\(backendURL)\(route)\(queryParams)") else {
            fatalError("The URL could not be resolved.")
        }
        let task = session.dataTask(with: url, completionHandler: completionHandler);
        task.resume()
    }
    
    /* Starts a POST Request to Heroku Backend */
    func POSTRequestToBackend(route: String, body: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: "\(backendURL)\(route)") else {
            fatalError("The URL could not be resolved.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let json = try JSONSerialization.data(withJSONObject: body, options: [])
            let task = session.uploadTask(with: request, from: json, completionHandler: completionHandler)
            task.resume()
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    /* Starts a DELETE Request to Heroku Backend */
    func DELETERequestToBackend(route: String, queryParams: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: "\(backendURL)\(route)\(queryParams)") else {
            fatalError("The URL could not be resolved.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}
