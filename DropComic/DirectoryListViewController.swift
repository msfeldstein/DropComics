//
//  DirectoryListViewController.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox

class DirectoryListViewController: UITableViewController {
    var files = [Files.Metadata]()
    var path = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.path != "" ? self.path : "Dropbox"
        if let client = DropboxClientsManager.authorizedClient {
          client.files.listFolder(path: self.path).response(queue: DispatchQueue(label: "MyCustomSerialQueue")) { response, error in
            if let result = response {
              print(result)
              self.files = result.entries
              DispatchQueue.main.async {
                self.tableView.reloadData()
              }
            }
          }
        }
      
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return files.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "directoryCell", for: indexPath) as? FileEntryCell else {
        fatalError()
      }
      cell.file = files[indexPath.row]
      return cell
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let metadata = files[indexPath.row]
      if let fileMetadata = metadata as? Files.FileMetadata {
        let viewerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "readerView") as! ComicReaderViewController
        viewerController.comicMetadata = fileMetadata
        self.navigationController?.pushViewController(viewerController, animated: true)
      } else if let directoryMetadata = metadata as? Files.FolderMetadata {
        let sublistController : DirectoryListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "directoryList") as! DirectoryListViewController
        sublistController.path = directoryMetadata.pathLower!
        self.navigationController?.pushViewController(sublistController, animated: true)
      }
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.hidesBarsOnTap = false
  }
}
