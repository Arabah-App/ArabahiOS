//
//  ScannerVC.swift
//  ARABAH
//
//  Created by cqlios on 29/10/24.
//

import UIKit
import MercariQRScanner
import AVFoundation

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var scannerView: UIView!
    
    //MARK: - VARIABLES
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarcodeScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                       self.captureSession.startRunning()
                   }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScaner(_ sender: UIButton) {
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    //MARK: - FUNCTION
    func setupBarcodeScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert(message: "Your device does not support camera.")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert(message: "Failed to load camera.")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showAlert(message: "Failed to add camera input.")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,       // For 8-digit EAN barcodes
                .ean13,      // For 13-digit EAN barcodes
                .code128     // For CODE-128 barcodes
            ]
        } else {
            showAlert(message: "Failed to add metadata output.")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        
        if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let barcode = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession.stopRunning()
            
            
             let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
            vc.qrCode = barcode
             self.navigationController?.pushViewController(vc, animated: true)
                
            print("Barcode value: \(barcode)")
          //  showAlert(message: "Scanned: \(barcode)")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            DispatchQueue.global(qos: .background).async {
                       self.captureSession.startRunning()
                   }
        })
        present(alert, animated: true)
    }
}
    
//class ScannerVC: UIViewController {
//    //MARK: - OUTLETS
//    @IBOutlet weak var scannerView: QRScannerView!
//    //MARK: - VARIABELS
//    //MARK: - VIEW LIFECYCLE
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupQRScanner()
//        scannerView.contentMode = .scaleAspectFill
//        scannerView.frame = view.bounds
//    }
//    //MARK: - ACTIONS
//    @IBAction func btnBack(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    @IBAction func btnScaner(_ sender: UIButton) {
//        
//    }
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        scannerView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
//    }
//    
//    //MARK: - FUNCTION
//    func setupQRScanner() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            setupQRScannerView()
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                if granted {
//                    DispatchQueue.main.async { [weak self] in
//                        self?.setupQRScannerView()
//                    }
//                }
//            }
//        default:
//            showAlert()
//        }
//    }
//    
//    func setupQRScannerView() {
//        scannerView.focusImagePadding = 8.0
//        scannerView.animationDuration = 5
//        scannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: false))
//        scannerView.startRunning()
//    }
//    
//    func showAlert() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
//            alert.addAction(.init(title: "OK", style: .default))
//            self?.present(alert, animated: true)
//        }
//    }
//}

extension ScannerVC: QRScannerViewDelegate {
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print("QR Scanner Error: \(error)")
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
            if let data = code.data(using: .utf8) {
                do {
                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let productId = jsonDict["productId"] as? String{
                        let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
                        vc.prodcutid = productId
                        self.navigationController?.pushViewController(vc, animated: true)
                        print("Extracted product ID: \(productId)")
                    } else {
                        print("Failed to parse JSON")
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        print("results-",code)
    }
}
