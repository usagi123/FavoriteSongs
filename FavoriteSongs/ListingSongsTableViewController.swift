//
//  ListingSongsTableViewController.swift
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

class ListingSongsTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item] = []
    var item: Item!
    var selectedIndex: Int!
    var filteredData: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchData()
    }
    
    func fetchData() {
        
        do {
            items = try context.fetch(Item.fetchRequest())
            filteredData = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Couldn't Fetch Data")
            let alert = UIAlertController(title: "Couldn't load data", message: "Data cannot be loaded from storage", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//Custom table view cell contents
class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headlineImageView: UIImageView!
    @IBOutlet weak var headlineTitleLabel: UILabel!
    @IBOutlet weak var headlineNameLabel: UILabel!
    @IBOutlet weak var headlineYearLabel: UILabel!
}

//Mandatory stuff to construct a table view cell
extension ListingSongsTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HeadlineTableViewCell
        
        cell.headlineTitleLabel.text = filteredData[indexPath.row].title!
        cell.headlineNameLabel.text = "by " + filteredData[indexPath.row].name!
        cell.headlineYearLabel.text = filteredData[indexPath.row].year
        cell.headlineImageView.image = UIImage(data: filteredData[indexPath.row].image!)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView))
        
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        cell.headlineImageView.addGestureRecognizer(singleTap)
        
        return cell
    }
    
    //Tap image in cell to open URL
    @objc func tappedOnView(onView gesture: UITapGestureRecognizer) {
        let location: CGPoint = gesture.location(in: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: location)
        var urlString = filteredData[(indexPath?.row)!].url
        if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
        } else {
            urlString = "http://" + urlString!
        }
        let url: URL = URL(string: urlString!)!
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "UpdateVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //swipe left for delete/open url
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            
            let item = self.filteredData[indexPath.row]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.filteredData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        let openURL = UITableViewRowAction(style: .default, title: "Open URL") { (action, indexPath) in
            let item = self.filteredData[indexPath.row]
            var urlString = item.url
            if (((urlString?.lowercased().range(of: "http://")) != nil) || ((urlString?.lowercased().range(of: "https://")) != nil)) {
            } else {
                urlString = "http://" + urlString!
            }
            let url: URL = URL(string: urlString!)!
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = UIColor(red: 240/255, green: 52/255, blue: 52/255, alpha: 1.0)
        openURL.backgroundColor = UIColor(red: 3/255, green: 201/255, blue: 169/255, alpha: 1.0)
        
        return [delete,openURL]
    }
    
    //Pass data from table view to View/Edit through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UpdateVC" {
            let updateVC = segue.destination as! EditSongViewController
            updateVC.item = filteredData[selectedIndex!]
        }
    }
}
