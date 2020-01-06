//  RWVideoNinja
//
//  Created by Aleksey Shapoval on 1/6/20.
//  Copyright © 2020 VoVa LLC. All rights reserved.

import UIKit
import AVKit
import MobileCoreServices

class PlayVideoViewController: UIViewController {
  
  @IBAction func playVideo(_ sender: AnyObject) {
     VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    //1
    guard
      let mediaType = info[UIImagePickerControllerMediaType] as? String,
      mediaType == (kUTTypeMovie as? String),
      let url = info[UIImagePickerControllerMediaURL] as? URL
      
      else {
        print("Failed to load mediaType & URL")
        return
      }
    
      print("Successfully loaded mediaType & url")
    //2
    dismiss(animated: true) {
      //3
      let player = AVPlayer(url: url)
      let vcPlayer = AVPlayerViewController()
      vcPlayer.player = player
      self.present(vcPlayer, animated: true, completion: nil)
    }
  }
  
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
}
