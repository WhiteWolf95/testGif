//
//  ApiManager.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    
    private let BASE_URL = "http://api.doitserver.in.ua"
    
    func logIn(email: String, password: String, completion: @escaping (_ token: String?, _ error: String?) -> Void){
        
        let parameters = ["email": email, "password": password] as [String : Any]
        
        Alamofire.request("\(BASE_URL)/login", method: .post, parameters: parameters).response { response in
            
            let code = response.response?.statusCode
            
            if code! == 400 {
                completion(nil, "Incorrect email or password")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                
                if let token = json["token"] as? String {
                    completion(token, nil)
                }
            } catch {
                
            }
            
        }
    }
    
    func registration(username: String, email: String, password: String, image: UIImage, completion: @escaping (_ token: String?, _ error: String?) -> Void) {
        
        let mageData = UIImagePNGRepresentation(image);
        
        let parameters = ["username": username, "email": email, "password": password] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = mageData {
                multipartFormData.append(data, withName: "avatar", fileName: "image.png", mimeType: "image/png")
                
            }
            
        }, usingThreshold: UInt64.init(), to: "\(BASE_URL)/create", method: .post) { (result) in
            
            switch result{
                
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                        if let children = json["children"] as? [String:AnyObject] {
                            let email = children["email"] as! [String:AnyObject]
                            let avatar = children["avatar"] as! [String:AnyObject]
                            if email["errors"] != nil {
                                completion(nil, String(describing: email["errors"]!))
                                return
                            }
                            
                            if avatar["errors"] != nil {
                                completion(nil, String(describing: avatar["errors"]!))
                                return
                            }
                        }
                        
                        if let token = json["token"] as? String {
                            completion(token, nil)
                        }
                    } catch {
                        
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(nil, error.localizedDescription)
                
            }
        }
        
    }
    
    func loadImages(completion: @escaping (_ data: Data?, _ error: String?) -> Void){
        
        let headers = [
            "token": UserDefaults.standard.value(forKey: "token") as! String
        ]
        
        Alamofire.request("\(BASE_URL)/all", method: .get, headers: headers).response { (response) in
            
            
            let code = response.response?.statusCode
            
            if code! == 403 {
                completion(nil, "Invalid access token")
                return
            }
            
            completion(response.data, nil)
            
        }
    }
    
    func getGif(completion: @escaping (_ gifUrl: String?, _ error: String?) -> Void){
        
        let headers = [
            "token": UserDefaults.standard.value(forKey: "token") as! String
        ]
        
        Alamofire.request("\(BASE_URL)/gif", method: .get, headers: headers).response { (response) in
            
            let code = response.response?.statusCode
            
            if code! == 403 {
                completion(nil, "Invalid access token")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                
                if let gifUrl = json["gif"] as? String {
                    completion(gifUrl, nil)
                }
                
            } catch {
                
            }
            
        }
    }
    
    func uploadImage(image: UIImage, description: String, hashtag: String, latitude: Float, longitude: Float, completion: @escaping( _ complete: Bool, _ error: String?) -> Void){
        
        let headers = [
            "token": UserDefaults.standard.value(forKey: "token") as! String
        ]
        
        let imageData = UIImagePNGRepresentation(image);
        
        let parameters = ["description": description, "hashtag": hashtag, "latitude": String(latitude), "longitude": String(longitude)] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData {
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
                
            }
            
        }, usingThreshold: UInt64.init(), to: "\(BASE_URL)/image", method: .post, headers: headers) { (result) in
            
            switch result{
                
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                        if let children = json["children"] as? [String:AnyObject] {
                            
                            let image = children["image"] as? [String:AnyObject]
                            completion(false, String(describing: image!["errors"]!))
                            return
                        }
                        completion(true,nil)
                    } catch {
                        
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                
            }
        }
        
        
    }
    
}
