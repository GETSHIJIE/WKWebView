//
//  ViewController.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/3.
//  Copyright © 2020 shijie. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import AVFoundation

class ViewController: UIViewController {

    private let tbName: String = "UserInfoTable";
    
    var webView: WKWebView!;
    
    let locationModel = LocationModel();
    let cameraModel = CameraModel();
    let serverAPIModel = ServerAPIModel();
    let pathMonitor = PathMonitor();
    let qrCodeModel = QrCodeModel();
    let sqLite = SQLiteController();
    
    var timer: Timer?;
    
    var avCaptureSession = AVCaptureSession();
    var previewLayer: AVCaptureVideoPreviewLayer!;
        
    //=====================================
    struct WebViewData: Codable {
        var kind: String;
        var data: String;
    }
    
    struct SqlDelete: Codable {
        var kind: String;
        var data: delete;
    }
    struct delete: Codable {
        let delete: Int;
    }
    
    struct Brightness: Decodable {
        var kind: String;
        var brightness: Int;
    }
    
    struct Authorization {
        var camera: Bool;
        var location: Bool;
    }
    var auth: Authorization! = Authorization(camera: false, location: false);
    
    //=====================================
    
    var isPathMonitor: Bool = false;

    //=====================================
    override func loadView() {
        createWebView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView();
        
        Init();
    }
    
    private func Init() -> Void {
        
        //Create WebView Back Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.goBack));
        
        //Create DB Table
        sqLite.DBCreateTable(dbTableName: tbName);
    }
    
    private func createWebView(){
        let webConfiguration = WKWebViewConfiguration();
        webConfiguration.userContentController = WKUserContentController();
        webConfiguration.userContentController.add(self, name: "ToApp");
        webView = WKWebView(frame: .zero, configuration: webConfiguration);
        webView.uiDelegate = self;
        view = webView;
    }
    
    private func loadWebView(){
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "website")! ;
        
        webView.loadFileURL(url, allowingReadAccessTo: url);
        let request = URLRequest(url: url);
        webView.navigationDelegate = self;
        webView.load(request);
        self.view.sendSubviewToBack(webView);
    }
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack();
        }
    }
    
    private func defineWVData(wvData: WebViewData) -> Void {
        print(wvData);
        var data: String = "";
        switch wvData.kind {
            
        //----- access_privilege -----
            
        case "access_privilege":
            if(wvData.data == "camera_privileges" || wvData.data == "get_all_privileges"){
                auth.camera = cameraModel.getCameraAuth();
            }
            if(wvData.data == "location_privileges" || wvData.data == "get_all_privileges"){
                auth.location = locationModel.getLocationAuth();
            }
            data = "{\"camera\":\(auth.camera),\"location\":\(auth.location)}";
            self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: data));
            break;
        
        //----- get_location -----
        case "get_location":
            if(wvData.data == "start_gps"){
                runTimer(sec: 3) {
                    let location = self.locationModel.getLocation();
                    let longitude = location.coordinate.longitude;
                    let latitude = location.coordinate.latitude;
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
                    let date = Date()
                    let datetime = dateFormatter.string(from: date);
                    data = "{\"longitude\":\"\(longitude)\",\"latitude\":\"\(latitude)\",\"datatime\":\"\(datetime)\"}";
                    self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: data));
                }
                
            }else if(wvData.data == "stop_gps"){
                timer?.invalidate();
            }
            break;
            
        //----- server_api -----
        case "server_api":
            if(wvData.data == "post"){
                let addr = "https://nkl.socialbook.com.tw/api/Login/validate_code";
                serverAPIModel.byPost(addr: addr) { (_data) in
                    do {
                        let object = try JSONSerialization.jsonObject(with: _data, options: .allowFragments)
                        if let dictionary = object as? [String: AnyObject] {
                            var dic = dictionary;
                            dic["type"] = "post" as AnyObject;
                            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: []);
                            let decoded = String(data: jsonData, encoding: .utf8)!;
                            data = decoded;
                        }
                    } catch {
                    }
                    DispatchQueue.main.async {
                        self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: data));
                    }
                }
                
            }else if(wvData.data == "get"){
                let addr = "https://nkl.socialbook.com.tw/api/Analysis/getEnterpriseList";
                serverAPIModel.byGet(addr: addr) { (_data) in
                    
                    do {
                        let object = try JSONSerialization.jsonObject(with: _data, options: .allowFragments)
                        if let dictionary = object as? [String: AnyObject] {
                            var dic = dictionary;
                            dic["type"] = "get" as AnyObject;
                            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: []);
                            let decoded = String(data: jsonData, encoding: .utf8)!;
                            data = decoded;
                        }
                    } catch {
                    }
                    DispatchQueue.main.async {
                        self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: data));
                    }
                }
            }
            
            break;
            
        //----- check_network -----
        case "check_network":
            pathMonitor.checkInternet { (path) in
                var isCheck: Bool = false;
                if path.status == .satisfied {
                    isCheck = true;
                }
                data = "\(isCheck)";
                if(self.isPathMonitor != isCheck){
                    self.isPathMonitor = isCheck;
                    DispatchQueue.main.async {
                        self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: data));
                    }
                }
            }
            break;
            
            
        //----- scan_qrcode -----
        case "scan_qrcode":
            self.startQRCodeScan();
            break;
            
        //----- sqlite_setup -----
        case "sqlite":
            if(wvData.data == "search"){
                 data = sqLite.fetchData(offset: 0);
            }else if(wvData.data == "insert"){
                let str = "Test";
                if(sqLite.isInsert(data: str)){
                    data = sqLite.fetchData(offset: 0);
                }
            }else{
                let key = wvData.data.components(separatedBy: ":"); //delete:id
                if(key[0] == "delete"){
                    sqLite.deleteData(id: Int(key[1])!);
                    data = sqLite.fetchData(offset: 0);
                }
            }
            self.sendMsgToWV(msg: self.MegCombination(kind: "sqlite_setup", data: data));
            break;
        
            
        //----- background_processing -----
        case "background_processing":
            if(wvData.data == "execution"){
                let semaphore = DispatchSemaphore(value: 1)
                let queue = DispatchQueue.global()
                for i in 0..<10000 {
                    queue.async {
                        if semaphore.wait(timeout: .distantFuture) == .success {
                            print(i);
                            semaphore.signal()
                        }
                    }
                }
                
                DispatchQueue.global().async {
                    for i in 1...100 {
                        //建立信號
                        //let semaphore = DispatchSemaphore(value: 0);
                        if i == 3 {
                            
                        } else {
                            //產生放行信號
                            //semaphore.signal();
                        }
                        
                        //等待信號
                        //_ = semaphore.wait(timeout: DispatchTime.distantFuture);
                        
                        DispatchQueue.main.async(execute: {
                            self.sendMsgToWV(msg: self.MegCombination(kind: wvData.kind, data: "\"\(i)%\""));
                        })
                        print(i);
                        sleep(1);
                    }
                }
            }
            break;
            
        //----- default -----
        default:
            break;
        }
        
    }
    
    private func MegCombination(kind:String, data: String) -> String {
        return "callJS('{\"kind\":\"\(kind)\",\"data\":\(data)}')";
    }
    
    private func sendMsgToWV(msg: String) -> Void {
        print("send Msg: \(msg)")
        self.webView.evaluateJavaScript(msg) {(result, err) in}
    }
    
    public func runTimer(sec: Double, Action: @escaping () -> Void) -> Void {
        timer = Timer.scheduledTimer(withTimeInterval: sec, repeats: true) { (timer) in
            Action();
        }
    }
    
    
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet);

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }));

        self.present(alertController, animated: true, completion: nil);
        
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
}


