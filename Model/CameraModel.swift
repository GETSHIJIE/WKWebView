//
//  AuthorizationModel.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/4.
//  Copyright © 2020 shijie. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


class CameraModel {
    
    func getCameraAuth() -> Bool {
        var cameraResult: Bool = false;
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video);
        switch authStatus {
        case .denied:
            print("denied");
            self.presentCameraSetting();
            break;
        case .restricted:
            print("restricted");
            break;
        case .authorized:
            print("authorized");
            cameraResult = true;
            break;
        case .notDetermined:
            print("notDetermined");
            AVCaptureDevice.requestAccess(for: .video) { (success) in
                if(success){
                    cameraResult = true;
                }else{
                    print("permission not granted");
                }
            }
            break;
        default:
            break;
        }
        
        return cameraResult;
    }
    
    func presentCameraSetting(){
        let alertConroller = UIAlertController(title: "Error", message: "Camera access is denied", preferredStyle: .alert);
        alertConroller.addAction(UIAlertAction(title: "Cancel", style: .default));
        alertConroller.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString)
            {
                UIApplication.shared.open(url, options: [:]) { _ in
                    
                }
            }
            
        }))
        
        let UI = UIApplication.getPresentedViewController();
        UI?.present(alertConroller, animated: true, completion: nil);
    }
    
}
