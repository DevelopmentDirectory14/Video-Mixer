//  RWVideoNinja
//
//  Created by Aleksey Shapoval on 1/6/20.
//  Copyright © 2020 VoVa LLC. All rights reserved.

import UIKit
import MobileCoreServices
import MediaPlayer
import Photos

class MergeVideoViewController: UIViewController {
  var firstAsset: AVAsset?
  var secondAsset: AVAsset?
  var audioAsset: AVAsset?
  var loadingAssetOne = false
  
  @IBOutlet var activityMonitor: UIActivityIndicatorView!
  
  func savedPhotosAvailable() -> Bool {
    guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }
    
    let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
    return false
  }
  
  @IBAction func loadAssetOne(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = true
      VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
  }
  
  @IBAction func loadAssetTwo(_ sender: AnyObject) {
    if savedPhotosAvailable() {
      loadingAssetOne = false
      VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
  }
  
  @IBAction func loadAudio(_ sender: AnyObject) {
    
  }
    
  @IBAction func merge(_ sender: AnyObject) {
    
  }
  
}

extension MergeVideoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true, completion: nil)
    
    guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
      mediaType == (kUTTypeMovie as String),
      let url = info[UIImagePickerControllerMediaURL] as? URL
      else { return }
    
    let avAsset = AVAsset(url: url)
    var message = ""
    if loadingAssetOne {
      message = "Video one loaded"
      firstAsset = avAsset
    } else {
      message = "Video two loaded"
      secondAsset = avAsset
    }
    let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
}

extension MergeVideoViewController: UINavigationControllerDelegate {
  
}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {
  
}