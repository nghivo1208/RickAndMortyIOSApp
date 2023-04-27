//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 25/04/2023.
//

import Foundation

final class RMCharacterDetailViewViewModel{
    
    private let character: RMCharacter
    init(character: RMCharacter){
        self.character = character
    }
    
    private var requestUrl: URL?{
        return URL(string: character.url)
    }
    
    public var title: String{
        character.name.uppercased()
    }
}
