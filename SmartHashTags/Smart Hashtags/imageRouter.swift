//
//  imageRouter.swift
//  Smart Hashtags
//
//  Created by Akansha Bhardwaj on 11/05/20.
//  Copyright © 2020 Akansha Bhardwaj. All rights reserved.
//

import Foundation
import Alamofire
public enum ImaggaRouter: URLRequestConvertible {
  enum Constants {
     static let baseURLPath = "https://api.imagga.com/v2"
    static let authenticationToken = "Basic YWNjXzAxZGM3NGUxNTEyNGRlNDo2NTQ5OWY3ODU3YWJiNTg0Mzc5NGM3YzlhNTI3OWQwNg=="
  }
case content
  case tags(String)
  case colors(String)
  
  var method: HTTPMethod {
    switch self {
    case .content:
      return .post
    case .tags, .colors:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .content:
      return "/uploads"
    case .tags:
      return "/tags"
    case .colors:
      return "/colors"
    }
  }
  
  public func asURLRequest() throws -> URLRequest {
    let parameters: [String: Any] = {
      switch self {
      case .tags(let uploadId):
        return ["image_upload_id": uploadId]
      case .colors(let uploadId):
        return ["image_upload_id": uploadId, "extract_object_colors": 0]
      default:
        return [:]
      }
    }()
    
    let url = try ImaggaRouter.Constants.baseURLPath.asURL()  //.baseURLPath //.asURL()
    
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.setValue(ImaggaRouter.Constants.authenticationToken, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = TimeInterval(10 * 1000)
    
    return try URLEncoding.default.encode(request, with: parameters)
  }
}
