//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 21/04/2023.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject{
    func didLoadInitialCharacter()
    func didLoadMoreCharacter(with newIndexpath: [IndexPath])
    func didSelectCharacter(_ character: RMCharacter)
}

// View Model to handle character list view logic
final class RMCharacterListViewViewModel: NSObject{
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var isLoadingMoreCharacter = false
    
    private var characters: [RMCharacter] = []{
        didSet{
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageURL: URL(string: character.image))
                if !cellViewModels.contains(viewModel){
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
    //fetch initial set of character (20)
    public func fetchCharacters(){
        RMService.shared.execute(.listCharacters, expecting: RMGetAllCharactersResponse.self){result in
            switch result{
            case .success(let responseModel):
                let result = responseModel.results
                let info = responseModel.info
                
                self.characters = result
                self.apiInfo = info
                
                DispatchQueue.main.async {
                    self.delegate?.didLoadInitialCharacter()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    //Paginate if additional characters are needed
    public func fetchAdditionalCharacter(url: URL) {
        guard !isLoadingMoreCharacter else{ return }
        isLoadingMoreCharacter = true
        
        guard let request = RMRequest(url: url) else{
            isLoadingMoreCharacter = false
            return
        }
        
        RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self){[weak self] result in
            guard let strongSelf = self else{
                return
            }
            switch result{
            case .success(let responseModel):
                let moreResluts = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                
                let originalCount = strongSelf.characters.count
                let newCount = moreResluts.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                
                let indexPathToAdd: [IndexPath] = Array(startingIndex ..< (startingIndex + newCount)).compactMap{
                    return IndexPath(row: $0, section: 0)
                }
                strongSelf.characters.append(contentsOf: moreResluts)
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreCharacter(with: indexPathToAdd)
                    strongSelf.isLoadingMoreCharacter = false
                }
                
            case .failure(let error):
                print(String(describing: error))
                self?.isLoadingMoreCharacter = false
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool{
        return apiInfo?.next != nil
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath) as? RMFooterLoadingCollectionReusableView
        else{
            fatalError("Unsupported")
        }
        footer.startAnimating()
        return footer
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else{
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 100)
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
        guard shouldShowLoadMoreIndicator,
              !isLoadingMoreCharacter,
              !cellViewModels.isEmpty,
              let nextURLString = apiInfo?.next,
              let url = URL(string: nextURLString)
        else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false){[weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalContentViewFixHeight = scrollView.frame.size.height
            
            if offset >= (totalContentHeight - totalContentViewFixHeight - 120){
                self?.fetchAdditionalCharacter(url: url)
            }
            t.invalidate()
        }
    }
}
