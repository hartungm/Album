//
//  AlbumDashboardViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/26/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//
//
//import Foundation
//import FirebaseAuth
//import FirebaseStorage
//import FirebaseDatabase
//import Nuke
//import Preheat
//
//class AlbumDashboardViewControllerOld : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, UITabBarDelegate {
//	
//	@IBOutlet weak var collectionView: UICollectionView!
//	var ref: FIRDatabaseReference!
//	var author : String?
//	var albumName : String? = nil
//	var photos : Array<URL> = Array()
//	var photoStrings : Array<String>?
//	var image : UIImage?
//	var imageName : String?
//	var index : Int?
//	var preheater: Preheater! = Nuke.Preheater()
//	var preheatController: Preheat.Controller<UICollectionView>!
//	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
////		self.getPhotos()
//	}
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		self.navigationItem.title = "\(albumName!)"
//		ref = FIRDatabase.database().reference()
//		self.collectionView.alwaysBounceVertical = true
//		let refresh = UIRefreshControl()
//		refresh.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
//		self.collectionView.addSubview(refresh)
//		
//		preheatController = Preheat.Controller(view: collectionView!)
//		preheatController?.handler = { [weak self] addedIndexPaths, removedIndexPaths in
//			self?.preheat(added: addedIndexPaths, removed: removedIndexPaths)
//		}
//	}
//	
//	func preheat(added: [IndexPath], removed: [IndexPath]) {
//		func requests(for indexPaths: [IndexPath]) -> [Request] {
//			return indexPaths.map { Request(url: photos[$0.row]) }
//		}
//		preheater.startPreheating(with: requests(for: added))
//		preheater.stopPreheating(with: requests(for: removed))
//	}
//	
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		preheatController?.enabled = true
////		getPhotos()
//	}
//	
//	override func viewDidDisappear(_ animated: Bool) {
//		super.viewDidDisappear(animated)
//		preheatController?.enabled = false
//	}
//	
//	func handleRefresh(refreshControl: UIRefreshControl) {
//		getPhotos()
//		refreshControl.endRefreshing()
//	}
//	
//	func getPhotos() {
//		self.ref.child("albums").child(albumName!).observeSingleEvent(of: .value, with: {(snapshot) in
//			let albumValue = snapshot.value as? NSDictionary
//			self.photoStrings = albumValue?["photos"] as? Array<String>
//			self.photoStrings?.reverse()
//			self.author = albumValue?["author"] as? String
////			if self.photos.count != self.photoStrings?.count {
//				self.photos = Array()
//				if let photoStrings = self.photoStrings {
//					for photo in photoStrings {
//						self.photos.append(URL(string: photo)!)
//					}
//					self.collectionView.reloadData()
//				}
////			}
//		})
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		return photos.count
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! AlbumCollectionViewCell
//		let photo = photos[indexPath.row]
//		let request = Request(url: photo)
//		Nuke.loadImage(with: request, into: cell.image)
//		return cell
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		let cell = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
//		self.image = cell.image.image
//		self.imageName = self.photoStrings?[indexPath.row]
//		self.index = indexPath.row
//		self.performSegue(withIdentifier: "viewImage", sender: self)
//	}
//	
//	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//		if(item.tag == 1) {
//			let upload = UploadViewController()
//			upload.albumName = self.albumName
//			upload.imageSourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
//			self.navigationController?.present(upload, animated: true, completion: nil)
//			self.getPhotos()
//		} else if(item.tag == 2) {
//			
//		}
//	}
//	
//	@IBAction func backToDashboard(_ sender: Any) {
//		self.navigationController?.popViewController(animated: true)
//	}
//	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if segue.identifier == "viewImage" {
//			let destination = segue.destination as! AlbumImagePageViewController
//			destination.image = image
//			destination.photos = self.photoStrings
//			destination.albumName = self.albumName
//			destination.photoName = self.imageName
//			destination.author = self.author
//			destination.index = self.index
//		}
//		if segue.identifier == "useCamera" {
//			let viewController : CameraViewController = segue.destination as! CameraViewController
//			viewController.albumName = self.albumName
//		}
//	}
//}
