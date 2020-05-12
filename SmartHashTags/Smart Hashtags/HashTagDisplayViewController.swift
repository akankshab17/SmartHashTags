//
//  HashTagDisplayViewController.swift
//  Smart Hashtags
//
//  Created by Akansha Bhardwaj on 12/05/20.
//  Copyright © 2020 Akansha Bhardwaj. All rights reserved.
//

import UIKit

class HashTagDisplayViewController: UIViewController {

    @IBOutlet weak var hashtagsTextView: UITextView!
    public var tags : [String] = []
    public var colors : [PhotoColor] = []
    
    
    override func viewDidLoad() {
        print (tags)
        hashtagsTextView.text = tags.first
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
