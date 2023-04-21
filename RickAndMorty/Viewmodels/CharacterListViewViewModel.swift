//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import Foundation

struct CharacterListViewViewModel{
    func fetchCharacters(){
        RMService.shared.execute(.listCharacters, expecting: RMGetAllCharactersResponse.self){result in
            switch result{
            case .success(let model):
                print("Total: \(String(model.info.pages))")
                print("Page result count: \(String(model.results.count))")
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
}
