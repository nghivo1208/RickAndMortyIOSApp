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
    
    public var title: String{
        character.name.uppercased()
    }
}
