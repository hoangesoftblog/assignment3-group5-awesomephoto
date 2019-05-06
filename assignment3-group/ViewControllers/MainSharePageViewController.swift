//
//  MainSharePageViewController.swift
//  AwesomePhoto
//
//  Created by Chau Phuoc Tuong on 4/21/19.
//  Copyright © 2019 Chau Phuoc Tuong. All rights reserved.
//

import UIKit
import Firebase

class MainSharePageViewController: UIViewController {
    var imageNames: [String] = []
    var imagePhoto: [Int: UIImage] = [:]
    let sectionInsets = UIEdgeInsets(top: 50.0,
                                     left: 20.0,
                                     bottom: 50.0,
                                     right: 20.0)
    var numberOfColumns: CGFloat = 2
    
    @IBOutlet weak var imageCollection: UICollectionView!
    let reuseIdentifier = "Cell"
    let SharedToDetail = "SharedToDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Current username is " + (currentUser ?? "not available"))
        getDataOnce()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 23))
        imageView.image = #imageLiteral(resourceName: "awesome")
        navigationItem.titleView = imageView

        // Do any additional setup after loading the view.
    }

    func getDataOnce(){
        if currentUser != nil {
            ref.child("userPicture/\(currentUser!)/fileSharedWithWatermark").observeSingleEvent(of: .value){ snapshot in
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
                        
                        self.imageCollection.reloadData()
                    }
                }
            }
        }
    }
}

extension MainSharePageViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("number of sections")
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(imagePhoto.count) picture")
        return imagePhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let photoViewCell = cell as? SharedPhotoViewCell {
            if indexPath.row < imagePhoto.count{
                photoViewCell.imageView.image = imagePhoto[indexPath.row]
                return photoViewCell
            }
        }
        
        return cell
    }
}

extension MainSharePageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: SharedToDetail, sender: (imageNames[indexPath.row], imagePhoto[indexPath.row]))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SharedToDetail {
            if let dest = segue.destination as? DetailViewController {
                if let (name, image) = sender as? (String, UIImage) {
                    dest.image = image
                    dest.fileName = name
                }
            }
        }
    }
}

extension MainSharePageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (numberOfColumns + 1)
        let available = view.frame.width - paddingSpace
        let widthPerItem = available / numberOfColumns
        
        print("IndexPath row is \(indexPath.row)")
        print("imagePhoto has \(imagePhoto.count)\n")
        if indexPath.row < imagePhoto.count && imagePhoto[indexPath.row] != nil {
            let photoHeight = (imagePhoto[indexPath.row]?.size.height)!
            let photoWidth = (imagePhoto[indexPath.row]?.size.width)!
            print("\(photoHeight)\t\(photoWidth)")
            
            return CGSize(width: widthPerItem, height: widthPerItem * (photoHeight / photoWidth))
        }
        else {
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


