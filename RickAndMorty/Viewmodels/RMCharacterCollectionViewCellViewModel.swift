//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 24/04/2023.
//

import Foundation

final class RMCharacterCollectionViewCellViewModel: Hashable, Equatable{
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
        RMImageLoader.shared.downloadImage(url, completion: completion)
    }
    
    //MARK: Hashable
    
    static func == (lhs: RMCharacterCollectionViewCellViewModel, rhs: RMCharacterCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageURL)
    }
    
}
