//
//  ExtensionImageView.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageFromURL(urlString: String) {
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
                self.image = imageToCache
            }
            
            
            }.resume()
    }
}

