//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject{
    func didLoadInitialCharacter()
    func didSelectCharacter(_ character: RMCharacter)
}

// View Model to handle character list view logic
final class RMCharacterListViewViewModel: NSObject{
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var characters: [RMCharacter] = []{
        didSet{
            for character in characters{
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageURL: URL(string: character.image))
                cellViewModels.append(viewModel)
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var aipInfo: RMGetAllCharactersResponse.Info? = nil
    
    //fetch initial set of character (20)
    public func fetchCharacters(){
        RMService.shared.execute(.listCharacters, expecting: RMGetAllCharactersResponse.self){result in
            switch result{
            case .success(let responseModel):
                let result = responseModel.results
                let info = responseModel.info
                
                self.characters = result
                self.aipInfo = info
                
                DispatchQueue.main.async {
                    self.delegate?.didLoadInitialCharacter()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    //Paginate if additional characters are needed
    public func fetchAdditionalCharacter() {
    
    }
    
    public var shouldShowLoadMoreIndicator: Bool{
        return aipInfo?.next != nil
    }
    
}

// MARK: CollectionView

extension RMCharacterListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier, for: indexPath) as? RMCharacterCollectionViewCell else{
            fatalError("Unsupported cell")
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30)/2
        return CGSize(width: width, height: width*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}

// MARK: - Srcoll View
extension RMCharacterListViewViewModel: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
        guard shouldShowLoadMoreIndicator else { return }
    }
}
