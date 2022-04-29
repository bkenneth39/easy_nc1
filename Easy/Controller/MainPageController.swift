//
//  ViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 27/04/22.
//

import UIKit
import CoreData

class MainPageController: UIViewController {
    var essays = [Essay]()
    var ideas = [Ideas]()
    
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "Let's Start"
//        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem?.tintColor = Helper.orangeColor
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.borderColor = Helper.orangeColor.cgColor
        
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 10
      
        loadItems()
        loadIdeas()
       
    }
    
    @objc func addTapped(){
        performSegue(withIdentifier: "goToAddNewEssay", sender: self)
    }
    
    func loadItems() {
        let request: NSFetchRequest<Essay> = Essay.fetchRequest()
        let sort = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [sort]
        do{
            essays = try context.fetch(request)
            tableView.reloadData()
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
        tableView.reloadData()
    }
    
    func loadIdeas(){
        let requestIdeas: NSFetchRequest<Ideas> = Ideas.fetchRequest()
       
        
        do{
            ideas = try context.fetch(requestIdeas)
            print(ideas.count)
            
        }catch{
            print(error)
        }
       
    }


}

extension MainPageController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = true
                self?.loadItems()
                self?.tableView.reloadData()
                self?.loadIdeas()
            }
//            detailVC.indexData = tableView.indexPathForSelectedRow?.row
            if let selectedRow = tableView.indexPathForSelectedRow{
                detailVC.parentId = essays[selectedRow.row].objectID
            }
           
        } else if segue.identifier == "goToAddNewEssay" {
            let newVC = segue.destination as! AddNewEssayViewController
            newVC.isDismissed = { [weak self] in
                self?.navigationController?.navigationBar.prefersLargeTitles = true
                self?.loadItems()
                self?.tableView.reloadData()
                self?.loadIdeas()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Trash action
        let trash = UIContextualAction(style: .destructive,
            title: "Delete") { [weak self] (action, view, completionHandler) in
            
            self!.context.delete((self?.essays[indexPath.row])!)
            self?.essays.remove(at: indexPath.row)
            self!.saveItems()
            self?.loadIdeas()
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [trash])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
    }
}

extension MainPageController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "essayCell")
        cell?.backgroundColor = .clear
        cell?.textLabel?.text = essays[indexPath.row].title
//        print(essays[indexPath.row].id)
//        print(essays[indexPath.row].objectID)
        
        cell?.imageView?.image = UIImage(systemName: "newspaper.fill")
        cell?.imageView?.tintColor = .black
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(essays.count <= 0){
            var noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                       noDataLabel.text = "No essay available 🥲"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
        } else {
            var noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                       noDataLabel.text = ""
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
        }
        return essays.count
       
    }
    
    
}
