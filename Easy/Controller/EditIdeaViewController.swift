//
//  EditIdeaViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData
import SafariServices

class EditIdeaViewController: UIViewController,SFSafariViewControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    var ideasId: NSManagedObjectID?
    var ideas = [Ideas]()
    var object: Ideas?
    var isDismissed: (() -> Void)?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = Helper.orangeColor
        navigationController?.navigationBar.prefersLargeTitles = false
        titleTextField.layer.masksToBounds = true
        titleTextField.layer.borderColor = Helper.orangeColor.cgColor
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 10
        urlTextField.layer.masksToBounds = true
        urlTextField.layer.borderColor = Helper.orangeColor.cgColor
        urlTextField.layer.borderWidth = 1.0
        urlTextField.layer.cornerRadius = 10
//        loadIdeas()
        if let ideasId = ideasId {
            do{
                object = try context.existingObject(with: ideasId) as! Ideas
                print(object)
                titleTextField.text = object?.idea
                urlTextField.text = object?.urllink
            } catch {
                print(error)
            }
            
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.isDismissed?()
    }
    func saveItems(){
        do{
            try context.save()
        }catch{
            print(error)
        }
    }
    
    @IBAction func openLinkBtnPressed(_ sender: UIButton) {
        if let url = URL(string: object?.urllink ?? "https://google.com") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self

            present(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Link Not Valid", message: "Try change your link or include https://", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        object?.idea = titleTextField.text
        object?.urllink = urlTextField.text
        saveItems()
        self.isDismissed?()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Ideas", message: "You sure about deleting the idea?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
//            self.navigationController?.popViewController(animated: true)
            if let object = self.object {
                self.context.delete(object)
                self.saveItems()
                self.isDismissed?()
                self.navigationController?.popViewController(animated: true)
            }
           
        }))
        self.present(alert, animated: true, completion: {
               print("completion block")
        })
    }
    
}
