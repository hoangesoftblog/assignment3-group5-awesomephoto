//
//  MainHomeViewController.swift
//  AwesomePhoto
//
//  Created by Chau Phuoc Tuong on 4/21/19.
//  Copyright © 2019 Chau Phuoc Tuong. All rights reserved.
//

import UIKit
import Firebase

let ref: DatabaseReference = Database.database().reference()

class MainHomeViewController: UIViewController {
    var imageNames: [String] = []
    var imagePhoto: [Int: UIImage] = [:]
    var numberOfColumns: CGFloat = 2
    
    private let reuseIdentifier = "Cell"
    
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataOnce()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 23))
        imageView.image = #imageLiteral(resourceName: "AwesomePhotos-Logo")
        navigationItem.titleView = imageView
        // Do any additional setup after loading the view.
        
    }
    
    //get data of all images from firebase
    func getDataOnce(){
        // Listen for new comments in the Firebase database
        ref.child("publicPicture").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            print(snapshot.value)
            
            for i in snapshot.children {
                if let i2 = (i as? DataSnapshot)?.value as? String {
                    self.imageNames.append(i2)
                }
            }
            
            self.imageCollection.reloadData()
            
            for i in 0..<self.imageNames.count {
                storageRef.child(self.imageNames[i]).getData(maxSize: INT64_MAX){ data, error in
                    print(self.imageNames[i], separator: "", terminator: " ")
                    if error != nil {
                        print("Error occurs")
                    }
                    else if data != nil {
                        if let imageTemp = UIImage(data: data!) {
                            print("image available")
                            self.imagePhoto[i] = imageTemp
                        }
                    }
                    else {
                        print("Data nil")
                    }
                    
                    self.imageCollection.reloadData()
                }
            }
            
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MainHomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(imagePhoto.count) picture")
        return imagePhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let photoViewCell = cell as? PhotoViewCell {
            if indexPath.row < imagePhoto.count{
                photoViewCell.imageView.image = imagePhoto[indexPath.row]
                return photoViewCell
            }
        }
        
        // Configure the cell
        return cell
    }
}

