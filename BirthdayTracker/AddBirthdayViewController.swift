//
//  ViewController.swift
//  BirthdayTracker
//
//  Created by a96 on 09/08/2019.
//  Copyright © 2019 Tony R Inc. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

//скрытие клавиатуры
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)) //ищет один или несколько нажатий
        //чтобы тап не мешал, и отменял другие взаимодействия - раскоментировать строку ниже
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() { //вызывает функцию выше, когда касание распознано
        view.endEditing(true) //заставляет представление (или одно из его встроенных текстовых полей) отказаться от статуса первого респондента
    }
}

class AddBirthdayViewController: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var giftIdeasTextField: UITextField!
    @IBOutlet var birthdatePicker: UIDatePicker!
    @IBOutlet var additionalNotificationSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() { //Метод изначальной настройки
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        birthdatePicker.maximumDate = Date()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let giftIdeas = giftIdeasTextField.text ?? ""
        let birthdate = birthdatePicker.date
        let additionalNotification = additionalNotificationSegmentedControl.selectedSegmentIndex
        
        //для сортировки по дню рождения без учета года
        let myDateComponents = Calendar.current.dateComponents([.month, .day, .hour], from: birthdate) //без .hour дата будет на 1 день меньше
        let birthdateWithoutYear = Calendar.current.date(from: myDateComponents)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBirthday = Birthday(context: context)
        newBirthday.firstName = firstName
        newBirthday.lastName = lastName
        newBirthday.giftIdeas = giftIdeas
        newBirthday.birthdate = birthdate as Date?
        newBirthday.birthdateWithoutYear = birthdateWithoutYear as Date?
        newBirthday.additionalNotification = Int16(additionalNotification)
        newBirthday.birthdayId = UUID().uuidString
        if let uniqueId = newBirthday.birthdayId {
            print("birthdayId: \(uniqueId)")
        }
        
        do {
            
            try context.save()
            let message = "Сегодня \(firstName) \(lastName) празднует день рождения!"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            
            var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthdate)
            dateComponents.hour = 8
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            //второе уведомление
            let message2 = "Завтра \(firstName) \(lastName) будет праздновать день рождения!"
            let content2 = UNMutableNotificationContent()
            content2.body = message2
            content2.sound = UNNotificationSound.default
            
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: birthdate)!
            var dateComponents2 = Calendar.current.dateComponents([.month, .day], from: oneDayAgo)
            dateComponents2.hour = 8
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: true)
            
            //дополнительное уведомление
            var rest = Int()
            switch additionalNotification {
            case 0:
                rest = 0
            case 1:
                rest = 7
            case 2:
                rest = 14
            case 3:
                rest = 30
            default:
                ()
            }
            let message3 = "Через \(rest) дней \(firstName) \(lastName) будет праздновать день рождения!"
            let content3 = UNMutableNotificationContent()
            content3.body = message3
            content3.sound = UNNotificationSound.default
            
            let fewDaysAgo = Calendar.current.date(byAdding: .day, value: -rest, to: birthdate)!
            var dateComponents3 = Calendar.current.dateComponents([.month, .day], from: fewDaysAgo)
            dateComponents3.hour = 18
            dateComponents3.minute = 47
            let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateComponents3, repeats: true)
            
            if let identifier = newBirthday.birthdayId {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
                
                //второе уведомление
                let request2 = UNNotificationRequest(identifier: identifier + "2", content: content2, trigger: trigger2)
                let center2 = UNUserNotificationCenter.current()
                center2.add(request2, withCompletionHandler: nil)
                
                //дополнительное уведомление
                let request3 = UNNotificationRequest(identifier: identifier + "3", content: content3, trigger: trigger3)
                let center3 = UNUserNotificationCenter.current()
                if additionalNotification != 0 {
                    center3.add(request3, withCompletionHandler: nil)
                }
            }
        
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error).")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
