//
//  BirthdaysTableViewController.swift
//  BirthdayTracker
//
//  Created by a96 on 12/08/2019.
//  Copyright © 2019 Tony R Inc. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class BirthdaysTableViewController: UITableViewController {

    var birthdays = [Birthday]()
    
    let dateFormatter = DateFormatter()
    
    var firstNameData: [String] = []
    var lastNameData: [String] = []
    var giftIdeasData: [String] = []
    var birthdateData: [Date] = []
    
    @IBAction func saveToBirthdaysTableViewController (segue:UIStoryboardSegue) {
        
        let editBirthdayViewController = segue.source as! EditBirthdayTableViewController
        let editedFirstNameData = editBirthdayViewController.firstNameString
        let editedLastNameData = editBirthdayViewController.lastNameString
        let editedGiftIdeasData = editBirthdayViewController.giftIdeasString
        let editedBirthdateData = editBirthdayViewController.birthdateString
        let index = editBirthdayViewController.index
        
        tableView.reloadData()
        
        //сохранить изменения обратно в таблицу
        let birthday = birthdays[index!]
        birthday.firstName = editedFirstNameData
        birthday.lastName = editedLastNameData
        birthday.giftIdeas = editedGiftIdeasData
        birthday.birthdate = editedBirthdateData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.refresh(birthday, mergeChanges: true)
        
        do {
            try context.save()
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error).")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .long //Тоже что и DateFormatter.Style.long
        dateFormatter.timeStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        
        let sortDescriptor1 = NSSortDescriptor(key: "birthdateWithoutYear", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "firstName", ascending: true)
        let sortDescriptor3 = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3] //сначала сортируем по дате, потом по имени, потом по фамилии
        
        do {
            birthdays = try context.fetch(fetchRequest)
        } catch let error {
            print("Не удалось загрузить данные из-за ошибки: \(error).")
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { //сообщает таблич. представлению, сколько разделов он должен иметь
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //сколько рядов будет отображаться в каждом разделе
        // #warning Incomplete implementation, return the number of rows
        return birthdays.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCellIdentifier", for: indexPath) //создание UITableViewCell
        let birthday = birthdays[indexPath.row] //определение, какой именно Birthday из массива Birthday будет отображаться внутри ячейки
        
        let firstName = birthday.firstName ?? ""
        let lastName = birthday.lastName ?? ""
        let giftIdeas = birthday.giftIdeas ?? ""
        let additionalNotification = birthday.additionalNotification
        
        //возраст
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: birthday.birthdate!, to: now)
        let age = "  \(ageComponents.year!)"
        
        //остаток дней до дня рождения
        let today = Calendar.current.startOfDay(for: Date())
        let dayAndMonth = Calendar.current.dateComponents([.day, .month], from: birthday.birthdate!)
        let nextBirthDay = Calendar.current.nextDate(after: today, matching: dayAndMonth, matchingPolicy: .nextTimePreservingSmallerComponents)! //.nextTimePreservingSmallerComponents - если день рождения 29 февраля, его следующее появление будет рассчитанно на 1 марта, если год не является високосным годом
        let difference = Calendar.current.dateComponents([.day], from: today, to: nextBirthDay)
        
        //правильное окончание
        func rightDay() -> String {
            var day = "дней"
            let remainder = difference.day! % 10
            switch remainder {
            case 1:
                if difference.day! != 11 {
                    day = "день"
                }
            case 2,3,4:
                if difference.day! != 12 && difference.day! != 13 && difference.day! != 14 {
                    day = "дня"
                }
            default:
                break
            }
            let tomorrow = Calendar.current.date(byAdding: .day, value: +1, to: today)!
            if Calendar.current.dateComponents([.day, .month], from: today) == dayAndMonth {
                return "Сегодня 🥳"
            }
            else if Calendar.current.dateComponents([.day, .month], from: tomorrow) == dayAndMonth {
                return "Завтра 😏"
            }
            else if additionalNotification == 1 && difference.day! == 7 {
                return "7 дней ☝️"
            }
            else if additionalNotification == 2 && difference.day! == 14 {
                return "14 дней ☝️"
            }
            else if additionalNotification == 3 && difference.day! == 30 {
                return "30 дней ☝️"
            }
            else {
                return "\(difference.day!) " + day
            }
        }
        
        //сделать часть текста жирной
        let attributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
        let attributes2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
        let boldString = NSMutableAttributedString(string: firstName, attributes: attributes)
        let normalString = NSMutableAttributedString(string: " " + lastName, attributes: attributes2)
        boldString.append(normalString)
        
        //изменить цвет части текста
        let range = (age as NSString).range(of: age)
        let ageString = NSMutableAttributedString(string: age, attributes: attributes2)
        if #available(iOS 13.0, *) {
            ageString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray , range: range)
        } else {
            // Fallback on earlier versions
            ageString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray , range: range)
        }
        boldString.append(ageString)
        
