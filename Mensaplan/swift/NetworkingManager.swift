//
//  NetworkingManager.swift
//  Mensaplan
//
//  Created by Stefan Sator on 14.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import Foundation

/// Class which is responsible for the Networking Communication with the Backend of the App.
class NetworkingManager {
    /// Singleton instance of a NetworkingManager.
    static let shared = NetworkingManager()
    /// The URL of the backend service.
    let backendURL = "https://young-beyond-20476.herokuapp.com"
    
    /// Private Constructor, so that it is not possible to create multiple instances of the NetworkingManager Class.
    private init() {}
    
    //Private Functions
    /**
     Handler for GET Requests to the Backend Service.
     - Parameters:
        - route: The Route of the service to contact.
        - queryParams: The Query Parameters.
        - completionHandler: The Handler called after completion of the request.
     */
    func GETRequestToBackend(route: String, queryParams: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: "\(backendURL)\(route)\(queryParams)") else {
            fatalError("The URL could not be resolved.")
        }
        let task = session.dataTask(with: url, completionHandler: completionHandler);
        task.resume()
    }
    
    /**
     Handler for POST Requests to the Backend Service.
     - Parameters:
        - route: The Route of the service to contact.
        - body: The Body Parameters.
        - completionHandler: The Handler called after completion of the request.
     */
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
    /**
     Handler for DELETE Requests to the Backend Service.
     - Parameters:
        - route: The Route of the service to contact.
        - queryParams: The Query Parameters.
        - completionHandler: The Handler called after completion of the request.
     */
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
