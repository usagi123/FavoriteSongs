//
//  CreateSongViewController.swift
//  FavoriteSongs
//
//  Created by Mai Pham Quang Huy on 8/20/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment
 Author: Mai Pham Quang Huy
 ID: s3618861
 Created date: 08/20/18
 Acknowledgement:
 - Stack Overflow - https://stackoverflow.com
 - Apple Developer Documentation - https://developer.apple.com/documentation/
 - How to configure a UIScrollView with Auto Layout in Interface Builder - https://medium.com/@pradeep_chauhan/how-to-configure-a-uiscrollview-with-auto-layout-in-interface-builder-218dcb4022d7
 - Using Auto Layout in an UIScrollView - https://medium.com/@einancunlu/using-auto-layout-in-an-uiscrollview-44c9bba89ad6
 - ActionSheet Popover on iPad in Swift - https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
 - iPhone Apps 101 - Move the iPhone App View Up and Down Using the Size of the Keyboard (24/29) - https://youtu.be/iUQ1GfiVzS0
 - Using Auto Layout in an UIScrollView - https://youtu.be/6J22gHORk2I
 - Learn Swift: Scale Images Keep Aspect Ratio! - https://youtu.be/wXDkZqmXVBs
 - iOS Core Data with Swift 3 - https://youtu.be/da6W7wDh0Dw
 - USING CORE DATA IN SWIFT || CREATING A NOTES APP - https://youtu.be/c0Fdce_N1Tg
 */

import UIKit
import SafariServices

class CreateSongViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePickerController: UIImagePickerController!
    
    @IBOutlet var itemEntryTextView: UITextView?
    @IBOutlet weak var titleEntryTextView: UITextView!
    @IBOutlet weak var yearEntryTextView: UITextView!
    @IBOutlet weak var urlEntryTextView: UITextView!
    @IBOutlet weak var imageEntryImageView: UIImageView!
    
    @IBAction func chooseImageByTapping(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
                //realistically, I dont need to catch this since every apple mobile devices have rear camera
            } else {
                print("Error")
                let alertCamera = UIAlertController(title: "Error", message: "No rear camera detected on this device", preferredStyle: .alert)
                alertCamera.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertCamera, animated: true, completion: nil)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //For ipad action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageEntryImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveContact(_ sender: Any) {
        
        //If any fields are empty, app will reject and pop a alert for user to fill it or cancel creating new entry
        if (itemEntryTextView?.text.isEmpty)! || itemEntryTextView?.text == "Name" || (titleEntryTextView?.text.isEmpty)! || titleEntryTextView?.text == "Title" || (yearEntryTextView?.text.isEmpty)! || yearEntryTextView?.text == "Year" || (urlEntryTextView?.text.isEmpty)! || urlEntryTextView?.text == "URL" || imageEntryImageView.image == UIImage(named: "011429230786001.jpeg") {
            
//            print("No Data")
            let alert = UIAlertController(title: "Blank entry", message: "Please fully filled all details.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            
            self.present(alert, animated: true, completion: nil)
            
        } else if Double(yearEntryTextView.text) == nil {
            
//            print("Error, not number input")
            let alert = UIAlertController(title: "Wrong data type", message: "Please type number only", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Let data from the fields saved into Core Data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newEntry = Item(context: context)
            newEntry.name = itemEntryTextView?.text!
            newEntry.title = titleEntryTextView?.text!
            newEntry.year = yearEntryTextView?.text!
            yearEntryTextView.keyboardType = .numberPad
            newEntry.url = urlEntryTextView?.text!
            
            //Convert UIImage data to Binary data to save to Core Data
            let img = imageEntryImageView.image
            newEntry.image = UIImageJPEGRepresentation(img!, 1)! as Data
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func openURL(_ sender: Any) {
        
        //Adding http/https for url that missing it
        var urlString = urlEntryTextView.text
                if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
                } else {
                    urlString = "http://" + urlString!
                }
        let url: URL = URL(string: urlString!)!
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemEntryTextView?.delegate = self
        titleEntryTextView?.delegate = self
        yearEntryTextView?.delegate = self
        urlEntryTextView?.delegate = self
        
        //Move the UI for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
