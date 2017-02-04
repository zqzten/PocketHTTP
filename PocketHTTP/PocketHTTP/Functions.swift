//
//  Functions.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/2/4.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit

func makeURL(onBase baseURL: String, withPara parameters: [[String]]) -> String {
    var url = baseURL
    var isFirstPara = true
    for parameter in parameters {
        if parameter[0] != "" || parameter[1] != "" {
            if isFirstPara {
                url += ("?" + parameter[0] + "=" + parameter[1])
                isFirstPara = false
            } else {
                url += ("&" + parameter[0] + "=" + parameter[1])
            }
        }
    }
    return url
}

func splitURL(_ url: String) -> (baseURL: String, parameters: [[String]]) {
    let components = url.components(separatedBy: "?")
    let baseURL = components[0]
    var parameters = [[String]]()
    if components.count == 2 {
        let parameterComponents = components[1].components(separatedBy: "&")
        for parameterComponent in parameterComponents {
            let parameterPair = parameterComponent.components(separatedBy: "=")
            if parameterPair.count == 2 {
                parameters.append([parameterPair[0], parameterPair[1]])
            }
        }
    }
    parameters.append(["", ""])
    return (baseURL: baseURL, parameters: parameters)
}

func systemBlue() -> UIColor {
    return UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
}
