//
//  ViewController.swift
//  simpleInstagram
//
//  Created by shubham Garg on 28/07/20.
//  Copyright © 2020 shubham Garg. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var medias:[MediaModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func uploadBtnAxn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.openCamera(onlyPhoto: false)
        })
        let saveAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.openGallary(onlyPhoto: false)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
            popoverController.sourceView = self.view
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK:- Image Picker Method
    //Open gallery on Gallery button
    func openGallary(onlyPhoto: Bool)
    {
        var imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        if onlyPhoto{
            imagePicker.mediaTypes = [(kUTTypeImage as String)];

        }
        else{
            imagePicker.mediaTypes = [(kUTTypeImage as String), (kUTTypeMovie as String)];
        }
        imagePicker.videoQuality = .typeMedium
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Open Camera on camera button
    func openCamera(onlyPhoto: Bool)
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            if onlyPhoto{
                imagePicker.cameraCaptureMode = .photo
                imagePicker.mediaTypes = [(kUTTypeImage as String)];
            
            }
            else{
                imagePicker.mediaTypes = [(kUTTypeImage as String), (kUTTypeMovie as String)];
            }
            imagePicker.videoQuality = .typeMedium
            present(imagePicker, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContentTableViewCell.self), for: indexPath) as!  ContentTableViewCell
        let media = medias[indexPath.row]
        cell.captionLbl.text = media.caption
        if media.type == MediaType.Image{
            cell.playPauseBtn.isHidden = true
            cell.playerView.isHidden =  true
            cell.contentimageView.image = media.image
        }
        else{
            cell.playPauseBtn.isHidden = false
            cell.playerView.isHidden =  false
            if let url = media.dataurl{
                cell.contentimageView.image = thumbnailImageFor(fileUrl: url)
            }
            cell.playPauseBtn.tag = indexPath.row
            cell.playPauseBtn.addTarget(self, action: #selector(self.playAndPauseVideo), for: .touchUpInside)
        }
        return cell
    }
    
    
    @objc func playAndPauseVideo(sender:UIButton){
        let videoURL = medias[sender.tag].dataurl
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    
    func thumbnailImageFor(fileUrl:URL) -> UIImage? {

        let video = AVURLAsset(url: fileUrl, options: [:])
        let assetImgGenerate = AVAssetImageGenerator(asset: video)
        assetImgGenerate.appliesPreferredTrackTransform = true

        let videoDuration:CMTime = video.duration
        let durationInSeconds:Float64 = CMTimeGetSeconds(videoDuration)

        let numerator = Int64(1)
        let denominator = videoDuration.timescale
        let time = CMTimeMake(value: numerator, timescale: denominator)

        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error)
            return nil
        }
    }
    
    
}

extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
       }
    
     public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // This is a video
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                print("\(info)")
                let data: Data? = try? Data(contentsOf: mediaURL)
                
                print(String(format: "File size is : %.2f MB", Float(data?.count ?? 0) / 1024.0 / 1024.0))
                
                let mbData = Float(data?.count ?? 0) / 1024.0 / 1024.0
                
                dismiss(animated: true)
                
                if mbData > 100.00 {
                    let alert  = UIAlertController(title: nil, message: "Video size shoud not greater than 100 mb !", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let timestamp = Date().timeIntervalSince1970
                    let media = MediaModel(caption: "Video \(mbData) \(timestamp)", image: nil, dataurl: mediaURL, type: .Video)
                    self.medias.append(media)
                }
               
            }
//            else if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL{
//              let timestamp = Date().timeIntervalSince1970
//                let media = MediaModel(caption: "Image \(timestamp)", image: UIImage(contentsOfFile: imageURL.absoluteString), dataurl: nil, type: .Image)
//              self.medias.append(media)
//            }
            else if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
              let timestamp = Date().timeIntervalSince1970
                let media = MediaModel(caption: "Image  \(timestamp)", image: image, dataurl: nil, type: .Image)
              self.medias.append(media)
            }
        else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
          let timestamp = Date().timeIntervalSince1970
            let media = MediaModel(caption: "Image  \(timestamp)", image: image, dataurl: nil, type: .Image)
          self.medias.append(media)
        }
         dismiss(animated: true, completion: nil)
        self.tableview.reloadData()
    }
}


enum MediaType{
    case Image
    case Video
}


struct MediaModel{
    var caption:String?
    var image: UIImage?
    var dataurl: URL?
    var type: MediaType?
}