//        cell.textLabel?.text = firstName + " " + lastName //надпись для отображения в ячейке имени
        cell.textLabel?.attributedText = boldString
        
        if let date = birthday.birthdate as Date? {
            //собственное отображение даты
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            //дополнительное уведомление, и за сколько оно дней
            var rest = String()
            switch additionalNotification {
            case 0:
                rest = ""
            case 1:
                rest = " 7"
            case 2:
                rest = " 14"
            case 3:
                rest = " 30"
            default:
                ()
            };
            
            //изменить цвет части текста
            let mainString = formatter.string(from: date) + " (" + rightDay() + ")\(rest)  " + giftIdeas
            let range2 = (mainString as NSString).range(of: formatter.string(from: date) + " (" + rightDay() + ")")
            let range3 = (mainString as NSString).range(of: rest)
            let range4 = (mainString as NSString).range(of: giftIdeas)
            let attributes3 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
            let attributedString = NSMutableAttributedString(string: mainString, attributes: attributes3)
            if #available(iOS 13.0, *) {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray , range: range2)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray2 , range: range4)
            } else {
                // Fallback on earlier versions
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray , range: range2)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray , range: range4)
            }
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.purple , range: range3)
            
//            cell.detailTextLabel?.text = dateFormatter.string(from: date) + " (" + rightDay() + ") → " + giftIdeas //надпись для отображения в ячейке даты рождения
            cell.detailTextLabel?.attributedText = attributedString
            cell.detailTextLabel?.numberOfLines = 0
        } else {
            cell.detailTextLabel?.text = " "
        }
        
        return cell //возвращение ячейки в формате, готовом к отображению в табличном представлении
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if birthdays.count > indexPath.row { //birthdays.count - кол-во ДР, а indexPath.row - индексы ДР (их отсчет начинается с 0), поэтому знак >
            
            let birthday = birthdays[indexPath.row]
            
            // Удаляем уведомление
            if let identifier = birthday.birthdayId {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
                
                //удаляем второе уведомление
                let center2 = UNUserNotificationCenter.current()
                center2.removePendingNotificationRequests(withIdentifiers: [identifier + "2"])
                
                //удаляем дополнительное уведомление
                let center3 = UNUserNotificationCenter.current()
                center3.removePendingNotificationRequests(withIdentifiers: [identifier + "3"])
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(birthday)
            birthdays.remove(at: indexPath.row)
            
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки \(error).")
            }
            
            tableView.deleteRows(at:[indexPath],with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            
            let path = tableView.indexPathForSelectedRow
            let destination = segue.destination as! EditBirthdayTableViewController
            destination.index = path?.row
            
            firstNameData.removeAll()
            lastNameData.removeAll()
            giftIdeasData.removeAll()
            birthdateData.removeAll()
            for number in 0...(birthdays.count-1) {
                firstNameData.append(birthdays[number].firstName ?? "")
                lastNameData.append(birthdays[number].lastName ?? "")
                giftIdeasData.append(birthdays[number].giftIdeas ?? "")
                birthdateData.append(birthdays[number].birthdate!) //!, т.к. значение точно не nil
            }
            
            destination.firstName = firstNameData
            destination.lastName = lastNameData
            destination.giftIdeas = giftIdeasData
            destination.birthdate = birthdateData
            
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
