//
//  RMService.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import Foundation


/// Primary API service object to get Rick and Morty data
final class RMService{
    
    /// Share singleton instance
    static let shared = RMService()
    
    enum RMRequestError: Error{
        case failedToCreateRequest
        case failedToGetData
    }
    
    /// Privatized contructor
    private init(){}
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Request instance
    ///   - completion: Callback with data or error
    ///   - type: The type of object we expect to get back
    public func execute<T: Codable>(_ request: RMRequest,
                                    expecting type: T.Type,
                                    completion: @escaping (Result<T,Error>) -> Void){
        
        guard let urlRequest = self.request(from: request) else {
            completion(.failure(RMRequestError.failedToCreateRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest){data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? RMRequestError.failedToGetData))
                return
            }
            
            //Decode response
            do{
                let result = try JSONDecoder().decode(type.self, from: data)
                completion(.success(result))
            }
            catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Private
    
    private func request(from rmRequset: RMRequest) -> URLRequest?{
        guard let url = rmRequset.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = rmRequset.httpMethod
        
        
        return request
    }
    
    
}
