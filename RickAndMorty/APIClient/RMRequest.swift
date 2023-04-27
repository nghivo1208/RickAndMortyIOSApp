//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import Foundation

/// Object represent a single API call
final class RMRequest{
    
    /// API Constants
    private struct Constant{
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired endpoint
    private let endPoint: RMEndpoint
    
    /// Path component for API, if any
    private let pathComponents: [String]
    
    /// Query argument for API, if any
    private let queryParameters: [URLQueryItem]
    
    /// Constructedurl for the api request in string format
    private var urlString: String{
        var string = Constant.baseUrl
        string += "/"
        string += endPoint.rawValue
        
        if !pathComponents.isEmpty{
            pathComponents.forEach({
                string += "/\($0)"       // $0 represent the particular path component
            })
        }
        if !queryParameters.isEmpty{
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            string += argumentString
        }
        return string
    }
    
    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Desired http method
    public let httpMethod = "GET"
    
    
    // MARK: - Public
    
    
    /// Construct request
    /// - Parameters:
    ///   - endPoint: Target endpoint
    ///   - pathComponents: Collection of Path components
    ///   - queryParameters: Collection of query parameters
    public init(endPoint: RMEndpoint,
         pathComponents: [String] = [],
         queryParameters: [URLQueryItem] = []
    ){
        self.endPoint = endPoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    /// Attempt to create request
    /// - Parameter url: URL to parse
    convenience init?(url: URL){
        let string = url.absoluteString
        if !string.contains(Constant.baseUrl){
            return nil
        }
        
        let trimmed = string.replacingOccurrences(of: Constant.baseUrl + "/", with: "")     //baseURL.com/character/abc
        if trimmed.contains("/"){
            //after trim trimmed = "character/abc"
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty{
                let endpointString = components[0]
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let rmEndpoint = RMEndpoint(
                    rawValue: endpointString
                ){
                    self.init(endPoint: rmEndpoint, pathComponents: pathComponents)
                    return
                }
            }
        }else if trimmed.contains("?"){
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2{
                let endpointString = components[0]
                let queryItemsString = components[1]
                //value=name&value=name
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let part = $0.components(separatedBy: "=")
                    
                    return URLQueryItem(name: part[0], value: part[1])
                })
                if let rmEndpoint = RMEndpoint(rawValue: endpointString){
                    self.init(endPoint: rmEndpoint, queryParameters: queryItems)
                    return
                }
            }
        }
        return nil
    }
}

extension RMRequest{
    static let listCharacters = RMRequest(endPoint: .character)
}
