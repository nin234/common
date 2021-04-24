//
//  EasyViewController.swift
//  common
//
//  Created by Ninan Thomas on 6/1/19.
//  Copyright © 2019 nshare. All rights reserved.
//

import Foundation
import UIKit

enum eActionSheet : Int {
    case eActnShetMainScreen
    case eActnShetInAppPurchse
}

struct APPIDS {
    
    static let EASYGROCLIST_ID = 2
    static let SMARTMSG_ID = 3
    static let NSHARELIST_ID = 4
}

@objc public protocol EasyViewControllerDelegate: NSObjectProtocol {
   @objc func shareContactsSetSelected()
    @objc func getAlexaUserId(_ code: String)
    @objc func runAlexaQuery()
}



@objc public class EasyViewController: UIViewController, UISearchBarDelegate, UIActionSheetDelegate {
    var eAction: eActionSheet!
    
    @objc public var pAllItms: EasyListViewController?
    var pSearchBar: UISearchBar?
    @objc public var bShareView = false
    
    @objc public var bShowAlexaBtn = true
    
    @objc public func getAlexaItems()
    {
        delegate?.runAlexaQuery();
    }
    
    func mainScreenActions(_ buttonIndex: Int) {
    }
    
   @objc public weak var delegate: EasyViewControllerDelegate?
    
 override   init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  Converted to Swift 5 by Swiftify v5.0.23302 - https://objectivec2swift.com/
    override  public func loadView() {
        super.loadView()
        let mainScrn: CGRect = UIScreen.main.applicationFrame
        if !bShareView {
            var viewRect: CGRect
            viewRect = CGRect(x: 0, y: mainScrn.origin.y + (navigationController?.navigationBar.frame.size.height ?? 0.0), width: mainScrn.size.width, height: 50)
            pSearchBar = UISearchBar(frame: viewRect)
            pSearchBar?.delegate = self
            view.addSubview(pSearchBar!)
        }
        pAllItms = EasyListViewController(nibName: nil, bundle: nil)
        
        pAllItms!.bShareView = bShareView
        var yoffset: CGFloat
        if bShareView {
            yoffset = 0
        } else {
            yoffset = 50
        }
        let tableRect = CGRect(x: 0, y: mainScrn.origin.y + (navigationController?.navigationBar.frame.size.height ?? 0.0) + yoffset, width: mainScrn.size.width, height: mainScrn.size.height - (navigationController?.navigationBar.frame.size.height ?? 0.0))
        let pTVw = UITableView(frame: tableRect, style: .plain)
        pAllItms!.tableView = pTVw
        pAllItms?.tableView.reloadData()
        view.addSubview(pAllItms!.tableView)
        
    }
    
    @objc func enableCancelButton(_ aSearchBar: UISearchBar?) {
        for subview in aSearchBar?.subviews ?? [] {
            if (subview is UIButton) {
                subview.isUserInteractionEnabled = true
            }
        }
    }

    //  Converted to Swift 5 by Swiftify v5.0.23302 - https://objectivec2swift.com/
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
        //execute a new fetch statement
        //repopulate the table
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // printf("Finished editing search bar %s %d\n", __FILE__, __LINE__);
        
        // [searchBar resignFirstResponder];
        perform(#selector(self.enableCancelButton(_:)), with: searchBar, afterDelay: 0.0)
    }
    
    public func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("Clicked results list button\n")
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //printf("Clicked search button\n");
        print("Search button clicked in MainView Initiating new search with \(searchBar.text ?? "")\n")
        
