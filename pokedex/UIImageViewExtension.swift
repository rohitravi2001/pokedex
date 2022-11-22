//
//  UIImageViewExtension.swift
//  pokedex
//
//  Created by rohravi on 11/21/22.
//

import Foundation
import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView {
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
    
    
  func cacheImage(urlString: String){
    let url = URL(string: urlString)
        
    if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
        self.image = imageFromCache
        return
    }
      
      let task = URLSession.shared.dataTask(with: url!) { data, response, error in
          guard let data = data, error == nil else {
              print("Somthing went wrong")
              return
          }
          
          do {
              let result = try JSONDecoder().decode(PokedexResult.self, from: data)
              for res in result.results! {

                  self.fetchImage(pokemonURL: res.url) { (imageURL) in
                      self.downloadImage(from: URL(string: imageURL)!) { (image) in
                          DispatchQueue.main.async {
                              imageCache.setObject(image, forKey: urlString as AnyObject)
                          self.image = image
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
  }
}

