//
//  MasterViewController.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import UIKit
import PINRemoteImage

class MasterViewController: UITableViewController {
  
  var detailViewController: DetailViewController? = nil
  var gists = [Gist]()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    navigationItem.leftBarButtonItem = editButtonItem
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadGists()
  }
  
  func loadGists() {
    GitHubAPIManager.shared.fetchPublicGists() {
      result in
      guard result.error == nil else {
        self.handleLoadGistsError(result.error!)
        return
      }
      if let fetchedGists = result.value {
        self.gists = fetchedGists
      }
      self.tableView.reloadData()
    }
  }
  
  func handleLoadGistsError(_ error: Error) {
    // TODO: show error
  }
  
  @objc
  func insertNewObject(_ sender: Any) {
    let alert = UIAlertController(title: "Not Implemented",
                                  message: "Can't create new gists yet, will implement later",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
                                  style: .default,
                                  handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let gist = gists[indexPath.row]
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = gist
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: - Table View
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gists.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let gist = gists[indexPath.row]
    cell.textLabel?.text = gist.gistDescription
    cell.detailTextLabel?.text = gist.owner?.login
    
    cell.imageView?.image = nil
    if let url = gist.owner?.avatarURL {
      GitHubAPIManager.shared.imageFrom(url: url) {
        (image, error) in
        guard error == nil else {
          print(error!)
          return
        }
        
        if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) {
          cellToUpdate.imageView?.image = image // will work fine even if image is nil
          // need to reload the view, which won't happen otherwise
          // since this is in an async call
          cellToUpdate.setNeedsLayout()
        }
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      gists.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
}