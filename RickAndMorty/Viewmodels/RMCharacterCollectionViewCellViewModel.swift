//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 24/04/2023.
//

import Foundation

final class RMCharacterCollectionViewCellViewModel{
    public let characterName: String
    public let characterStatus: String?
    private let characterImageURL: URL?
    
    // MARK: - Init
    
    init(
        characterName: String,
        characterStatus: String?,
        characterImageURL: URL?
    ){
        self.characterName = characterName
        self.characterStatus = "Stauts: \(characterStatus?.uppercased() ?? "UKNOWN")"
        self.characterImageURL = characterImageURL
    }
    
    public func fetchImage(completion: @escaping (Result<Data, Error>) -> Void){
        // TODO: Abstract to Image manager
        guard let url = characterImageURL else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request){data, _, error in
            guard let data = data, error == nil else{
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
