//
//  VideoDetailsViewController.swift
//  LambdaTimeline
//
//  Created by Samantha Gatt on 10/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoDetailsViewController: UIViewController, PostControllerViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        playVideo()
    }
    
    var postController: PostController!
    var videoURL: URL?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var videoView: UIView!
    
    @IBAction func post(_ sender: Any) {
        view.endEditing(true)
        
        guard let videoURL = videoURL,
            let videoData = try? Data(contentsOf: videoURL),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        let ratio = videoView.bounds.height / videoView.bounds.width
        postController.createPost(with: title, ofType: .video, mediaData: videoData, ratio: ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowMainCollectionView", sender: nil)
            }
        }
    }
    
    
    private func playVideo() {
        guard isViewLoaded else { NSLog("playVideo called before view was loaded"); return }
        guard let videoURL = videoURL else { NSLog("No videoURL passed from camera view controller"); return }
        let player = AVPlayer(url: URL(fileURLWithPath: videoURL.path))
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
