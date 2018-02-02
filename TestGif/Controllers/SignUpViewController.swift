//
//  SignUpViewController.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txfUserName: UITextField!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var imgvPicture: UIImageView!
    @IBOutlet weak var constTopImvPicture: NSLayoutConstraint!
    private let imagePicker = UIImagePickerController()
    private let apiManager = ApiManager()
    private var pickedImage: UIImage!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    private func setupController(){
        activityIndicator.isHidden = true
        txfUserName.delegate = self
        txfEmail.delegate = self
        txfPassword.delegate = self
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture(tapGestureRecognizer:)))
        imgvPicture.isUserInteractionEnabled = true
        imgvPicture.addGestureRecognizer(tapGestureRecognizer)
        
        let scrollViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollRecognizer(tapGestureRecognizer:)))
        scrollView.addGestureRecognizer(scrollViewGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    private func choosePicture(tapGestureRecognizer: UITapGestureRecognizer){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc
    private func scrollRecognizer (tapGestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgvPicture.contentMode = .scaleAspectFit
            pickedImage = image
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
    
    @IBAction func signUp(_ sender: UIButton) {
        
        
        if !(txfUserName.text?.isEmpty)! && !(txfEmail.text?.isEmpty)! && !(txfPassword.text?.isEmpty)! && pickedImage != nil {
            
            self.activityIndicator.isHidden = false
            self.view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            
            apiManager.registration(username: txfUserName.text!, email: txfEmail.text!, password: txfPassword.text!, image: imgvPicture.image!) { (token, error) in
                if let errorDescription = error {
                    self.createAlert(message: errorDescription)
                    return
                }
                
                UserDefaults.standard.set(token, forKey: "token")
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImagesCollectionController") as! ImagesCollectionController
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        } else {
            createAlert(message: "fill all fields")
        }
        
    }
    
    private func createAlert(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.activityIndicator.isHidden = true
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            txfEmail.becomeFirstResponder()
        case 2:
            txfPassword.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification){
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.constTopImvPicture.constant = -180
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification){
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.constTopImvPicture.constant = 20
            self.view.layoutIfNeeded()
        })
    }
    
}
