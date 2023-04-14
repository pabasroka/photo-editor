//
//  ViewController.swift
//  testiphone5s
//
//  Created by RMS on 10/03/2023.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraPreview: UIImageView!
    @IBOutlet weak var BlackWhiteFilter: UIButton!
    @IBOutlet weak var GalleryButton: UIButton!
    
    @IBOutlet weak var FIltersSection: UIView!
    @IBOutlet weak var SavePhoto: UIButton!
    @IBOutlet weak var ClearFilters: UIButton!
    @IBOutlet weak var SharePhoto: UIButton!
    @IBOutlet weak var ThermalFilter: UIButton!
    @IBOutlet weak var PosterizeFilter: UIButton!
    var originalPhoto: UIImage!
    
    @IBOutlet weak var Sepiafilter: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        FIltersSection.isHidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func tappedCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated:  true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraPreview.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        originalPhoto = cameraPreview.image
        picker.dismiss(animated: true, completion: nil)
        FIltersSection.isHidden = false
    }
    
    @IBAction func galleryButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func previewBlackWhite(_ sender: Any) {
        clearFilters()
        cameraPreview.image = convertToGrayScale(image:  cameraPreview.image!)
    }
    
    @IBAction func previewSepia(_ sender: Any) {
        clearFilters()
        cameraPreview.image = convertToSepia(image: cameraPreview.image!)
    }
    
    @IBAction func previewThermal(_ sender: Any) {
        clearFilters()
        cameraPreview.image = convertToThermal(image: cameraPreview.image!)
    }
    
    @IBAction func previewPosterize(_ sender: Any) {
        clearFilters()
        cameraPreview.image = convertToPosterize(image: cameraPreview.image!)
    }
    
    @IBAction func clearFilters() {
        cameraPreview.image = originalPhoto
    }
    
    @IBAction func savePhoto() {
        if cameraPreview.image != nil {
            UIImageWriteToSavedPhotosAlbum(cameraPreview.image!, nil, nil, nil)
            self.showToast(message: "Photo saved successfully", font: .systemFont(ofSize: 12.0))
        } else {
            self.showToast(message: "Take a photo or use gallery", font: .systemFont(ofSize: 12.0))
        }
    }
    
    @IBAction func sharePhoto() {
        let activityVC = UIActivityViewController(activityItems: [cameraPreview.image!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = cameraPreview
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }
    
    func convertToSepia(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        
        let originalCIImage = CIImage(image: image)
        if originalCIImage != nil {
            if let sepiaCIImage = sepiaFilter(originalCIImage!, intensity: 0.9) {
                let cgimg = context.createCGImage(sepiaCIImage, from: sepiaCIImage.extent)
                return UIImage(cgImage: cgimg!)
            }
            return image
        }
        return image
    }
    
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
        {
            let sepiaFilter = CIFilter(name:"CISepiaTone")
            sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
            sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
            return sepiaFilter?.outputImage
        }
    
    func convertToThermal(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        
        let originalCIImage = CIImage(image: image)
        if originalCIImage != nil {
            if let thermalImage = thermalFilter(originalCIImage!, intensity: 0.9) {
                let cgimg = context.createCGImage(thermalImage, from: thermalImage.extent)
                return UIImage(cgImage: cgimg!)
            }
            return image
        }
        return image
    }
    
    func thermalFilter(_ input: CIImage, intensity: Double) -> CIImage?
        {
            let sepiaFilter = CIFilter(name:"CIColorInvert")
            sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
            return sepiaFilter?.outputImage
        }
    
    func convertToPosterize(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        
        let originalCIImage = CIImage(image: image)
        if originalCIImage != nil {
            if let posterizeCIImage = posterizeFilter(originalCIImage!, intensity: 0.9) {
                let cgimg = context.createCGImage(posterizeCIImage, from: posterizeCIImage.extent)
                return UIImage(cgImage: cgimg!)
            }
            return image
        }
        return image
    }
    
    func posterizeFilter(_ input: CIImage, intensity: Double) -> CIImage?
        {
            let posterizeFilter = CIFilter(name:"CIColorPosterize")
            posterizeFilter?.setValue(input, forKey: kCIInputImageKey)
            return posterizeFilter?.outputImage
        }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 200, y: self.view.frame.size.height/2, width: 400, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

