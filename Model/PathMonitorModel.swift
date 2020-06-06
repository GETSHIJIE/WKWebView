//
//  PathMonitorModel.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/5.
//  Copyright © 2020 shijie. All rights reserved.
//

import Foundation
import Network

class PathMonitor {
    
    private let monitor = NWPathMonitor();
    
    func checkInternet(completion: @escaping (NWPath) -> Void) -> Void {
        
        monitor.pathUpdateHandler = { path in
            completion(path);
        }
        monitor.start(queue: DispatchQueue.global());
    }
    
}
