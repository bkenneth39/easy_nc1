//
//  IntoFAQViewController.swift
//  Easy
//
//  Created by Bryan Kenneth on 06/05/22.
//

import UIKit
import SafariServices

class IntoFAQViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
   
    var introFAQManager = IntroFAQManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
       
    }

    @IBAction func readMoreBtnPressed(_ sender: UIBarButtonItem) {
        if let url = URL(string: "https://www.scribbr.com/academic-essay/introduction/") {
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

extension IntoFAQViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "introfaqcell", for: indexPath)
      
       
        if indexPath.row == 0{
            cell.textLabel?.text = introFAQManager.introArray[indexPath.section].title
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
            cell.textLabel?.text = introFAQManager.introArray[indexPath.section].answers[indexPath.row - 1]
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
        return introFAQManager.introArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let question = introFAQManager.introArray[section]
        if(question.isOpened){
            return question.answers.count + 1
        } else {
            return 1
        }
    }
}

extension IntoFAQViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0){
            introFAQManager.introArray[indexPath.section].isOpened = !introFAQManager.introArray[indexPath.section].isOpened
            
            
            tableView.reloadSections([indexPath.section], with: .none)
           
        }
    }
}
