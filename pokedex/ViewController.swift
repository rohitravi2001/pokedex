//
//  ViewController.swift
//  pokedex
//
//  Created by rohravi on 11/17/22.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let imageCache = NSCache<AnyObject, AnyObject>()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topPokemonImage: UIImageView!
    
    var pokemonNames: [String] = []
    var pokemonImages: [UIImage] = []
    var offset: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print("Somthing went wrong")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PokedexResult.self, from: data)
                var pokeNames: [String] = []
                var pokeImages: [UIImage] = []
                let group = DispatchGroup()
                for res in result.results! {
                    group.enter()

                    self.fetchImage(pokemonURL: res.url) { (imageURL) in
                        self.downloadImage(from: URL(string: imageURL)!) { (image) in
                            pokeNames.append(res.name)
                            pokeImages.append(image)
                            group.leave()

                        }

                    }

                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        
                        self.pokemonNames = pokeNames
                        self.pokemonImages = pokeImages
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completionHandler:@escaping(UIImage)->()) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            // always update the UI from the main thread
            completionHandler(UIImage(data: data)!)
        
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonNames.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let pokemonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PokedexCollectionViewCell{
            pokemonCell.configure(with: pokemonNames[indexPath.row], pokemonImage: pokemonImages[indexPath.row])
            cell = pokemonCell
        }
        cell.isHidden = false
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         self.topPokemonImage.image = pokemonImages[indexPath.row]

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        if distanceFromBottom == height {
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset="+String(self.offset))
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else {
                    print("Somthing went wrong")
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PokedexResult.self, from: data)

                    for res in result.results! {
                        if let all = self.imageCache.value(forKey: "allObjects") as? NSArray {
                            for object in all {
                                print("object is \(object)")
                            }
                        }
                        if let imageFromCache = self.imageCache.object(forKey: res.url as AnyObject) as? UIImage {
                            self.pokemonNames.append(res.name)
                            self.pokemonImages.append(imageFromCache)
                            print("In cache")
                            self.collectionView.reloadData()
                            continue
                        }

                        self.fetchImage(pokemonURL: res.url) { (imageURL) in
                            self.downloadImage(from: URL(string: imageURL)!) { (image) in
                                DispatchQueue.main.async {
                                    
                                    self.pokemonNames.append(res.name)
                                    self.pokemonImages.append(image)
                                    self.imageCache.setObject(image, forKey: imageURL as AnyObject)
                                    self.collectionView.reloadData()
                                }

                             }

                        }

                    }

                    

                }
                catch {
                    
                    print(error)
                }
            }
            
            task.resume()
            self.offset = self.offset + 20
        }
    }
    

    
 

}

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

