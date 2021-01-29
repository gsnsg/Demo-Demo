//
//  ViewController.swift
//  Demo Demo
//
//  Created by Sai Nikhit Gulla on 29/01/21.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    //MARK:- Images Properties
    private let apiURL: String = "https://picsum.photos/v2/list?page=2&limit=100"
    private var images: [ImageModel] = []

    //MARK:- Collection View Properties
    private let spacing: CGFloat = 16
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupCollectionView()
        self.fetchImages()
    }
    
    
    func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.frame = view.frame
        self.collectionView.backgroundColor = .lightGray
        view.addSubview(collectionView)
    }


}


extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.images.count)
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.setupCell(imageURL: images[indexPath.row].download_url)
//        cell.backgroundColor = .red
        return cell
    }
    
    // Reference:- https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
        
    }
    
    
    
}


//MARK:- Image Data Model
struct ImageModel: Identifiable, Decodable {
    var id: String
    var download_url: String
}

//MARK:- Image Fetching Functions

extension ViewController {
    func fetchImages() {
        URLSession.shared.dataTask(with: URL(string: apiURL)!) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print(error!.localizedDescription)
                return
            }
            do {
                let images = try JSONDecoder().decode([ImageModel].self, from: data)
                self?.images = images
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
        .resume()
    }
}


//MARK:- Custom Collection View Cell

class CustomCell: UICollectionViewCell {
    
    
    var bg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.addSubview(bg)
        
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupCell(imageURL: String) {
        bg.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(systemName: "icloud.slash"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
