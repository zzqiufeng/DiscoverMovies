//
//  AddReviewViewController.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-23.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController {

    
    @IBOutlet var rateStars: [UIButton]!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var userReview: UITextView!
    @IBOutlet weak var userPhoto: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var callCamera: UIBarButtonItem!
    
    var reviewId = 0
    var oneReview = Review(reviewId: 0, starRate: 0, title: "", review: "", photo: nil)
    var userRate = [RateStar(rate:1,set:false),RateStar(rate:5,set:false),RateStar(rate:5,set:false),RateStar(rate:5,set:false),RateStar(rate:5,set:false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("process review of \(reviewId)")
        self.navigationItem.title = "Review"
        view.backgroundColor = BACKGROUND_COLOR
        //
        userReview.delegate = self
        userReview.text = "Please input your review."
        userReview.backgroundColor = .white
        userReview.textColor = .lightGray
        //
        oneReview.reviewId = reviewId
        //
        setRateStar()
        titleLabel.delegate = self
        titleLabel.keyboardType = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if ReviewMovies.shared.isReviewExisted(forId: oneReview.reviewId) {
            ReviewMovies.shared.updateReview(review: oneReview)
        } else {
            ReviewMovies.shared.addReview(review: oneReview)
        }
        print(ReviewMovies.shared.reviews)
    }
    
    func setRateStar(){
        if ReviewMovies.shared.isReviewExisted(forId: reviewId) {
            let currentReview = ReviewMovies.shared.getReview(withId: reviewId)
            
            if currentReview != nil {
                print("this movie you rated it as \(currentReview!.starRate )")
                if currentReview!.starRate != 0 {
                    for index in 0...(currentReview!.starRate - 1) {
                        rateStars[index].setImage(UIImage.init(named: "starYellow.png"), for: .normal)
                        userRate[index].set = true
                    }
                }
                oneReview.reviewId = currentReview!.reviewId
                oneReview.starRate = currentReview!.starRate
                oneReview.title = currentReview!.title
                oneReview.review = currentReview!.review
                if currentReview!.photo != nil {
                    oneReview.photo = currentReview!.photo
                    userImage.image = oneReview.photo
                } else {
                    print("no user photo")
                    userImage.image = UIImage(named: "seeMovie.png")
                    print("set user photo to seeMovie")
                }
                userReview.text = oneReview.review                
                titleLabel.text = oneReview.title
                userReview.textColor = .black
                userPhoto.setImage(oneReview.photo, for: .normal)
            }
                     
        }
    }
    
    
    @IBAction func giveRate(_ sender: UIButton) {
        print(sender.tag)
        if userRate[sender.tag - 1].set {
            for index in (sender.tag - 1)...4 {
               rateStars[index].setImage(UIImage.init(named: "starWhite.png"), for: .normal)
                userRate[index].set = false
            }
            oneReview.starRate = sender.tag - 1
        } else {
            for index in 0...(sender.tag - 1) {
                rateStars[index].setImage(UIImage.init(named: "starYellow.png"), for: .normal)
                userRate[index].set = true
            }
            oneReview.starRate = sender.tag
        }
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Please select source", message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.camera()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.photoLibrary()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.barButtonItem = self.callCamera
            
            self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto__try(_ sender: Any) {
         // Create the action buttons for the alert.
         let defaultAction = UIAlertAction(title: "Agree",
                              style: .default) { (action) in
          // Respond to user selection of the action.
         }
         let cancelAction = UIAlertAction(title: "Disagree",
                              style: .cancel) { (action) in
          // Respond to user selection of the action.
         }
         
         // Create and configure the alert controller.
         let alert = UIAlertController(title: "Terms and Conditions",
               message: "Click Agree to accept the terms and conditions.",
               preferredStyle: .alert)
         alert.addAction(defaultAction)
         alert.addAction(cancelAction)
              
         self.present(alert, animated: true) {
            // The alert was presented
         }
    }
    
    func takePhoto(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    

}

extension AddReviewViewController:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please input your review."
            textView.textColor = UIColor.lightGray
        } else {
            oneReview.review = textView.text
            print(oneReview)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}

extension AddReviewViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func photoLibrary()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }

    func camera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
        userImage.image = image
        oneReview.photo = image
    }
    
}

extension AddReviewViewController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil {
            oneReview.title = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
