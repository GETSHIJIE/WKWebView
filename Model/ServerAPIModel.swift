//
//  ServerAPIModel.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/5.
//  Copyright © 2020 shijie. All rights reserved.
//

import Foundation


class ServerAPIModel {
    
    func byGet(addr: String, completion: @escaping (Data) -> Void) -> Void {
        if let url = URL(string: addr){
            let task = URLSession.shared.dataTask(with: url ){
                (data, response, error) in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)");
                    return;
                }
                
                print(url as Any);
                
                if let response = response as? HTTPURLResponse,let data = data {
                    print("Status code: \(response.statusCode)");
                    completion(data);
                }
            }
            task.resume();
        }
    }
    
    func byPost(addr: String, completion: @escaping (Data) -> Void) -> Void {
        let url = URL(string: addr);
        var request = URLRequest(url: url!);
        request.httpMethod = "POST";
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type");
        request.httpBody = "".data(using: .utf8);
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if error != nil{
                return;
            }
            
            if let response = response as? HTTPURLResponse,let data = data {
                print("Status code: \(response.statusCode)")
                completion(data);
            }
        }
        task.resume();
    }
    
}

