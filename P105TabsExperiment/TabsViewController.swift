//
//  TabTableViewController.swift
//  P105TabsExperiment
//
//  Created by Stefan Arentz (Mozilla) on 2014-10-20.
//  Copyright (c) 2014 Stefan Arentz. All rights reserved.
//

import UIKit
import Alamofire

class Tab
{
    var title: String
    var url: String
    
    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

class TabClient
{
    var name: String
    var tabs: [Tab] = []
    
    init(name: String) {
        self.name = name
    }
}

class TabsResponse: NSObject
{
    var clients: [TabClient] = []
}

func parseTabsResponse(response: AnyObject?) -> TabsResponse {
    let tabsResponse = TabsResponse()
    
    if let response: NSArray = response as? NSArray {
        for client in response {
            let tabClient = TabClient(name: client.valueForKey("clientName") as String)
            if let tabs = client.valueForKey("tabs") as? NSArray {
                for tab in tabs {
                    var title = ""
                    var url = ""
                    if let t = tab.valueForKey("title") as? String {
                        title = t
                    }
                    if let u = tab.valueForKey("urlHistory") as? NSArray {
                        if u.count > 0 {
                            url = u[0] as String
                        }
                    }
                    tabClient.tabs.append(Tab(title: title, url: url))
                }
            }
            
            tabsResponse.clients.append(tabClient)
        }
    }
    
    return tabsResponse
}

func createMockFavicon(icon: UIImage) -> UIImage {
    let size = CGSize(width: 30, height: 30)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    var context = UIGraphicsGetCurrentContext()
    icon.drawInRect(CGRectInset(CGRect(origin: CGPointZero, size: size), 1.0, 1.0))
    CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeEllipseInRect(context, CGRectInset(CGRect(origin: CGPointZero, size: size), 1.0, 1.0))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

class TabsViewController: UITableViewController
{
    var tabsResponse: TabsResponse?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        Alamofire.request(.GET, "https://syncapi-dev.sateh.com/1.0/tabs")
            .authenticate(user: "sarentz+syncapi@mozilla.com", password: "q1w2e3r4")
            .responseJSON { (request, response, data, error) in
                self.tabsResponse = parseTabsResponse(data)
                self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let r = tabsResponse {
            return r.clients.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let r = tabsResponse {
            return r.clients[section].tabs.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        if let image = (UIImage(named: "leaf.png")) {
            cell.imageView.image = createMockFavicon(image)
        }
        
        let tab = tabsResponse?.clients[indexPath.section].tabs[indexPath.row]
        
        cell.textLabel.text = tab?.title
        cell.textLabel.font = UIFont(name: "FiraSans-Light", size: cell.textLabel.font.pointSize)
        cell.textLabel.textColor = UIColor.grayColor()
        cell.indentationWidth = 20
        return cell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let objects = UINib(nibName: "TabsViewControllerHeader", bundle: nil).instantiateWithOwner(nil, options: nil)
        let view = objects[0] as? UIView

        if let label = view?.viewWithTag(1) as? UILabel {
            if let response = tabsResponse {
                let client = response.clients[section]
                label.text = client.name
            }
        }
        
        return view
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let objects = UINib(nibName: "TabsViewControllerHeader", bundle: nil).instantiateWithOwner(nil, options: nil)
        if let view = objects[0] as? UIView {
            if let label = view.viewWithTag(1) as? UILabel {
                // TODO: More button
            }
        }
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let tab = tabsResponse?.clients[indexPath.section].tabs[indexPath.row] {
            UIApplication.sharedApplication().openURL(NSURL(string: tab.url)!)
        }
    }
}
