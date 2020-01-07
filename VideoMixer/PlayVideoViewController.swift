//  VideoMixer
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
  
  func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    //1
    guard
      let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String,
      mediaType == (kUTTypeMovie as? String),
      let url = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
      
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
