//
//  EditSongViewController.swift
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

class EditSongViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: Item!
    var editToggle: Bool = false
    
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var yearText: UITextView!
    @IBOutlet weak var urlText: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImageByTapping(_ sender: UITapGestureRecognizer) {
        
        switch editToggle {
        case true: //if edit mode is true, tap the image to select image
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            
            let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
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
            
            //For ipad
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            self.present(actionSheet, animated: true, completion: nil)
        case false: //else, tap the image to open url
            var urlString = urlText.text
            if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
            } else {
                urlString = "http://" + urlString!
            }
            let url: URL = URL(string: urlString!)!
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        }
    }

    //Prepare field to be editable between edit/view mode
    func textFieldActive() {
        
        entryText.isEditable = true
        titleText.isEditable = true
        yearText.isEditable = true
        urlText.isHidden = false
        urlText.isEditable = true
        imageView.isUserInteractionEnabled = true
    }
    
    func textFieldDeactive() {
        
        entryText.isEditable = false
        titleText.isEditable = false
        yearText.isEditable = false
        urlText.isHidden = true
        urlText.isEditable = false
        imageView.isUserInteractionEnabled = false
    }
    
    @IBOutlet weak var updateHeadingOutlet: UILabel!
    @IBOutlet weak var updateActionOutlet: UIButton!
    @IBAction func updateAction(_ sender: Any) {
        
        switch editToggle {
        case false:
            //Switch to edit mode when Edit button was pressed
            guard let newEntry = entryText.text,
                let newTitle = titleText.text,
                let newYear = yearText.text,
                let newURL = urlText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //Assign which attribute belong to which entity so they can load correctly into their field (Read)
            item.name = newEntry
            item.title = newTitle
            item.year = newYear
            item.url = newURL
            item.image = UIImageJPEGRepresentation(newImage, 1)! as Data //Convert Binary data from Core Data to UIImage data for display
            
            updateHeadingOutlet.text = "Update Song"
            updateActionOutlet.setTitle("Update", for: UIControlState.normal)
            textFieldActive()
            editToggle = true
        case true:
            guard let newEntry = entryText.text,
                let newTitle = titleText.text,
                let newYear = yearText.text,
                let newURL = urlText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //If one field is empty then alert user to fully filled it before saving
            if ((titleText?.text.isEmpty)! || (entryText?.text.isEmpty)! || (yearText?.text.isEmpty)! || (urlText?.text.isEmpty)!) {
                
                let alert = UIAlertController(title: "Blank field", message: "Please fully filled all details", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
                
                self.present(alert, animated: true, completion: nil)
                
            } else if Double(yearText.text) == nil { //Filter number only in the year field
                
                print("Error, not number input")
                let alert = UIAlertController(title: "Wrong data type", message: "Please type number only", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                //Save new data from inside all fields back to Core Data (Update)
                item.name = newEntry
                item.title = newTitle
                item.year = newYear
                item.url = newURL
                item.image = UIImageJPEGRepresentation(newImage, 1)! as Data
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //Switch back to view mode after press Update button
                updateHeadingOutlet.text = "View Song"
                updateActionOutlet.setTitle("Edit", for: UIControlState.normal)
                textFieldDeactive()
                editToggle = false
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        entryText!.delegate = self
        titleText!.delegate = self
        yearText!.delegate = self
        yearText.keyboardType = .numberPad
        urlText!.delegate = self
        let img = UIImage(data: item.image! as Data)
        imageView.image = img
        
        configureEntryData(entry: item)
        print(item)
        
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
    
    //Call Core Data entity and attributes
    func configureEntryData(entry: Item) {
        
        guard let text = entry.name,
            let title = entry.title,
            let year = entry.year,
            let url = entry.url else {
                return
        }
        
        entryText!.text = text
        titleText!.text = title
        yearText!.text = year
        urlText!.text = url
    }
    
    //View keyboard everytime clicking into field
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    //Press return to finish typing that field
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
