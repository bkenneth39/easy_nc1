//
//  ConclusionViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 28/04/22.
//

import UIKit
import CoreData

class ConclusionViewController: UIViewController {
    var parentId: NSManagedObjectID?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var essay: Essay?
    var essays = [Essay]()
    var ideas = [Ideas]()
    var isDismissed: (() -> Void)?
   

    @IBOutlet weak var ideasTableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var conclusionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        textView.layer.borderColor = Helper.orangeColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10

        ideasTableView.layer.borderColor = Helper.orangeColor.cgColor
        ideasTableView.layer.borderWidth = 1
        ideasTableView.layer.cornerRadius = 10
        
        ideasTableView.separatorColor = .clear
        
        ideasTableView.dataSource = self
        
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)

        let largeBoldDoc = UIImage(systemName: "chevron.left", withConfiguration: largeConfig)
        
        button.setImage(largeBoldDoc, for: .normal)
           button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.sizeToFit()
        button.imageView?.tintColor = Helper.orangeColor
        
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: button)
        
        button.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
      
        if let parentId = parentId {
            print(parentId)
            do{
                essay = try context.existingObject(with: parentId) as? Essay
                loadIdeas()
                if(essay?.conclusion != "" && essay?.conclusion != nil){
                    conclusionTextView.text = essay?.conclusion
                }
            }catch{
                print(error)
            }
        } else {
            loadItems()
            loadIdeas()
            essay = essays.last
            if(essay?.conclusion != "" && essay?.conclusion != nil){
                conclusionTextView.text = essay?.conclusion
            }
            print(essay)
        }
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        if(essay?.conclusion != conclusionTextView.text){
            let refreshAlert = UIAlertController(title: "Changes not saved", message: "Would you like to save changes you made?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { (action: UIAlertAction!) in
                self.essay?.conclusion = self.conclusionTextView.text
                self.saveItems()
                self.isDismissed?()
                self.navigationController?.popViewController(animated: true)
            }))

            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                self.isDismissed?()
                self.navigationController?.popViewController(animated: true)
            }))

            present(refreshAlert, animated: true, completion: nil)
        } else {
            self.isDismissed?()
            navigationController?.popViewController(animated: true)
        }
        
       
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        
        isDismissed?()
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
       
        essay?.conclusion = conclusionTextView.text
        saveItems()
        isDismissed?()
        navigationController?.popViewController(animated: true)
    }
    
    func loadItems() {
        let request: NSFetchRequest<Essay> = Essay.fetchRequest()
        let sort = NSSortDescriptor(key: "dateAdded", ascending: true)
        request.sortDescriptors = [sort]
        do{
            essays = try context.fetch(request)
        } catch {
            print(error)
        }
        ideasTableView.reloadData()
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print(error)
        }
    }
    
    func loadIdeas(){
        let requestIdeas: NSFetchRequest<Ideas> = Ideas.fetchRequest()
        let idPredicate: NSPredicate?
        if let parentId = parentId {
            idPredicate = NSPredicate(format: "parrentEssay == %@", essay!)
        } else {
            idPredicate = NSPredicate(format: "parrentEssay == %@", essays.last!)
        }
        requestIdeas.predicate = idPredicate
        
        do{
            ideas = try context.fetch(requestIdeas)
            print(ideas)
        }catch{
            print(error)
        }
        ideasTableView.reloadData()
    }
    
    @IBAction func infoBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToConclusionFAQ", sender: self)
    }
}

extension ConclusionViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(ideas.count <= 0){
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.ideasTableView.bounds.size.width, height: self.ideasTableView.bounds.size.height))
                       noDataLabel.text = "No Ideas have been added 🤔"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            ideasTableView.backgroundView = noDataLabel
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.ideasTableView.bounds.size.width, height: self.ideasTableView.bounds.size.height))
                       noDataLabel.text = ""
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            ideasTableView.backgroundView = noDataLabel
        }
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cells = ideasTableView.dequeueReusableCell(withIdentifier: "cellIdeas")
        cells?.backgroundColor = .clear
        cells?.textLabel?.text = ideas[indexPath.row].idea
        return cells!
    }
    
    
}
