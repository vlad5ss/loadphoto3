//
//  ViewController.swift
//  loadphoto3
//
//  Created by mac on 2/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var secondImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        textField.delegate=self
         searcImage(text: "panda")
        textField.becomeFirstResponder()
        imageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convert(farm: Int,server: String,photoId: String,secret: String) -> URL? {
        let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_c.jpg")
        print(url)
        return url
    }
    
    func showError(text: String){
        let alert = UIAlertController(title: "Mistake", message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert,animated: true)
        
        DispatchQueue.main.async {
               self.present(alert,animated: true)
        }
        
    }
    
    func showLoader(show: Bool){
        DispatchQueue.main.async {
            if show{
                self.loader.startAnimating()
                self.imageView.image = nil
                self.secondImageView.image = nil
            } else {
                self.loader.stopAnimating()
            }
        }
    }

    func searcImage(text: String){
        showLoader(show: true)
        
        //https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=64147ab7d6588a0822243b78336b26b9&text=zebra&format=json&nojsoncallback=1
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=a1cfc052392d1e9e9e1289df9a3fcf6e"
        let format = "&format=json&nojsoncallback=1"
        let farmattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let textToSearch="&text=\(farmattedText)"
        let sort = "&sort=relevance"
        let searchUrl=base+key+format+textToSearch+sort
        let url = URL(string: searchUrl)!
        
        URLSession.shared.dataTask(with: url) {(data, _, _) in
            guard let jsonData = data else{
            self.showError(text: "Don't have data")
                self.showLoader(show: false)
            return
            }
            
            guard let jsonAny = try? JSONSerialization.jsonObject(with: jsonData, options: []) else{
                self.showError(text: "Don't have a json")
                self.showLoader(show: false)
               return
            }
            guard let json = jsonAny as? [String: Any] else{
                return
            }
            
//              print(json)
            guard let photos = json["photos"] as? [String: Any] else {
                 self.showLoader(show: false)
                return
            }
            
            guard let photosArray = photos["photo"] as? [Any] else{
                 self.showLoader(show: false)
                return
            }
            
            guard  photosArray.count>=2 else {
                 self.showLoader(show: false)
             self.showError(text: "don't have the two photos")

                return
            }
//
////            if photosArray.count>=5 {
////                for photo in photosArray.enumerated() {
////                  print("Number",photo.offset)
////                      print("Photo",photo.element)
////                }
////                print("ddd")
////            }
//
             guard let firstPhoto = photosArray[0] as? [String: Any] else {
                 self.showLoader(show: false)
                return
            }

            guard let secondPhoto = photosArray[1] as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            
            self.loadImage(firstPhoto: firstPhoto,imageView: self.imageView)
            self.loadImage(firstPhoto: secondPhoto,imageView:self.secondImageView)
        }.resume()

    }
    
    func loadImage(firstPhoto:[String: Any],imageView: UIImageView){
            let farm = firstPhoto["farm"] as! Int
            let id = firstPhoto["id"] as! String
            let secret = firstPhoto["secret"] as! String
            let server = firstPhoto["server"] as! String
            
            let pictureUrl = self.convert(farm: farm, server: server, photoId: id, secret: secret)
            
            URLSession.shared.dataTask(with: pictureUrl!, completionHandler: {(data, _, _) in
                DispatchQueue.main.async {
//                    self.imageView.image = UIImage(data: data!)
                    imageView.image = UIImage(data: data!)
                }
                self.showLoader(show: false)
            }).resume()
            }
    
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searcImage(text: textField.text!)
        return true
    }

}


