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
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
}
