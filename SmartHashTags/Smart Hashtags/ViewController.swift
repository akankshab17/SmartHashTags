//
//  ViewController.swift
//  Smart Hashtags
//
//  Created by Akansha Bhardwaj on 05/05/20.
//  Copyright © 2020 Akansha Bhardwaj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Social


class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    fileprivate var tags: [String]?
    fileprivate var colors: [PhotoColor]?
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SeagueToHashTagDisplay",
            let controller = segue.destination as? HashTagDisplayViewController {
            controller.tags = tags ?? []
            controller.colors = colors ?? []
            controller.toUploadImage = imageView.image ?? UIImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBAction func importHashtags(_ sender: Any) {
         activityIndicatorView.startAnimating()
        present(self.alert, animated: true, completion: nil)
        guard let image = imageView.image else {return}
        upload(
            image: image,
            progressCompletion: { [unowned self] percent in
              
            },
            completion: { [unowned self] tags, colors in
              
            self.activityIndicatorView.stopAnimating()
                self.alert.dismiss(animated: true, completion: nil)
                self.tags = tags
                self.colors = colors
                self.performSegue(withIdentifier: "SeagueToHashTagDisplay", sender: self)
        })
    }
    
    // print (tags)
    @IBAction func importImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source ", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)}
            else
            {
                print ("camera not available")
            }
        }))
        
        
        
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  nil))
        self.present(actionSheet, animated: true, completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image =  info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
         selectPictureUpdateConstraints()
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func selectPictureUpdateConstraints() {
        for constraint in self.view.constraints {
                  if constraint.identifier == "selectPictureTrailingAlignmentConstraint" {
                      constraint.isActive = false
                  }
              }
              self.view.layoutIfNeeded()
        
    }
    
    func upload(image: UIImage,
                progressCompletion: @escaping (_ percent: Float) -> Void,
                completion: @escaping (_ tags: [String], _ colors: [PhotoColor]) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData,
                                         withName: "image",
                                         fileName: "image.jpg",
                                         mimeType: "image/jpeg")
        },
            with: ImaggaRouter.content,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        progressCompletion(Float(progress.fractionCompleted))
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        // 1.
                        guard response.result.isSuccess else {
                            print("Error while uploading file: \(String(describing: response.result.error))")
                            completion([String](), [PhotoColor]())
                            return
                        }
                        
                        // 2.
                        guard let responseJSON = response.result.value as? [String: Any],
                            let uploadedFiles = responseJSON["result"] as? [String: Any],
                            let firstFileID = uploadedFiles["upload_id"] as? String else {
                                print("Invalid information received from service")
                                completion([String](), [PhotoColor]())
                                return
                        }
                       
                        
                        print("Content uploaded with ID: \(firstFileID)")
                        
                        // 3.
                        self.downloadTags(uploadId: firstFileID) { tags in
                            self.downloadColors(uploadId: firstFileID) { colors in
                                completion(tags, colors)
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    func downloadTags(uploadId: String, completion: @escaping ([String]) -> Void) {
        Alamofire.request(ImaggaRouter.tags(uploadId))
            .responseJSON { response in
                // 1.
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(String(describing: response.result.error))")
                    completion([String]())
                    return
                }
                
                // 2.
                guard let responseJSON = response.result.value as? [String: Any],
                    let result = responseJSON["result"] as? [String: Any],
                    let tagsAndConfidences = result["tags"] as? [[String: Any]] else {
                        print("Invalid tag information received from the service")
                        completion([String]())
                        return
                }
                
                // 3.
                let tags = tagsAndConfidences.compactMap({ dict -> String in
                    
                    guard let tag = dict["tag"] as? [String: Any],
                        let tagName = tag["en"] as? String else {
                            return ""
                    }
                    
                    return tagName
                })
                
                // 4.
                completion(tags)
        }
    }
    func downloadColors(uploadId: String, completion: @escaping ([PhotoColor]) -> Void) {
        Alamofire.request(ImaggaRouter.colors(uploadId))
            .responseJSON { response in
                // 2.
                guard response.result.isSuccess else {
                    print("Error while fetching colors: \(String(describing: response.result.error))")
                    completion([PhotoColor]())
                    return
                }
                
                // 3.
                guard let responseJSON = response.result.value as? [String: Any],
                    let result = responseJSON["result"] as? [String: Any],
                    let info = result["colors"] as? [String: Any],
                    let imageColors = info["image_colors"] as? [[String: Any]] else {
                        print("Invalid color information received from service")
                        completion([PhotoColor]())
                        return
                }
                
                // 4.
                let photoColors = imageColors.flatMap({ (dict) -> PhotoColor? in
                    guard let r = dict["r"] as? Int,
                        let g = dict["g"] as? Int,
                        let b = dict["b"] as? Int,
                        let closestPaletteColor = dict["closest_palette_color"] as? String else {
                            return nil
                    }
                    
                    return PhotoColor(red: Int(r),
                                      green: Int(g),
                                      blue: Int(b),
                                      colorName: closestPaletteColor)
                })
                
                // 5.
                completion(photoColors)
        }
    }
}
