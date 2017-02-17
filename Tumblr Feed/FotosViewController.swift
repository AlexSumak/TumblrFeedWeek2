//
//  FotosViewController.swift
//  Tumblr Feed
//
//  Created by  Alex Sumak on 2/2/17.
//  Copyright © 2017  Alex Sumak. All rights reserved.
//

import AFNetworking
import UIKit
class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
class FotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var posts: [NSDictionary] = []
    
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240;
        // Do any additional setup after loading the view.
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                         self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData()
                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fotoCell", for: indexPath as IndexPath) as! fotoCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "fotoCell") as! fotoCell
        
        // Configure YourCustomCell using the outlets that you've defined.
        let post = posts[indexPath.row]
        //let timestamp = post["timestamp"] as? String
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.foto.setImageWith(imageUrl)
                
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    func loadMoreData() {
        
       let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
         let request = URLRequest(url: url!)
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request , completionHandler: { (data, response, error) in
                                                                        
                                                                        // Update flag
                                                                        self.isMoreDataLoading = false
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {
                    print("responseDictionary: \(responseDictionary)")
                    
                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                    self.tableView.reloadData()
                    // This is where you will store the returned array of posts in your posts property
                   self.posts += responseFieldDictionary["posts"] as! [NSDictionary]
                }
            }
            
            
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to st
            self.tableView.reloadData()
        });
        task.resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        //let cell = tableView(self.tableView, cellForRowAt: indexPath!) as! fotoCell
        
        let post = posts[(indexPath?.row)!]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                //cell.foto.setImageWith(imageUrl)
                vc.imageUrl = imageUrl
            }
        }
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
       
            
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {
                    print("responseDictionary: \(responseDictionary)")
                    
                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                    self.tableView.reloadData()
                    // This is where you will store the returned array of posts in your posts property
                    // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                }
            }

   
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
