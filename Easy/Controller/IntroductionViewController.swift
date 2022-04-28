//
//  IntroductionViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData

class IntroductionViewController: UIViewController {
    var parentId: NSManagedObjectID?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var essay: Essay?
    var essays = [Essay]()
    var ideas = [Ideas]()
    var isDismissed: (() -> Void)?
    
    
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var ideasTableView: UITableView!
    @IBOutlet weak var introductionTableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderColor = Helper.orangeColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        
        ideasTableView.dataSource = self
        ideasTableView.delegate = self
        
        ideasTableView.layer.borderColor = Helper.orangeColor.cgColor
        ideasTableView.layer.borderWidth = 1
        ideasTableView.layer.cornerRadius = 10
        
        if let parentId = parentId {
            print(parentId)
            do{
                essay = try context.existingObject(with: parentId) as? Essay
                loadIdeas()
                if(essay?.introduction != "" && essay?.introduction != nil){
                    introductionTextView.text = essay?.introduction
                }
            }catch{
                print(error)
            }
        } else {
            loadItems()
            loadIdeas()
            essay = essays.last
            if(essay?.introduction != "" && essay?.introduction != nil){
                introductionTextView.text = essay?.introduction
            }
            print(essay)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isDismissed?()
    }
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        essay?.introduction = introductionTextView.text
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

}

extension IntroductionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
}
extension IntroductionViewController: UITableViewDataSource{
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
