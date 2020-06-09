//
//  HashTagDisplayViewController.swift
//  Smart Hashtags
//
//  Created by Akansha Bhardwaj on 12/05/20.
//  Copyright © 2020 Akansha Bhardwaj. All rights reserved.
//

import UIKit
import Social
import FBSDKShareKit

class HashTagDisplayViewController: UIViewController, SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print ("Completed")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Failed with error : \(error.localizedDescription)");
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print ("Canceled")
    }
    
    
    @IBOutlet weak var hashtagsTextView: UITextView!
    public var tags : [String] = []
    public var colors : [PhotoColor] = []
    var hashtagsString : String = ""
    var toUploadImage: UIImage = UIImage()
    
    @IBAction func shareNavigationBarButtonClicked(_ sender: UIBarButtonItem) {
                              let activityViewController = UIActivityViewController(activityItems: [toUploadImage, hashtagsString], applicationActivities: nil)
                              activityViewController.popoverPresentationController?.sourceView = self.view
                              self.present(activityViewController, animated: true, completion: nil)
                   
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //  print (tags)
        for i in 0..<tags.count {
            hashtagsString =  hashtagsString + "#" + tags[i].replacingOccurrences(of: " ", with: "") + " "
        }
        print(hashtagsString)
        hashtagsTextView.text = hashtagsString
        let button = FBShareButton()
        let photo = SharePhoto()
                   photo.image = toUploadImage
                   photo.isUserGenerated = true
                   let content = SharePhotoContent()
                   content.photos = [photo]
                   content.hashtag = Hashtag(hashtagsString)
        button.shareContent = content
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200).isActive = true
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
