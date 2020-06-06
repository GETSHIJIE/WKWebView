//
//  QrCodeModel.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/5.
//  Copyright © 2020 shijie. All rights reserved.
//

import Foundation
import AVFoundation

class QrCodeModel {

    func createAVCaptureSession() -> AVCaptureSession? {
        let avCaptureSession = AVCaptureSession();
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return nil}
        let videoInput:AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice);
        }catch let error {
            print(error)
            return nil;
        }
        if (avCaptureSession.canAddInput(videoInput) ){
            avCaptureSession.addInput(videoInput);
        }else{
            return nil;
        }
        
        return avCaptureSession;
    }
}
