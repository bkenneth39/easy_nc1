//
//  AddNewIdeasViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData

class AddNewIdeasViewController: UIViewController {
    var parentId: NSManagedObjectID?
    var flagg: Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var essays = [Essay]()
    var ideas = [Ideas]()
    var newIdea: Ideas?
    var isDismissed: (() -> Void)?
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.layer.masksToBounds = true
        textField.layer.borderColor = Helper.orangeColor.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 10
        linkTextField.layer.masksToBounds = true
        linkTextField.layer.borderColor = Helper.orangeColor.cgColor
        linkTextField.layer.borderWidth = 1.0
        linkTextField.layer.cornerRadius = 10
        
        newIdea = Ideas(context: context)
        if let parentId = parentId {
            print(parentId)
            do{
                newIdea?.parrentEssay = try context.existingObject(with: parentId) as? Essay
            } catch{
                print(error)
            }
        } else {
            print("still no parentId")
            loadItems()
            print(essays)
//            parentId =
            print(essays.last?.objectID)
            newIdea?.parrentEssay = essays.last
           
        }
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        linkTextField.addTarget(self, action: #selector(self.textFieldDidChange2(_:)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        newIdea?.idea = textField.text
//        print(textField.text)
    }
    @objc func textFieldDidChange2(_ textField: UITextField) {
        newIdea?.urllink = textField.text
//        print(textField.text)
    }
    

    @IBAction func saveBtnPressed(_ sender: UIButton) {
        print(newIdea)
        if let newIdea = newIdea {
            newIdea.idea = textField.text != "" ? textField.text : "Untitled Idea"
            ideas.append(newIdea)
        }
        
        saveItems()
        isDismissed?()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let newIdea = newIdea {
            newIdea.idea = textField.text != "" ? textField.text : "Untitled Idea"
            ideas.append(newIdea)
        }
        isDismissed?()
    }
    func loadItems() {
        let request: NSFetchRequest<Essay> = Essay.fetchRequest()
        let requestIdeas: NSFetchRequest<Ideas> = Ideas.fetchRequest()
        let sort = NSSortDescriptor(key: "dateAdded", ascending: true)
        request.sortDescriptors = [sort]
        do{
            essays = try context.fetch(request)
            ideas = try context.fetch(requestIdeas)
           
        } catch {
            print(error)
        }
        
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print(error)
        }
    }

}
