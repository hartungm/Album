//
//  AlbumDashboardViewController.swift
//  Album
//
//  Created by Michael Hartung on 5/6/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import Nuke
import Preheat
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "imageCell"

class AlbumDashboardViewController: UICollectionViewController {
    
    var photos : Array<URL> = Array()
	var ref: FIRDatabaseReference!
    var albumName : String = ""
    var author : String = ""
	var reverse : Bool = false
    var selectedImageData : AlbumImageViewData = AlbumImageViewData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.ref = FIRDatabase.database().reference()
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		if albumName == "" {
			loadAlbumData()
		} else {
			self.navigationItem.title = self.albumName
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedImageData = AlbumImageViewData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToDashboard(_ sender: Any) {
        self.photos = Array()
        self.navigationController?.popViewController(animated: true)
    }
    
	@IBAction func uploadImage(_ sender: Any) {
		let upload = UploadViewController()
		upload.albumName = self.albumName
		upload.imageSourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
		self.navigationController?.present(upload, animated: true, completion: nil)
	}
	
	@IBAction func uploadImage2(_ sender: Any) {
		let upload = UploadViewController()
		upload.albumName = self.albumName
		upload.imageSourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
		self.navigationController?.present(upload, animated: true, completion: nil)
	}
	
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewImage" {
            let pageViewController = segue.destination as! AlbumImagePageViewController
            pageViewController.imageData = self.selectedImageData
            self.selectedImageData = AlbumImageViewData()
        }
        if segue.identifier == "useCamera" {
            let cameraController = segue.destination as! CameraViewController
            cameraController.albumName = self.albumName
        }
     }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCollectionViewCell
        let photo = photos[indexPath.row]
        let request = Request(url: photo)
        Nuke.loadImage(with: request, into: cell.image)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImageData.albumName = self.albumName
        self.selectedImageData.author = self.author
        self.selectedImageData.index = indexPath.item
        self.selectedImageData.photos = self.photos
        self.performSegue(withIdentifier: "viewImage", sender: self)
    }
	
	func loadAlbumData() {
		if let user = FIRAuth.auth()?.currentUser {
			let userid = user.uid
			self.ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
				let userValue = snapshot.value as? NSDictionary
				self.albumName = userValue?["defaultAlbum"] as? String ?? ""
				if self.albumName != "" {
					self.navigationController?.navigationBar.topItem?.title = self.albumName
					// Grab the album
					self.ref.child("albums").child(self.albumName).observeSingleEvent(of: .value, with: {(snapshot) in
						let albumValue = snapshot.value as? NSDictionary
						
						self.author = albumValue?["authorName"] as? String ?? ""
						
						if let photos = albumValue?["photos"] as? Array<String> {
							self.photos = Array()
							for photo in photos {
								self.photos.append(URL(string: photo)!)
							}
							self.collectionView?.reloadData()
						}
					})
				}
			}, withCancel: { (error) in
				print(error.localizedDescription)
			})
		}
	}
	
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
