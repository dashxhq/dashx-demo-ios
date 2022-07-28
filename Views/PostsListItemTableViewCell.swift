//
//  PostsListItemTableViewCell.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 15/07/22.
//

import Foundation
import UIKit

class PostsListItemTableViewCell: UITableViewCell {
    static let identifier = "PostsListItemTableViewCell"
    static let nib = UINib(nibName: PostsListItemTableViewCell.identifier, bundle: nil)
    
    struct Post {
        let id: Int
        let userImage: String?
        let userName: String
        let createdDate: String
        let message: String
        var isBookmarked: Bool
        
        init(id: Int, userImage: String? = nil, userName: String, createdDate: String, message: String, isBookmarked: Bool) {
            self.id = id
            self.userImage = userImage
            self.userName = userName
            self.createdDate = createdDate
            self.message = message
            self.isBookmarked = isBookmarked
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton! {
        didSet {
            bookmarkButton.setTitle("", for: .normal)
        }
    }
    
    var post: Post!
    var onClickBookmarkAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: Actions
    @IBAction func onClickBookmark(_ sender: UIButton) {
        onClickBookmarkAction!()
    }
    
    func setUpData(post: Post) {
        userNameLabel.text = post.userName
        createdDateLabel.text = post.createdDate
        messageLabel.text = post.message
        bookmarkButton.setImage(post.isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
    }
}

