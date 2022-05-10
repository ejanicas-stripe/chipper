//
//  APIClient.swift
//  Stripe POS
//
//  Created by Ben Guo on 3/12/18.
//  Modified by Eduardo Janicas on 09/05/22
//  Copyright © 2018 Stripe. All rights reserved.
//

import Foundation
import Alamofire
import StripeTerminal

class APIClient: NSObject, ConnectionTokenProvider {

    // This comes from `AppDelegate.backendUrl`, set URL there
    var baseURLString: String?

    private var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }

    // MARK: ConnectionTokenProvider
    func fetchConnectionToken(_ completion: @escaping ConnectionTokenCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("connection_token")
        Alamofire.request(url, method: .post, parameters: [:])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json as [String: AnyObject]) where json["secret"] is String:
                    completion((json["secret"] as! String), nil)
                case .success,
                     .failure where responseJSON.response?.statusCode == 402:
                    let description = responseJSON.data.flatMap({ String(data: $0, encoding: .utf8) })
                        ?? "Failed to decode connection token"
                    let error = NSError(domain: "example",
                                        code: 1,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: description
                    ])
                    completion(nil, error)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }

    // MARK: Endpoints for App

    /// Create PaymentIntent using https://github.com/stripe/example-terminal-backend
    ///
    /// - Parameters:
    ///   - params: parameters for PaymentIntent creation
    ///   - completion: called with result: either PaymentIntent client_secret, or the error
    func createPaymentIntent(_ params: PaymentIntentParameters, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        let url = self.baseURL.appendingPathComponent("create_payment_intent")
        Alamofire.request(url, method: .post,
                          parameters: [
                            "amount": params.amount,
                            "currency": params.currency,
                            "description": params.statementDescriptor ?? "Example PaymentIntent"
        ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json as [String: AnyObject]):
                    if let secret = json["secret"] as? String {
                        completion(.success(secret))
                        return
                    }
                    fallthrough
                case .success,
                     .failure where responseJSON.response?.statusCode == 402:
                    let description = responseJSON.data.flatMap({ String(data: $0, encoding: .utf8) })
                        ?? "Failed to create PaymentIntent"
                    let error = NSError(domain: "example",
                                        code: 4,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: description
                    ])
                    completion(.failure(error))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    func capturePaymentIntent(_ paymentIntentId: String, completion: @escaping ErrorCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("capture_payment_intent")
        Alamofire.request(url, method: .post,
                          parameters: ["payment_intent_id": paymentIntentId])
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure where response.response?.statusCode == 402:
                    let description = response.data.flatMap({ String(data: $0, encoding: .utf8) })
                        ?? "Failed to capture PaymentIntent"
                    let error = NSError(domain: "example",
                                        code: 2,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: description
                    ])
                    completion(error)
                case .failure(let error):
                    completion(error)
                }
        }
    }

    /**
    Creates a Location with the specified displayName and address
     */
    func createLocation(displayName: String, address: [String: String], completion: @escaping (Location?, Error?) -> Void) {
        let url = self.baseURL.appendingPathComponent("create_location")
        let parameters: Parameters = [
            "display_name": displayName,
            "address": address
        ]

        Alamofire.request(url,
                          method: .post,
                          parameters: parameters
                          )
        .validate(statusCode: 200..<300)
        .responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let json as [String: AnyObject]):
                completion(Location.decodedObject(fromJSON: json), nil)
            case .success:
                completion(nil, NSError(domain: "example",
                                        code: 3,
                                        userInfo: [
                                            NSLocalizedDescriptionKey: "Failed to decode created location"
                    ]))
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
