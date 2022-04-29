//
//  DetailViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
   
    var reasonManager = ReasonManager()
    var parentId: NSManagedObjectID?
    var isDismissed: (() -> Void)?
    var currentEssay: Essay?
    var essays = [Essay]()
    var ideas = [Ideas]()
    var chosenReason = 0

    @IBOutlet weak var heightIdeasTableView: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reasonTableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dataEssay = Essay()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var purposeTableView: UITableView!
    @IBOutlet weak var ideasTableView: UITableView!
    var indexData: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = Helper.orangeColor
        navigationController?.navigationBar.prefersLargeTitles = false
        print(indexData)
        
        purposeTableView.delegate = self
        purposeTableView.dataSource = self
        
        ideasTableView.delegate = self
        ideasTableView.dataSource = self
        
        if let parentId = parentId {
            do{
                currentEssay = try context.existingObject(with: parentId) as? Essay
                print(currentEssay)
               
                loadIdeas()
                titleTextField.text = currentEssay?.title
                chosenReason = Int(currentEssay?.reason ?? 0)
                titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            }catch{
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        essays.append(newEssay!)
        saveItems()
//        loadItems()
//        parentId = essays.last?.objectID
//        print(parentId!)
        isDismissed?()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        currentEssay?.title = textField.text
//        print(textField.text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddIdea"{
            let newIdeaVC = segue.destination as! AddNewIdeasViewController
            newIdeaVC.parentId = currentEssay?.objectID
            newIdeaVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = false
                print(self?.essays)
                self?.loadIdeas()
               
//            newIdeaVC.parentId = parentIdfix
            }
            
        } else if segue.identifier == "goToDetailIdeas"{
            let detailIdeaVC = segue.destination as! EditIdeaViewController
            if let indexPath = ideasTableView.indexPathForSelectedRow{
                detailIdeaVC.ideasId = ideas[indexPath.row].objectID
            }
            detailIdeaVC.isDismissed = { [weak self] in
//                print(self?.essays)
                self?.navigationController?.navigationBar.prefersLargeTitles = false
                self?.loadIdeas()
               
//            newIdeaVC.parentId = parentIdfix
            }
        } else if segue.identifier == "goToIntroduction"{
            let introVC = segue.destination as! IntroductionViewController
            introVC.parentId = currentEssay?.objectID
            introVC.isDismissed = { [weak self] in
//                print(self?.essays)
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
            
        } else if segue.identifier == "goToBody"{
            let bodyVC = segue.destination as! BodyViewController
            bodyVC.parentId = currentEssay?.objectID
            bodyVC.isDismissed = { [weak self] in
//                print(self?.essays)
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
        } else if segue.identifier == "goToConclusion"{
            let conclusionVC = segue.destination as! ConclusionViewController
            conclusionVC.parentId = currentEssay?.objectID
            conclusionVC.isDismissed = { [weak self] in
//                print(self?.essays)
                self?.navigationController?.navigationBar.prefersLargeTitles = false
            }
        }
    }
    
    @IBAction func bodyBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToBody", sender: self)
    }
    
    @IBAction func introBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToIntroduction", sender: self)
    }
    
    @IBAction func conclusionBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToConclusion", sender: self)
    }
    
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Ideas", message: "You sure about deleting the idea?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
//            self.navigationController?.popViewController(animated: true)
            if let currentEssay = self.currentEssay {
                self.context.delete(currentEssay)
                self.saveItems()
                self.isDismissed?()
                self.navigationController?.popViewController(animated: true)
            }
           
        }))
        self.present(alert, animated: true, completion: {
               print("completion block")
        })
    }
    @IBAction func addIdeaBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToAddIdea", sender: self)
        
    }
    func loadIdeas(){
        let requestIdeas: NSFetchRequest<Ideas> = Ideas.fetchRequest()
        let idPredicate = NSPredicate(format: "parrentEssay == %@", currentEssay!)
        requestIdeas.predicate = idPredicate
        
        do{
            ideas = try context.fetch(requestIdeas)
            print(ideas)
        }catch{
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
}

extension DetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == purposeTableView){
            for cell in tableView.visibleCells {
                cell.accessoryType = .none
            }
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            currentEssay?.reason = Int16(indexPath.row)
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
        if(tableView == purposeTableView){
            cell.accessoryType = indexPath.row == currentEssay!.reason ? .checkmark : .none
            cell.tintColor = Helper.orangeColor
        }else if(tableView == ideasTableView){
            cell.accessoryType = .disclosureIndicator
            cell.tintColor = Helper.orangeColor
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

extension DetailViewController: UITableViewDataSource{
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


