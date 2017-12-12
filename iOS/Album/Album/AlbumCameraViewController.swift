//
//  AlbumCameraViewController.swift
//  Album
//
//  Created by Michael Hartung on 3/19/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AlbumCameraViewController : UIViewController, AVCapturePhotoCaptureDelegate {
	@IBOutlet weak var cameraView: UIView!
	var captureSession = AVCaptureSession()
	var sessionOutput = AVCapturePhotoOutput()
	var previewLayer = AVCaptureVideoPreviewLayer()
	var defaultAlbum : String?
	var ref: FIRDatabaseReference!
	var storage: FIRStorageReference!
	var device : AVCaptureDevice?
	var pinchScale : CGFloat = 1
	var flashView : UIView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftAction))
		swipeLeft.direction = UISwipeGestureRecognizerDirection.left
		self.view.addGestureRecognizer(swipeLeft)
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.ref = FIRDatabase.database().reference()
		self.storage = FIRStorage.storage().reference()
		
		if let user = FIRAuth.auth()?.currentUser {
			let userid = user.uid
			self.ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
				let userValue = snapshot.value as? NSDictionary
				self.defaultAlbum = userValue?["defaultAlbum"] as? String
				if self.defaultAlbum == nil {
					_ = SimpleUIAlert(title: "Default Album Not Set", message: "Please set your default album by swiping right on an album.", sender: self)
					self.performSegue(withIdentifier: "toDashboard", sender: self)
				} else {
					self.navigationItem.title = self.defaultAlbum!
				}
			}, withCancel: { (error) in
				print(error.localizedDescription)
			})
		}
		setupCamera(position: AVCaptureDevicePosition.back)
	}
	
	func swipeLeftAction(_ gesture: UIGestureRecognizer) {
		self.performSegue(withIdentifier: "toDashboard", sender: self)
	}
	
	func setupCamera(position: AVCaptureDevicePosition) {
		do {
			self.device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: position)
			let input = try AVCaptureDeviceInput(device: self.device)
			
			for i in captureSession.inputs {
				captureSession.removeInput(i as! AVCaptureDeviceInput)
			}
			
			if captureSession.canAddInput(input) {
				captureSession.stopRunning()
				captureSession.addInput(input)
				cameraView.layer.sublayers = nil
				
				for i in captureSession.outputs {
					captureSession.removeOutput(i as! AVCapturePhotoOutput)
				}
				
				if captureSession.canAddOutput(sessionOutput) {
					captureSession.addOutput(sessionOutput)
					captureSession.startRunning()
					previewLayer.session = captureSession
					previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
					cameraView.layer.addSublayer(previewLayer)
					previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
					previewLayer.bounds = cameraView.frame
					if self.device?.position == AVCaptureDevicePosition.back {
						let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedCameraPreview))
						cameraView.addGestureRecognizer(pinchGesture)
					}
				}
				
				flashView = UIView(frame: cameraView.frame)
				flashView.alpha = 0
				flashView.backgroundColor = UIColor.black
				cameraView.addSubview(flashView)
			}
		} catch {
			print("Error initializing camera")
		}
	}
	
	@IBAction func takePhoto(_ sender: Any) {
		if (sessionOutput.connection(withMediaType: AVMediaTypeVideo)) != nil {
			let photoSettings = AVCapturePhotoSettings()
			photoSettings.isAutoStillImageStabilizationEnabled = true
			photoSettings.isHighResolutionPhotoEnabled = true
			photoSettings.flashMode = .auto
			self.flashView.alpha = 1
			
			UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { () -> Void in
				self.flashView.alpha = 0
			}, completion: nil)
			
			sessionOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
		}
	}
	
	func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)
	{
		
		if let error = error {
			print(error.localizedDescription)
		}
		
		if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
			if let image = UIImage(data: dataImage) {
				saveImage(image: image)
			} else {
				_ = SimpleUIAlert(title: "Error Capturing Image", message: "An error occurred while trying to capture image.", sender: self)
			}
		}
	}
	
	func saveImage(image: UIImage) {
		if self.defaultAlbum != nil {
			let imageName = "\(arc4random()).jpg"
			let imageRef = storage.child("\(self.defaultAlbum!)/\(imageName)")
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			if let user = FIRAuth.auth()?.currentUser {
				if metadata.customMetadata == nil {
					metadata.customMetadata = Dictionary<String, String>()
				}
				metadata.customMetadata?["User"] = user.uid
			}
			_ = imageRef.put(UIImageJPEGRepresentation(image, 1)!, metadata: metadata) { (metadata, error) in
				if error != nil {
					_  = SimpleUIAlert(title: "Issue saving Photo", message: "Photo not saved, possible network issue", sender: self)
					return
				}
				
				let downloadURL = metadata?.downloadURL()?.absoluteString
				self.ref.child("albums").child(self.defaultAlbum!).observeSingleEvent(of: .value, with: { (snapshot) in
					let albumValue = snapshot.value as? NSDictionary
					
					var photosArray = albumValue?["photos"] as? NSArray
					if photosArray == nil {
						photosArray = NSArray()
					}
					self.ref.child("albums").child(self.defaultAlbum!).child("photos").setValue(photosArray?.adding(downloadURL!))
					
					let numPhotos : Int = albumValue?["numPhotos"] as! Int
					self.ref.child("albums").child(self.defaultAlbum!).child("numPhotos").setValue(numPhotos + 1)
				}, withCancel: { (error) in
					print(error)
					_ = SimpleUIAlert(title: "Error occurred", message: "An error occurred connnecting to the database, please contact app support", sender: self)
				})
			}
		} else {
			_ = SimpleUIAlert(title: "Default Album not set", message: "Please set your default album", sender: self)
		}
	}
	
	// Focus Camera
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.device?.position == AVCaptureDevicePosition.back {
			let screenSize = cameraView.bounds.size
			if let touchPoint = touches.first {
				let x = touchPoint.location(in: cameraView).y / screenSize.height
				let y = 1.0 - touchPoint.location(in: cameraView).x / screenSize.width
				let focusPoint = CGPoint(x: x, y: y)
				
				if let device = self.device {
					do {
						try device.lockForConfiguration()
						
						device.focusPointOfInterest = focusPoint
						device.focusMode = .autoFocus
						device.exposurePointOfInterest = focusPoint
						device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
						device.unlockForConfiguration()
					}
					catch {
						// just ignore
					}
				}
			}
		}
	}
	
	// Pinch to zoom
	func pinchedCameraPreview(gesture: UIPinchGestureRecognizer) {
		
		if let device = self.device {
			do {
				try device.lockForConfiguration()
			
				switch gesture.state {
					case .began:
						self.pinchScale = device.videoZoomFactor
					case .changed:
						var factor = self.pinchScale * gesture.scale
						factor = max(1, min(factor, device.activeFormat.videoMaxZoomFactor))
						device.videoZoomFactor = factor
					case .failed, .ended:
						break
					default:
						break
				}
				
				device.unlockForConfiguration()
			}
			catch {
				print("Error when attempting to zoom.")
			}
		}
	}
	
	//  Camera switch
	@IBAction func cameraSwitch(_ sender: Any) {
		if let device = self.device {
			let position = device.position
			if position == AVCaptureDevicePosition.back {
				setupCamera(position: AVCaptureDevicePosition.front)
			} else {
				setupCamera(position: AVCaptureDevicePosition.back)
			}
		}
	}
}
