//
//  PlayGifViewController.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class PlayGifViewController: UIViewController {
    
    @IBOutlet weak var imgvGif: UIImageView!
    let apiManager = ApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGif()
    }
    
    private func loadGif(){
        apiManager.getGif { (gifUrl, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let image = UIImage.gif(url: gifUrl!)
            self.imgvGif.image = image
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