        pAllItms!.filter(searchBar.text)
        //pDlg.dataSync.refreshNow = true;
        searchBar.resignFirstResponder()
        
    }

    //  Converted to Swift 5 by Swiftify v5.0.23302 - https://objectivec2swift.com/
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Started editing search bar \(#file) \(#line)\n")
        
        searchBar.showsCancelButton = true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        //  pDlg.dataSync.refreshNow = true;
        pAllItms!.removeFilter()
        searchBar.resignFirstResponder()
    }
    
    @objc func itemAdd() {
        let pAppCmnUtil = AppCmnUtil.sharedInstance()
        let pMainVwCntrl = pAppCmnUtil?.navViewController.viewControllers[0] as? EasyViewController
        
        
        pMainVwCntrl?.pSearchBar!.text = nil
        pMainVwCntrl?.pSearchBar!.resignFirstResponder()
        let aViewController = EasyAddViewController(nibName: nil, bundle: nil)
        pAppCmnUtil?.navViewController.pushViewController(aViewController, animated: true)
        return
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let title = "List"
        navigationItem.title = title
        if bShareView {
            
            let pBarItem = UIBarButtonItem(title: "Recipients", style: .plain, target: self, action: #selector(self.shareContactsAdd))
            navigationItem.rightBarButtonItem = pBarItem
            return
        }
        
        let pBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.itemAdd))
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)

        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(self.showHelpScreen), for: .touchUpInside)

        // Create a bar button item using the info button as its custom view
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)

        // Use it as required
        
        let imageHelp = UIImage(named: "ic_help_outline_18pt_2x")
        let pHelpBtn = UIBarButtonItem(image: imageHelp, style: .plain, target: self, action: #selector(self.showHelpScreen))
        let imageAlexa = UIImage(named: "alexa_button")
        let pAlexaBtn = UIBarButtonItem(image: imageAlexa, style: .plain, target: self, action: #selector(showAlexaDialog))
        
        //NSArray *barItems = [NSArray arrayWithObjects:pBarItem,pHelpBtn,nil];
        navigationItem.rightBarButtonItem = pBarItem
        if bShowAlexaBtn
        {
            navigationItem.leftBarButtonItems = [infoBarButtonItem, pAlexaBtn]
        }
        else
        {
            navigationItem.leftBarButtonItem = infoBarButtonItem
        }
      //  navigationItem.leftBarButtonItem = pHelpBtn
        
        
    }
    
    
    override public func didReceiveMemoryWarning()
    {
      super.didReceiveMemoryWarning();
    // Dispose of any resources that can be recreated.
    }

    @objc func shareContactsAdd()
    {
        if (pAllItms?.itemSelected == false)
        {
             let alertController = UIAlertController(title: "Select List", message:"Select a List to share with the Recipients", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                
                print ("You have pressed OK");
               
            }
            
            alertController.addAction(ok)
           
            self.present(alertController, animated: true)
            return;
        }
        delegate?.shareContactsSetSelected();
    return;
    }
    
   @objc func showAlexaDialog()
    {
         let alertController = UIAlertController(title: "Alexa code", message:"Enter the Alexa numerical code to link the App and Alexa skill", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Code"
        }
        
        let ok = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            
            print ("Alexa code=" ,alertController.textFields![0].text ?? "no code")
            self.delegate?.getAlexaUserId(alertController.textFields![0].text ?? "no code")
        }
        
        let cxl = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }
        
        alertController.addAction(ok)
        alertController.addAction(cxl)
        self.present(alertController, animated: true)
    }
    
    @objc func showHelpScreen() {
        print("Showing help screen")
        let notesViewController = NotesViewController(nibName: "NotesViewController", bundle: nil)
        print("Pushing Notes view controller \(#file) \(#line)\n")
        //  albumContentsViewController.assetsGroup = group_;
        notesViewController.notes.isEditable = false
        notesViewController.mode = eNotesModeDisplay
        notesViewController.notes.isSelectable = false
        
        notesViewController.title = "How to use"
        
        let pAppCmnUtil = AppCmnUtil.sharedInstance()
    if let appId = pAppCmnUtil?.appId
    {
        if appId == APPIDS.EASYGROCLIST_ID
        {
        notesViewController.notes.text = "Create Planner lists. Click planner icon in the bottom tab bar to go to the Planner section of the App.\n\nCreate a new planner by clicking the + button on the top right hand corner. Enter the name of the store in the text box. Planners can be created for multiple stores.\n\nTo add items to planner, select the newly created planner item on the screen.\nThe planner list of a store is made up of three different sections (One-time, Replenish and Always). To switch between the sections click the buttons on the top navigation bar. Click the Edit button on top right corner to make changes to planner list and click the Save button to save the changes\n\nReplenish list keeps track of items that needs to be bought when they run out. The switch in the off position (red color) indicates that particular item has run out. When a list is created from the Home screen this item will be added to the list.\nAlways list are the items that are needed on every store visit. \n\nOne-time items are infrequently needed items. The items in this list are used the next time a new list is created from the Home screen. The items in the list are deleted after a new list is created and cannot be used again.\n\n After creating planner lists click the + button on the top right corner of the Home screen. Create a new list by selecting the appropriate Planner list. A new list created  from the planner list will merge items from these 3 components (Always, Replenish and One-time).\n\nClicking the brand new list on this screen will create an empty blank list. This can be used for one time lists.\n\n Alexa Integration. EasyGrocList iPhone App is integrated with EasyGrocList Alexa skill. Enable EasyGrocList Alexa skill. Refer to the skill documentation on how to use the skill. To link the iPhone App and Alexa skill, press the A button on the top left corner and enter the numerical code spoken by Alexa when the skill is invoked the first time. Invoke the Alexa skill again to start adding items. It is important to note that the Alexa added items are downloaded to the iPhone App only at start up. If Alexa added items are not seen in the list restart the App\n\nThe list can be shared with friends. Notifications should be enabled for the app for sharing. Notifications can be enabled during intial start up or later in the Settings app.\n\n The first step to share is to add Contacts to share the list with. Click the Contacts icon in the bottom tab bar to bring up the Contacts screen. There will be a ME line. Selecting the ME line, shows the share Id of the EasyGrocList on this iPhone. This number uniquely identifies the App for sharing purposes. Now navigate back to Contacts screen by clicking the Contacts button on top left corner. Click the + button on top right corner to add a new contact. Enter the share Id and a name to identify the contact.The Share Id is the number in the ME row of your friend's EasyGrocList app. \n\nClick the Share icon in the bottom tab bar. This will bring up the Share screen. Select the List to share and click the Recipients icon on the top right corner. This will bring up the Contacts screen. Select the contacts to share the item. Once the contacts are selected click the Send button. This will sent the list to the selected Contacts"
        }
        else if appId == APPIDS.NSHARELIST_ID
        {
            notesViewController.notes.text = "Create Template lists. Click Templates icon in the bottom tab bar to go to the Template lists section of the App.\n\nCreate a new Template list by clicking the + button on the top right hand corner. Enter the name of the list in the text box. Template lists can be created for multiple categories. Some examples are Template list for items to be packed for a trip, tasks to be accomplished daily, tasks to be assigned to spouse or partner.\n\nTo add items to template list, select the newly created template item on the screen.\nAdd items to the list. Click the Edit button on top right corner to make changes to template list and click the Save button to save the changes\n\nThe switch in the off position (red color) indicates that particular item has to be excluded next time a list is created from the template list.\n\n After creating Template lists click the + button on the top right corner of the Home screen. Create a new list by selecting the appropriate Template list. A new list created  from the Template list excluding items in the Template list that have switch in the off position (red color). After the list is created all the items in the Template list revert back to switch in the On position (green color). The newly created list will have all the items in the off position (switch red color). Once a check list task or item is accomplished the switch can be changed to the On position (green color).\n\nClicking the brand new list on this screen will create an empty blank list. This can be used for one time lists or tasks.\n\nThe check list can be shared with friends. Notifications should be enabled for the app for sharing. Notifications can be enabled during intial start up or later in the Settings app.\n\n The first step to share is to add Contacts to share the list with. Click the Contacts icon in the bottom tab bar to bring up the Contacts screen. There will be a ME line. Selecting the ME line, shows the share Id of the nsharelist on this iPhone. This number uniquely identifies the App for sharing purposes. Now navigate back to Contacts screen by clicking the Contacts button on top left corner. Click the + button on top right corner to add a new contact. Enter the share Id and a name to identify the contact.The Share Id is the number in the ME row of your friend's nsharelist app. \n\nClick the Share icon in the bottom tab bar. This will bring up the Share screen. Select the List to share and click the Recipients icon on the top right corner. This will bring up the Contacts screen. Select the contacts to share the item. Once the contacts are selected click the Send button. This will sent the list to the selected Contacts"
        }
        
         }
       
        notesViewController.notes.font = UIFont(name: "ArialMT", size: 20)
        navigationController?.pushViewController(notesViewController, animated: false)
    }

}