extension ViewController: WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit");
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.leftBarButtonItem?.isEnabled = webView.canGoBack;
        
        let viewName: String = webView.url!.lastPathComponent;
        print("webview finish: \(viewName)");
                
        if(viewName == "index.html"){
    
            if(previewLayer != nil){
                avCaptureSession.stopRunning();
                previewLayer.isHidden = true;
                previewLayer = nil;
            }
            
        }else if(viewName == "check_network.html"){
            let wvData: WebViewData = WebViewData(kind: "check_network", data: "");
            defineWVData(wvData: wvData);
        }
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url;
        let requestUrl: String = (url?.absoluteString.removingPercentEncoding!)!;
        //print(requestUrl);
        
        guard url != nil else {
            decisionHandler(.allow)
            return
        }
        
        if url!.description.lowercased().starts(with: "http://") ||
            url!.description.lowercased().starts(with: "https://")  {
            decisionHandler(.cancel);
            UIApplication.shared.open(url!, options: [:], completionHandler: nil);
        } else {
            decisionHandler(.allow)
        }
                
        let string = requestUrl.replacingOccurrences(of: "json:", with: "");
        let data = string.data(using: .utf8)!;
        let decoder = JSONDecoder();
        if let wvData = try? decoder.decode(WebViewData.self, from: data) {
            defineWVData(wvData: wvData);
        }
        
        if let del = try? decoder.decode(SqlDelete.self, from: data){
            defineWVData(wvData: WebViewData.init(kind: del.kind, data: "delete:\(del.data.delete)"))
        }
        
        if let brightness = try? decoder.decode(Brightness.self, from: data) {
            
            let brightnessNum = CGFloat(Double(brightness.brightness) / 100.0);
            UIScreen.main.brightness = brightnessNum;
        }
    }
}


extension ViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first{
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {return;}
            guard let qrCodeValue = readableObject.stringValue else {return;}
            self.sendMsgToWV(msg: self.MegCombination(kind: "scan_qrcode", data: "\"" + qrCodeValue + "\""));
        }
    }
    
    private func startQRCodeScan(){
        avCaptureSession = qrCodeModel.createAVCaptureSession()!;
        
        let metaDataOutput = AVCaptureMetadataOutput()
        if (avCaptureSession.canAddOutput(metaDataOutput) ){
            avCaptureSession.addOutput(metaDataOutput);
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main);
            metaDataOutput.metadataObjectTypes = [.qr, .ean8 , .ean13 , .pdf417];
        }else{
            return
        }
        let selfViewWidth = self.view.frame.width;
        let selfViewHeight = self.view.frame.height;
        previewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession);
        previewLayer.videoGravity = .resizeAspectFill;
        previewLayer.frame = CGRect.init(x: 0, y: selfViewHeight/2 - selfViewWidth/2, width: selfViewWidth, height: selfViewWidth);
        view.layer.addSublayer(previewLayer);
        avCaptureSession.startRunning();
    }
}

