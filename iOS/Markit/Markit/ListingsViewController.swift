//
//  ListingsTableViewController.swift
//  Markit
//
//  Created by Victor Frolov on 9/10/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit
import Firebase
import FontAwesome_swift

class ListingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var listingsTableView: UITableView!

    var ref:            FIRDatabaseReference!
    var itemsRef:       FIRDatabaseReference!
    var itemsByHubRef:  FIRDatabaseReference!
    var itemsByUserRef: FIRDatabaseReference!
    var userRef:        FIRDatabaseReference!
    var itemImageRef:   FIRStorageReference!
    var itemList      = [Item]()
    
    // These are for searching the list of items
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItems = [Item]()
    var didReceiveAdvancedSearchQuery: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listingsTableView.delegate = self
        self.listingsTableView.dataSource = self
        
        self.didReceiveAdvancedSearchQuery = false
        
        setupFirebaseReferences()
        
        fetchItems()
        searchItems()
    }
    
    func dismissSearchBar() {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func sortItemsBy () {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchController.searchBar.text == "" {
            self.searchController.isActive = false
        }
    }
    
    @IBAction func advancedSearchButtonTouched(_ sender: UIBarButtonItem) {
        dismissSearchBar()
    }
    
    func setupFirebaseReferences() {
        self.ref            = FIRDatabase.database().reference()
        self.itemImageRef   = FIRStorage.storage().reference()
        self.itemsRef       = ref.child("items")
        self.itemsByHubRef  = ref.child("itemsByHub")
        self.itemsByUserRef = ref.child("itemsByUser")
        self.userRef        = ref.child("users")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        didReceiveAdvancedSearchQuery = false
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredItems = itemList.filter { item in
            return (item.title!.lowercased().contains(searchText.lowercased()))
        }
        listingsTableView.reloadData()
    }
    
    func searchItems() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by item"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = 100
        
        definesPresentationContext = true
        self.listingsTableView.tableHeaderView = searchController.searchBar
    }
    
    func fetchItems() {
        self.itemsRef!.queryOrdered(byChild: "title")
                      .observe(.childAdded, with: { (snapshot) -> Void in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let item     = Item()
                item.uid     = dictionary["uid"] as! String?
                item.desc    = dictionary["description"] as! String?
                item.title   = dictionary["title"] as! String?
                item.date    = dictionary["date"] as! String?
                item.imageID = dictionary["id"] as! String?
                item.price   = dictionary["price"] as! String?
                item.tags    = dictionary["tags"] as? Array as [String]?
                item.hubs     = dictionary["hubs"] as? Array as [String]?
                    
                if let favorites = dictionary["favorites"] as? Array as [String]? {
                    item.favorites = favorites
                } else {
                    item.favorites = [""]
                }
                
                // There's some problems with the users again :(
                if let uid = dictionary["uid"] as! String? {
                    self.userRef.child(uid)
                                .child("username")
                                .observe(.value, with: { (snapshot) in
                        item.username = snapshot.value as? String ?? ""
                    })
                }
                
                self.getImage(imageID: item.imageID!, item: item)

                self.itemList.append(item)
            }
                        
            self.listingsTableView.reloadData()
        })
        
    }
    
    func getImage (imageID: String, item: Item) {
        self.itemImageRef!.child("images/itemImages/\(imageID)/imageOne").data(withMaxSize: 1 * 2048 * 2048) { (data, error) in
            if (error != nil) {
                print("Image download failed: \(error?.localizedDescription)")
                return
            }

            item.image = UIImage(data: data!)
            self.listingsTableView.reloadData()
            return
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        listingsTableView.reloadData()
    }
    
    @IBAction func cancelAdvancedSearch (segue: UIStoryboardSegue) {}
    
    @IBAction func unwindSearchButton (segue: UIStoryboardSegue) {
        self.didReceiveAdvancedSearchQuery = true
        self.filteredItems = [Item]()

        let advancedSearchVC = segue.source as! ListingsAdvancedSearchViewController
        let minPrice         = advancedSearchVC.advancedSearchContainerView.minPrice.text
        let maxPrice         = advancedSearchVC.advancedSearchContainerView.maxPrice.text
        let hubsQuery        = advancedSearchVC.advancedSearchContainerView.hubs.text
        let keywords         = advancedSearchVC.advancedSearchContainerView.keywords.text
        let tagsQuery        = advancedSearchVC.advancedSearchContainerView.tags.text
        
        self.filteredItems = itemList.filter { item in
            
            let tagList          = tagsQuery?.components(separatedBy: ", ")
            let hubList          = hubsQuery?.components(separatedBy: ", ")
            let minPriceQuery    = NumberFormatter().number(from: minPrice!)?.floatValue
            let maxPriceQuery    = NumberFormatter().number(from: maxPrice!)?.floatValue
            let itemPriceFloat   = NumberFormatter().number(from: item.price!)?.floatValue
            let withinPriceRange = itemPriceFloat! <= maxPriceQuery! && itemPriceFloat! >= minPriceQuery!

            if (hubsQuery?.characters.count)! > 0
                    && !hasTag(tagsIn: item, query: hubList!) { return false }
            
            if (tagsQuery?.characters.count)! > 0
                    && !hasTag(tagsIn: item, query: tagList!) { return false }
            
            if (keywords?.characters.count)! > 0 && !(item.title?.lowercased().contains(keywords!.lowercased()))! && !(item.desc?.lowercased().contains(keywords!.lowercased()))! { return false }
            
            if !withinPriceRange { return false }
            
            return true
        }
    }
    
    func hasTag(tagsIn item: Item, query: [String]) -> Bool {
        for q in query {
            if (item.tags?.contains(q.lowercased()))! {
                return true
            }
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listingsTableView.deselectRow(at: indexPath, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.didReceiveAdvancedSearchQuery! || self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.filteredItems.count
        }
        return self.itemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! ListingsTableViewCell
        let item: Item
        
        if self.didReceiveAdvancedSearchQuery! || self.searchController.isActive && self.searchController.searchBar.text != "" {
            item = self.filteredItems[row]
        } else {
            item = itemList[row]
        }
        
        // Configure the cell...
        cell.itemLabel?.text           = item.title
        cell.thumbnailImageView?.image = item.image
        cell.priceLabel?.text          = "$\(item.price!)"
        cell.userLabel?.text           = item.username
        cell.faved.tag                 = row
        
        cell.faved.addTarget(self, action: #selector(faveButtonTouched), for: .touchUpInside)
        
        // Will need to tweak this to change on tap
        let currentUser = CustomFirebaseAuth().getCurrentUser()
        if (item.favorites?.contains(currentUser))! {
            let filledHeart = UIImage.fontAwesomeIcon(name: FontAwesome.heart, textColor: UIColor.gray, size: CGSize(width: 35, height: 35))
            cell.faved?.setImage(filledHeart, for: .normal)
        } else {
            let emptyHeart = UIImage.fontAwesomeIcon(name: FontAwesome.heartO, textColor: UIColor.gray, size: CGSize(width: 35, height: 35))
            cell.faved?.setImage(emptyHeart, for: .normal)
        }
        
        cell.faved.layer.shadowColor = UIColor.white.cgColor
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailedViewSegue" {
            if let indexPath = listingsTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                let detailedVC = segue.destination as! DetailedTableViewController
                
                if self.didReceiveAdvancedSearchQuery! || self.searchController.isActive && self.searchController.searchBar.text != "" {
                    detailedVC.currentItem = filteredItems[selectedRow]
                } else {
                    detailedVC.currentItem = itemList[selectedRow]
                }
            }
        }
    }
    
    @IBAction func faveButtonTouched(_ sender: UIButton) {
        let currentUser = CustomFirebaseAuth().getCurrentUser()
        var itemID      = itemList[sender.tag].imageID
        var hubs        = itemList[sender.tag].hubs
        var sellerID    = itemList[sender.tag].uid
        if self.didReceiveAdvancedSearchQuery! ||
            self.searchController.isActive &&
            self.searchController.searchBar.text != "" {
            
            itemID   = filteredItems[sender.tag].imageID
            hubs     = filteredItems[sender.tag].hubs
            sellerID = filteredItems[sender.tag].uid
        }

        let itemFavoriteRef        = self.itemsRef.child("\(itemID!)/favorites/\(currentUser)")
        let itemsByUserFavoriteRef = self.itemsByUserRef.child("\(sellerID!)/\(itemID!)/favorites/\(currentUser)")
        let userFavoriteRef        = self.userRef.child("\(currentUser)/favorites/\(itemID!)")
        
        itemFavoriteRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if snapshot.exists() {
                itemFavoriteRef.removeValue()
                itemsByUserFavoriteRef.removeValue()
                userFavoriteRef.removeValue()
                
                for hub in hubs! {
                    self.itemsByHubRef.child("\(hub)/\(itemID!)/favorites/\(currentUser)").removeValue()
                }
            } else {
                itemFavoriteRef.setValue(true)
                itemsByUserFavoriteRef.setValue(true)
                userFavoriteRef.setValue(true)
                
                for hub in hubs! {
                    self.itemsByHubRef.child("\(hub)/\(itemID!)/favorites/\(currentUser)").setValue(true)
                }
            }
        })
    }
}
