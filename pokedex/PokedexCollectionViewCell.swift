//
//  PokedexCollectionViewCell.swift
//  pokedex
//
//  Created by rohravi on 11/17/22.
//

import UIKit

class PokedexCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pokemonLabel: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    
    func configure(with pokemonName: String, pokemonImage: UIImage) {
        pokemonLabel.text = pokemonName
        self.pokemonImage.image = pokemonImage
    }

}
