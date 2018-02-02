//
//  ViewController.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import UIKit
import CoreLocation

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var constTopTxfEmail: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    private let apiManager = ApiManager()
    private var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        
    }
    
    private func setupController(){
        locManager.requestWhenInUseAuthorization()
        
        txfEmail.delegate = self
        txfPassword.delegate = self
        
        let scrollViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollRecognizer(tapGestureRecognizer:)))
        scrollView.addGestureRecognizer(scrollViewGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    private func scrollRecognizer (tapGestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            txfPassword.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        
        if !(txfEmail.text?.isEmpty)! && !(txfPassword.text?.isEmpty)! {
            //// Put Real data
            apiManager.logIn(email: txfEmail.text!, password: txfPassword.text!) { (token, error) in
                if error != nil{
                    self.createAlert(message: error!)
                    return
                }
                
                UserDefaults.standard.set(token!, forKey: "token")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImagesCollectionController") as! ImagesCollectionController
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            createAlert(message: "fill the fields")
        }
    }
    
    private func createAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.value(forKey: "token") != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImagesCollectionController") as! ImagesCollectionController
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification){
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.constTopTxfEmail.constant = 160
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification){
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.constTopTxfEmail.constant = 200
            self.view.layoutIfNeeded()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

