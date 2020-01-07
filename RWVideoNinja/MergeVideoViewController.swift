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
  
    func exportDidFinish(_ session: AVAssetExportSession) {
      //Cleanup assets
      activityMonitor.stopAnimating()
      firstAsset = nil
      secondAsset = nil
      audioAsset = nil
      
      guard
          session.status == AVAssetExportSessionStatus.completed,
          let outputURL = session.outputURL
          else { return }
      
      let saveVideoToPhotos =  {
          PHPhotoLibrary.shared().performChanges({
              PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: outputURL)
          }) { saved, error in
              let success = saved && (error == nil)
              let title = success ? "Success" : "Error"
              let message = success ? "Video saved" : "Failed to save video"
              
            DispatchQueue.main.async {
              let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
              self.present(alert, animated: true, completion: nil)
            }
          }
      }
      
      //Ensure permission to access photo library
      if PHPhotoLibrary.authorizationStatus() != .authorized {
          PHPhotoLibrary.requestAuthorization({ status in
              if status == .authorized {
                  saveVideoToPhotos()
              }
          })
      } else {
          saveVideoToPhotos()
      }
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
    let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
    mediaPickerController.delegate = self
    mediaPickerController.prompt = "Select Audio"
    present(mediaPickerController, animated: true, completion: nil)
  }
    
  @IBAction func merge(_ sender: AnyObject) {
    guard
        let firstAsset = firstAsset,
        let secondAsset = secondAsset
        else { return }
    
    activityMonitor.startAnimating()
    
    //1 - Create AVMutableComposition object.  This object will hold your AVMutableCompositionTrack instances.
    let mixComposition = AVMutableComposition()
    
    //2 - Create two video tracks.
    guard
        let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID:
    Int32(kCMPersistentTrackID_Invalid))
        else { return }
    
    do {
        try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                        of: firstAsset.tracks(withMediaType:
                                            .video)[0],
                                        at: kCMTimeZero)
    } catch {
        print("Failed to load first track")
        return
    }
    
    guard
        let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID:
    Int32(kCMPersistentTrackID_Invalid))
        else { return }
    
    do {
        try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                        of: secondAsset.tracks(withMediaType:
                                            .video)[0],
                                        at: firstAsset.duration)
    } catch {
        print("Failed to load second track")
        return
    }
    
    // 3 - Audio track
    if let loadedAudioAsset = audioAsset {
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
        do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                            of: loadedAudioAsset.tracks(withMediaType: .audio)[0],
                                            at: kCMTimeZero)
        } catch {
            print("Failed to load Audio track")
        }
    }
    
    // 4 - Get Path
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    let date = dateFormatter.string(from: Date())
    let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
    
    // 5 - Create Exporter
    guard let exporter = AVAssetExportSession(asset: mixComposition, presetName:
        AVAssetExportPresetHighestQuality) else { return }
    
    exporter.outputURL = url
    exporter.outputFileType = AVFileType.mov
    exporter.shouldOptimizeForNetworkUse = true
    
    // 6 - Perform the Export
    exporter.exportAsynchronously() {
        DispatchQueue.main.async {
            self.exportDidFinish(exporter)
        }
    }
    
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
  func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
    dismiss(animated: true) {
      let selectedSongs = mediaItemCollection.items
      guard let song = selectedSongs.first else { return }
      
      let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
      self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
      let title = (url == nil) ? "Asset Not Available" : "Asset loaded"
      let message = (url == nil) ? "Audio Not Available" : "Audio loaded"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
    dismiss(animated: true, completion: nil)
  }
}
