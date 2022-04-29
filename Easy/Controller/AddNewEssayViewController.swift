//
//  AddNewEssayViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData

class AddNewEssayViewController: UIViewController {
    var reasonManager = ReasonManager()
    var parentId: NSManagedObjectID?
    var isDismissed: (() -> Void)?
    
    @IBOutlet weak var heightIdeasTableView: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var purposeTableView: UITableView!
    @IBOutlet weak var ideasTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var newEssay: Essay?
    var essays = [Essay]()
    var ideas = [Ideas]()
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = Helper.orangeColor
        navigationController?.navigationBar.prefersLargeTitles = false
        purposeTableView.delegate = self
        purposeTableView.dataSource = self
        
        ideasTableView.delegate = self
        ideasTableView.dataSource = self
        
        let date = Date()
        print(date)
        
        newEssay = Essay(context: context)
        newEssay?.title = "Untitled"
        newEssay?.dateAdded = date
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        loadItems()
 
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        essays.append(newEssay!)
        saveItems()
        loadItems()
        parentId = essays.last?.objectID
//        print(parentId!)
        isDismissed?()
    }
    
    @IBAction func AddIdeaTapped(_ sender: UIButton) {
        
//        print(parentId!)
        performSegue(withIdentifier: "goToAddIdea", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddIdea"{
            let newIdeaVC = segue.destination as! AddNewIdeasViewController
            newIdeaVC.isDismissed = { [weak self] in
                print(self?.essays)
                self?.loadIdeas()
                self?.navigationController?.navigationBar.prefersLargeTitles = false
//            newIdeaVC.parentId = parentIdfix
            }
            
        } else if segue.identifier == "goToDetailIdeas"{
            let detailIdeaVC = segue.destination as! EditIdeaViewController
            if let indexPath = ideasTableView.indexPathForSelectedRow{
                detailIdeaVC.ideasId = ideas[indexPath.row].objectID
            }
            detailIdeaVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = false
//                print(self?.essays)
                self?.loadIdeas()
               
//            newIdeaVC.parentId = parentIdfix
            }
           
            
        } else if segue.identifier == "goToIntroduction"{
            let introVC = segue.destination as! IntroductionViewController
            introVC.isDismissed = { [weak self] in
//                print(self?.essays)
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
        } else if segue.identifier == "goToBody"{
            let bodyVC = segue.destination as! BodyViewController
            bodyVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
        } else if segue.identifier == "goToConclusion"{
            let conclusionVC = segue.destination as! ConclusionViewController
            conclusionVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        newEssay?.title = textField.text
//        print(textField.text)
    }
    
    @IBAction func introductionButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToIntroduction", sender: self)
        
    }
    @IBAction func bodyButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToBody", sender: self)
        
    }
    @IBAction func conclusionButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToConclusion", sender: self)
        
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
        let idPredicate = NSPredicate(format: "parrentEssay == %@", essays.last!)
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

extension AddNewEssayViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == purposeTableView){
            for cell in tableView.visibleCells {
                cell.accessoryType = .none
            }
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            newEssay?.reason = Int16(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if(tableView == ideasTableView){
            performSegue(withIdentifier: "goToDetailIdeas", sender: self)
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        tableViewHeight.constant = purposeTableView.contentSize.height
        purposeTableView.layer.borderColor = Helper.orangeColor.cgColor
        purposeTableView.layer.borderWidth = 1
        purposeTableView.layer.cornerRadius = 10
        ideasTableView.layer.borderColor = Helper.orangeColor.cgColor
        ideasTableView.layer.borderWidth = 1
        ideasTableView.layer.cornerRadius = 10
        if(tableView == ideasTableView){
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Trash action
        if(tableView == ideasTableView){
            let trash = UIContextualAction(style: .destructive,
                title: "Delete") { [weak self] (action, view, completionHandler) in
                
                self!.context.delete((self?.ideas[indexPath.row])!)
                self?.ideas.remove(at: indexPath.row)
                self!.saveItems()
                
                self?.loadIdeas()
                completionHandler(true)
            }
            trash.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [trash])
            return configuration
        }
       return nil
    }
}



extension AddNewEssayViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == purposeTableView){
            return reasonManager.listReason.count
        } else if tableView == ideasTableView{
            if(ideas.count <= 0){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.ideasTableView.bounds.size.width, height: self.ideasTableView.bounds.size.height))
                           noDataLabel.text = "No Ideas available 👀"
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
//            return essays.count
            return ideas.count
        }
        return 0
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == purposeTableView{
            let cell = purposeTableView.dequeueReusableCell(withIdentifier: "cellPurpose")
            
            cell?.backgroundColor = .clear
            cell?.textLabel?.text = reasonManager.listReason[indexPath.row]
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            return cell!
        } else if tableView == ideasTableView{
            
            let cells = ideasTableView.dequeueReusableCell(withIdentifier: "cellIdeas")
            cells?.backgroundColor = .clear
            cells?.textLabel?.text = ideas[indexPath.row].idea
            print(ideas[indexPath.row].idea)
            heightIdeasTableView.constant = ideasTableView.contentSize.height
            ideasTableView.layer.borderColor = Helper.orangeColor.cgColor
            ideasTableView.layer.borderWidth = 1
            ideasTableView.layer.cornerRadius = 10
            return cells!
        }
        
        return UITableViewCell()
        
    }
    
    
}
