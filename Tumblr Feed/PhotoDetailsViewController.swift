//
//  PhotoDetailsViewController.swift
//  Tumblr Feed
//
//  Created by  Alex Sumak on 2/9/17.
//  Copyright © 2017  Alex Sumak. All rights reserved.
//

import UIKit
import AFNetworking
class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var detailsImageView: UIImageView!
    var imageUrl: URL? 
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsImageView.setImageWith(imageUrl! as URL)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
