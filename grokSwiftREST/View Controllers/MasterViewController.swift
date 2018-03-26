//
//  MasterViewController.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-22.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import UIKit
import PINRemoteImage
import SafariServices

class MasterViewController: UITableViewController, LoginViewDelegate, SFSafariViewControllerDelegate {
  
  var detailViewController: DetailViewController? = nil
  var gists = [Gist]()
  var nextPageURLString: String?
  var isLoading = false
  var dateFormatter = DateFormatter()
  var safariViewController: SFSafariViewController?
  
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

    // add refresh control for pull to refresh
    if (self.refreshControl == nil) {
      self.refreshControl = UIRefreshControl()
      self.refreshControl?.addTarget(self,
                                     action: #selector(refresh(sender:)),
                                     for: .valueChanged)
      self.dateFormatter.dateStyle = .short
      self.dateFormatter.timeStyle = .long
    }

    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (!GitHubAPIManager.shared.isLoadingOAuthToken) {
      loadInitialData()
    }
  }

  func loadInitialData() {
    isLoading = true
    GitHubAPIManager.shared.OAuthTokenCompletionHandler = { error in
      guard error == nil else {
        print(error!)
        self.isLoading = false
        // TODO: handle error
        // Something went wrong, try again
        self.showOAuthLoginView()
        return
      }
      if let _ = self.safariViewController {
        self.dismiss(animated: false) {}
      }
      self.loadGists(urlToLoad: nil)
    }
    if (!GitHubAPIManager.shared.hasOAuthToken()) {
      showOAuthLoginView()
      return
    }
    loadGists(urlToLoad: nil)
  }

  func showOAuthLoginView() {
    GitHubAPIManager.shared.isLoadingOAuthToken = true
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    guard let loginVC = storyboard.instantiateViewController(
      withIdentifier: "LoginViewController") as? LoginViewController else {
        assert(false, "Misnamed view controller")
        return
    }
    loginVC.delegate = self
    self.present(loginVC, animated: true, completion: nil)
  }

  func didTapLoginButton() {
    self.dismiss(animated: false) {
      guard let authURL = GitHubAPIManager.shared.URLToStartOAuth2Login() else {
        let error = BackendError.authCouldNot(reason:
          "Could not obtain an OAuth token")
        GitHubAPIManager.shared.OAuthTokenCompletionHandler?(error)
        return
      }
      self.safariViewController = SFSafariViewController(url: authURL)
      self.safariViewController?.delegate = self
      guard let webViewController = self.safariViewController else {
        return
      }
      self.present(webViewController, animated: true, completion: nil)
    }
  }

  // MARK: - Safari View Controller Delegate
  func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad
    didLoadSuccessfully: Bool) {
    // Detect not being able to load the OAuth URL
    if (!didLoadSuccessfully) {
      controller.dismiss(animated: true, completion: nil)
    }
  }
  
  func loadGists(urlToLoad: String?) {
    self.isLoading = true
    GitHubAPIManager.shared.fetchMyStarredGists(pageToLoad: urlToLoad) {
      (result, nextPage) in
      self.isLoading = false
      self.nextPageURLString = nextPage

      // tell refresh control it can stop showing up now
      if self.refreshControl != nil,
        self.refreshControl!.isRefreshing {
        self.refreshControl?.endRefreshing()
      }

      guard result.error == nil else {
        self.handleLoadGistsError(result.error!)
        return
      }

      if let fetchedGists = result.value {
        if urlToLoad == nil {
          // empty out the gists because we're not loading another page
          self.gists = []
        }

        self.gists += fetchedGists
      }

      // update "last updated" title for refresh control
      let now = Date()
      let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
      self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)

      self.tableView.reloadData()
    }
  }
  
  func handleLoadGistsError(_ error: Error) {
    print(error)
    nextPageURLString = nil
    isLoading = false

    switch error {
    case BackendError.authLost:
      self.showOAuthLoginView()
      return
    default:
      break
    }
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
    
    // set cell.imageView to display image at gist.owner?.avatarURL
    if let url = gist.owner?.avatarURL {
      cell.imageView?.pin_setImage(from: url, placeholderImage:
      UIImage(named: "placeholder.png")) {
        result in
        if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) {
          cellToUpdate.setNeedsLayout()
        }
      }
    } else {
      cell.imageView?.image = UIImage(named: "placeholder.png")
    }

    if !isLoading {
      let rowsLoaded = gists.count
      let rowsRemaining = rowsLoaded - indexPath.row
      let rowsToLoadFromBottom = 5

      if rowsRemaining <= rowsToLoadFromBottom {
        if let nextPage = nextPageURLString {
          self.loadGists(urlToLoad: nextPage)
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

  // MARK: - Pull to Refresh
  @objc func refresh(sender: Any) {
    GitHubAPIManager.shared.isLoadingOAuthToken = false
    nextPageURLString = nil // so it doesn't try to append the results
    GitHubAPIManager.shared.clearCache()
    loadInitialData()
  }
}
