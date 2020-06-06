//
//  LoacationModel.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/4.
//  Copyright © 2020 shijie. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class LocationModel: NSObject {
    
    let locationMgr = CLLocationManager();
     
    func getLocationAuth() -> Bool {
        let status  = CLLocationManager.authorizationStatus()
        var locationResult: Bool = false;
                
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return locationResult;
        }
         
        if status == .denied || status == .restricted {
             let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
             
             let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
             alert.addAction(okAction)
             
             let UI = UIApplication.getPresentedViewController();
             UI?.present(alert, animated: true, completion: nil);
             return locationResult;
        }
        
        locationResult = true;
        
        return locationResult;
    }
    
    func getLocation() -> CLLocation {
        var location: CLLocation!;
                
        locationMgr.startUpdatingLocation();
        location = locationMgr.location;
        locationMgr.stopUpdatingLocation();
        
        return location;
    }
}
