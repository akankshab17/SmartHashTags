//
//  Model.swift
//  Smart Hashtags
//
//  Created by Akansha Bhardwaj on 12/05/20.
//  Copyright © 2020 Akansha Bhardwaj. All rights reserved.
//

import Foundation
import UIKit
import Social

public struct PhotoColor {
    let red: Int
    let green: Int
    let blue: Int
    let colorName: String
  }

  public struct TagsColorTableData {
    var label: String
    var color: UIColor?
  }

 public class TextProvider: NSObject, UIActivityItemSource {
    var text: String
    
    public init(text: String) {
        self.text = text
        super.init()
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
}

 public class ImageProvider: NSObject, UIActivityItemSource {
    var image: UIImage
       
       public init(image: UIImage) {
           self.image = image
           super.init()
       }
    
   public  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
}
