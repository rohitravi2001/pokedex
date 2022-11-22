//
//  PokedexCollectionViewController.swift
//  pokedex
//
//  Created by rohravi on 11/17/22.
//

import UIKit


class PokedexCollectionViewController: UICollectionViewController {
    var pokemonNames: [String] = []
    var pokemonURLs: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=300&offset=0")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print("Somthing went wrong")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PokedexResult.self, from: data)
                var pokeNames: [String] = []
                var pokeURLs: [String] = []
                let group = DispatchGroup()
                for res in result.results! {
                    group.enter()

                    self.fetchImage(pokemonURL: res.url) { (imageURL) in
                        pokeURLs.append(imageURL)
                        pokeNames.append(res.name)
                        group.leave()

                    }

                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        
                        self.pokemonNames = pokeNames
                        self.pokemonURLs = pokeURLs
                        print(self.pokemonNames)
                        print(self.pokemonURLs)
                        self.collectionView.reloadData()
                    }
                }

            }
            catch {
                
                print(error)
            }
        }
        
        task.resume()
        


    }
    
    func fetchImage(pokemonURL: String, completionHandler: @escaping (String) -> Void) {
        let url = URL(string: pokemonURL)!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
            print("Error with fetching pokemon images: \(error)")
            return
          }
          
          if let data = data,
            let pokemonDescription = try? JSONDecoder().decode(PokemonDescription.self, from: data) {
              completionHandler(pokemonDescription.sprites.front_default)
          }
        })
        task.resume()
      }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonNames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let pokemonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PokedexCollectionViewCell{
            pokemonCell.configure(with: pokemonNames[indexPath.row], pokemonURL: pokemonURLs[indexPath.row])
            cell = pokemonCell
        }
        cell.isHidden = false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print(pokemonNames[indexPath.row])

    }


}

/*
struct PokedexResult: Hashable, Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [PokemonInfo]?
}

struct PokemonInfo: Hashable, Codable {
    let name: String
    let url: String
}

struct PokemonDescription: Hashable, Codable {
    let sprites: Sprite
}

struct Sprite: Hashable, Codable {
    let front_default: String
}
*/


