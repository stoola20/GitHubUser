////
//  RequestProtocol.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

/// Protocol for making network requests and handling responses.
protocol RequestProtocol {
    /// Sends a network request and returns the response as an observable sequence.
    ///
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - method: The HTTP method for the request.
    ///   - parameters: The parameters to be sent in the request, if any.
    ///   - header: The HTTP header fields for the request.
    ///   - type: The type of the expected response.
    /// - Returns: An observable sequence that emits the decoded response or an error.
    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<T>
    
    /// Sends a network request and returns both the response and headers as an observable sequence.
        ///
        /// - Parameters:
        ///   - url: The URL for the request.
        ///   - method: The HTTP method for the request.
        ///   - parameters: The parameters to be sent in the request, if any.
        ///   - header: The HTTP header fields for the request.
        ///   - type: The type of the expected response.
        /// - Returns: An observable sequence that emits a tuple containing the decoded response and headers, or an error.
    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<(T, [String: Any]?)>
}

/// Default implementation for sending a network request.
extension RequestProtocol {

    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<(T, [String: Any]?)> {
        guard let url = url else {
            return Observable.error(ServerError.unknownError)
        }

        return requestData(
            method,
            url,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: HTTPHeaders(header)
        )
        .debug("⏳")
        .flatMap { response, responseData -> Observable<(T, [String: Any]?)> in
            let headers = response.allHeaderFields as? [String: Any] // Capture the response headers
            
            if response.statusCode == 404 {
                return Observable.error(ServerError.requestFailure("Resource not found"))
            }
            
            if response.statusCode == 304 {
                return Observable.error(ServerError.requestFailure("Not modified"))
            }
            
            if response.statusCode != 200 {
                let msg = String(data: responseData, encoding: .utf8)
                return Observable.error(ServerError.requestFailure(msg ?? ""))
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let resultModel = try decoder.decode(type, from: responseData)

                return Observable.just((resultModel, headers))
            } catch {
                return Observable.error(ServerError.parsingFailure)
            }
        }
    }


    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<T> {
        guard let url else {
            return Observable.error(ServerError.unknownError)
        }

        return requestData(method,
                           url,
                           parameters: parameters,
                           encoding: URLEncoding.default,
                           headers: HTTPHeaders(header))
            .debug("⏳")
            .flatMap { response, responseData -> Observable<T> in
                if response.statusCode == 404 {
                    return Observable.error(ServerError.requestFailure("Resource not found"))
                }
                
                if response.statusCode == 304 {
                    return Observable.error(ServerError.requestFailure("Not modified"))
                }
                
                if response.statusCode != 200 {
                    let msg = String(data: responseData, encoding: .utf8)
                    return Observable.error(ServerError.requestFailure(msg ?? ""))
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let resultModel = try decoder.decode(type, from: responseData)

                    return Observable.just(resultModel)
                } catch {
                    return Observable.error(ServerError.parsingFailure)
                }
            }
    }
}

/// Enum representing possible server errors.
enum ServerError: Error {
    /// Indicates a failure in the network request.
    case requestFailure(String)
    /// Indicates a failure in parsing the response.
    case parsingFailure
    /// Indicates an unknown error.
    case unknownError
}

extension ServerError {
    /// Provides a readable description for each server error case.
    var errorDescription: String {
        switch self {
        case .requestFailure(let description):
            return description
        case .parsingFailure:
            return "Failed to parse the response data."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
