//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Vo Le Dinh Nghi on 24/04/2023.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...){
        views.forEach({
            addSubview($0)
        })
    }
}
