//
//  AddImageViewController.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import UIKit
import CoreLocation

protocol UpdateProtocol {
    func updateController()
}


class AddImageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgvPicture: UIImageView!
    @IBOutlet weak var txfDescription: UITextField!
    @IBOutlet weak var txfhashtag: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var constTopImgvPicture: NSLayoutConstraint!
    private let imagePicker = UIImagePickerController()
    
    private var locManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private let apiManager = ApiManager()
    private var pickedImage: UIImage!
    var delegate: UpdateProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
    }
    
    private func setupController(){
        
        activityIndicator.isHidden = true
        txfDescription.delegate = self
        txfhashtag.delegate = self
        imagePicker.delegate = self
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            currentLocation = locManager.location
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture(tapGestureRecognizer:)))
        imgvPicture.isUserInteractionEnabled = true
        imgvPicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    private func choosePicture(tapGestureRecognizer: UITapGestureRecognizer){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func SendImage(_ sender: UIButton) {
        
        if pickedImage != nil {
            self.activityIndicator.isHidden = false
            self.view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            apiManager.uploadImage(image: imgvPicture.image!, description: txfDescription.text!, hashtag: txfhashtag.text!, latitude: Float(currentLocation.coordinate.latitude), longitude: Float(currentLocation.coordinate.longitude)) { (complete, error) in
                
                if error != nil {
                    self.activityIndicator.isHidden = true
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.createAlert(message: error!)
                    return
                }
                
                self.delegate.updateController()
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            createAlert(message: "choose image")
        }
    }
    
    
    private func createAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            txfhashtag.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage = image
            imgvPicture.contentMode = .scaleAspectFit
            imgvPicture.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
