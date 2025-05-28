import Foundation
import UIKit
import PhotosUI

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    var picker = UIImagePickerController()
    var alert = UIAlertController(title: "Choose Video", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback: ((UIImage) -> ())?
    var pickMultipleImageCallback: (([UIImage]) -> ())?
    var pickVideoCallback: ((Bool, URL?, UIImage?) -> ())?
    var isPickVideoImage = false
    static let shared = ImagePickerManager()

    // Array to keep track of multiple images from camera
    var pickedImages: [UIImage] = []

    override init() {
        super.init()
    }

    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback
        self.viewController = viewController
        alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.viewController!.view
        }
        viewController.present(alert, animated: true, completion: nil)
    }

    func pickImageMultiple(_ viewController: UIViewController, _ callback: @escaping (([UIImage]) -> ())) {
        pickMultipleImageCallback = callback
        self.viewController = viewController
        alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { UIAlertAction in
            self.openPHPicker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.viewController!.view
        }
        viewController.present(alert, animated: true, completion: nil)
    }

    func pickVideo(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        self.viewController = viewController
        alert = UIAlertController(title: "Choose Video", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.viewController!.view
        }
        viewController.present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.picker.sourceType = .camera
                self.viewController!.present(self.picker, animated: true, completion: nil)
            } else {
                print("You don't have a camera")
            }
        }
    }

    func openGallery() {
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true, completion: nil)
            self.picker.sourceType = .photoLibrary
            self.viewController!.present(self.picker, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            pickedImages.append(image)
            pickImageCallback?(image)
        }

        // Dismiss the picker and call the callback with the images array
        viewController?.dismiss(animated: true, completion: {
            self.pickMultipleImageCallback?(self.pickedImages)
           // self.pickedImages.removeAll() // Clear the array after callback
        })
    }

    func openPHPicker() {
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
                phPickerConfig.selectionLimit = 9
                phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
                let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
                phPickerVC.delegate = self
                self.viewController?.present(phPickerVC, animated: true, completion: nil)
            }
        }
    }

    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard !results.isEmpty else { return }

        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let img = image as? UIImage {
                            images.append(img)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.pickMultipleImageCallback?(images)
        }
    }
}
