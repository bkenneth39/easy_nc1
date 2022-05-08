//
//  ConclusionFAQViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 07/05/22.
//

import UIKit
import SafariServices

class ConclusionFAQViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var conclusionFAQManager = ConclusionFAQManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    @IBAction func readBtnPressed(_ sender: UIBarButtonItem) {
        if let url = URL(string: "https://www.scribbr.com/academic-essay/conclusion/") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self

            present(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Link Not Valid", message: "Try change your link or include https://", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ConclusionFAQViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conclusionfaqcell", for: indexPath)
      
       
        if indexPath.row == 0{
            cell.textLabel?.text = conclusionFAQManager.conclusionArray[indexPath.section].title
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = Helper.orangeColor
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            cell.imageView?.image = UIImage(systemName: "questionmark.circle.fill")
            cell.imageView?.tintColor = Helper.orangeColor
            
            return cell
        } else {
            cell.textLabel?.text = conclusionFAQManager.conclusionArray[indexPath.section].answers[indexPath.row - 1]
            cell.accessoryType = .none
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = Helper.orangeColor
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.imageView?.image = .none
           
           
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return conclusionFAQManager.conclusionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let question = conclusionFAQManager.conclusionArray[section]
        if(question.isOpened){
            return question.answers.count + 1
        } else {
            return 1
        }
    }
}

extension ConclusionFAQViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0){
            conclusionFAQManager.conclusionArray[indexPath.section].isOpened = !conclusionFAQManager.conclusionArray[indexPath.section].isOpened
            
            
            tableView.reloadSections([indexPath.section], with: .none)
           
        }
    }
}
