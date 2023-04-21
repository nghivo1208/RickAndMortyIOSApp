//
//  RMCharacter.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import Foundation

struct RMCharacter: Codable{
    let id: Int
    let name: String
    let status: String? //RMCharacterStatus
    let species: String
    let type: String?
    let gender: String
    let origin: RMOrigin
    let location: RMSingleLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
}
