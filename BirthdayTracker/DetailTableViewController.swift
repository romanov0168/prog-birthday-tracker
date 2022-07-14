//
//  EditBirthdayTableViewController.swift
//  BirthdayTracker
//
//  Created by a96 on 18/09/2019.
//  Copyright © 2019 Tony R Inc. All rights reserved.
//

import UIKit

class EditBirthdayTableViewController: UITableViewController {
    
    @IBOutlet weak var editFirstNameTextField: UITextField!
    
    @IBOutlet weak var editLastNameTextField: UITextField!
    
    @IBOutlet weak var editGiftIdeasTextField: UITextField!
    
    @IBOutlet weak var editBirthdatePicker: UIDatePicker!
    
    var firstName:[String]!
    
    var lastName:[String]!
    
    var giftIdeas:[String]!
    
    var birthdate:[Date]!
    
    var index:Int?
    
    var firstNameString:String?
    
    var lastNameString:String?
    
    var giftIdeasString:String?
    
    var birthdateString:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editFirstNameTextField.text = firstName[index!]
        editLastNameTextField.text = lastName[index!]
        editGiftIdeasTextField.text = giftIdeas[index!]
        editBirthdatePicker.date = birthdate[index!]
        print(birthdate[index!])
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            editFirstNameTextField.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            editLastNameTextField.becomeFirstResponder()
        }
        else if indexPath.section == 2 && indexPath.row == 0 {
            editGiftIdeasTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     // MARK: - Table view firstName source
     
     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 0
     }
     
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 0
     }
     
     
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the firstName source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "edit" { //изначально было так: if segue.identifier != "save", но в Swift 4 у кнопки нет поля Identifier. НАПИСАТЬ УСЛОВИЕ ПОЛУЧШЕ!!!
            firstNameString = editFirstNameTextField.text
            lastNameString = editLastNameTextField.text
            giftIdeasString = editGiftIdeasTextField.text
            birthdateString = editBirthdatePicker.date
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
}
