//
//  ImagesCollectionController.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import UIKit

class ImagesCollectionController: UICollectionViewController, UpdateProtocol {
    
    let apiManager = ApiManager()
    var arrayOfImages: [ImageModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadImages()
        setUpController()
    }
    
    private func setUpController(){
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    private func loadImages(){
        apiManager.loadImages { (data, error) in
            if error != nil{
                let alert = UIAlertController(title: "Error", message: error!, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                let images = json["images"] as! NSArray
                
                for i in 0..<images.count {
                    
                    let dictionary = images[i] as! [String: AnyObject]
                    let parameters = dictionary["parameters"] as! [String: AnyObject]
                    if let imagePath = dictionary["smallImagePath"] as? String,
                        let address = parameters["address"] as? String,
                        let weather = parameters["weather"] as? String {

                    self.arrayOfImages.append(ImageModel(imageUrl: imagePath,
                                                         location: address,
                                                         weather: weather))
                    }
                }
                
                self.collectionView?.reloadData()
            } catch {
                
            }
        }
    }
    
    func updateController() {
        arrayOfImages.removeAll()
        loadImages()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(nil, forKey: "token")
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddImageViewController") as! AddImageViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath) as! ImageCollectionCell
        cell.imgPicture.loadImageFromURL(urlString: arrayOfImages[indexPath.row].imageUrl)
        cell.lblLocation.text = arrayOfImages[indexPath.row].location
        cell.lblTitle.text = arrayOfImages[indexPath.row].weather

        return cell
    }

}
