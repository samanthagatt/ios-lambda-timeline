//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Samantha Gatt on 10/17/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoPostViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, PostControllerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    
    // MARK: - Properties
    
    var postController: PostController!
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    var videoURL: URL?
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordStopButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func toggleRecord(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    
    
    // MARK: - Private Functions
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }
    
    private func setUpCapture() {
        let captureSession = AVCaptureSession()
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(videoDeviceInput) else {
            fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func deleteRecording(atPathURL pathURL: URL) {
        let fm = FileManager.default
        
        guard fm.isDeletableFile(atPath: pathURL.path) else { NSLog("Error deleting fm file"); return }
        do {
            try fm.removeItem(at: pathURL)
            print("fm file has been deleted")
        } catch {
            NSLog("Error deleting fm file")
            return
        }
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        let recordButtonImageName = recordOutput.isRecording ? "stop" : "record"
        recordStopButton.setImage(UIImage(named: recordButtonImageName), for: .normal)
    }
    
    private func saveVideo(atFileURL url: URL) {
      
        // self.deleteRecording(atPathURL: url)
        
    }
    
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
            self.saveVideo(atFileURL: outputFileURL)
            
            self.videoURL = outputFileURL
            
            self.performSegue(withIdentifier: "ShowCreateVideoPostDetails", sender: nil)
        }
    }
    
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCreateVideoPostDetails" {
            let destVC = segue.destination as? VideoDetailsViewController
            destVC?.postController = postController
            destVC?.videoURL = videoURL
        }
    }
}
