//
//  ZoomImageVC.swift
//  ARABAH
//
//  Created by cqlsys on 14/04/25.
//

import UIKit

class ZoomImageVC: UIViewController, UIScrollViewDelegate {
    var imageUrl: String = ""
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        img.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
            
        }
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 6.0
        // scrollView.delegate = self - it is set on the storyboard.
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return img
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
