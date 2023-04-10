//
//  PostsListViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 14/07/22.
//

import Foundation
import UIKit
import DashX

class PostsListViewController: UIViewController {
    static let identifier = "PostsListViewController"
    
    // MARK: Outlets
    @IBOutlet weak var fetchPostsErrorLabel: UILabel! {
        didSet {
            hideFetchPostsError()
        }
    }
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noPostsPlaceholderView: UIView!
    @IBOutlet weak var addPostInputPlaceholderView: UIView!
    @IBOutlet weak var postInputBackgroundView: UIView! {
        didSet {
            postInputBackgroundView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.delegate = self
            messageTextView.layer.cornerRadius = 6
            messageTextView.layer.borderWidth = 1
            showPlaceholderTextForMessageTextView()
        }
    }
    @IBOutlet weak var addPostErrorLabel: UILabel! {
        didSet {
            hideAddPostError()
        }
    }
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.layer.borderWidth = 2
            postButton.layer.cornerRadius = 6
            postButton.layer.borderColor = UIColor.systemBlue.cgColor
            postButton.backgroundColor = UIColor.systemBlue
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.borderWidth = 2
            cancelButton.layer.cornerRadius = 6
            cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    typealias Post = PostsListItemTableViewCell.Post
    private var posts: [Post] = []
    private var isLoadingForTheFirstTime = true
    private var isPostsLoading = false {
        didSet {
            if isPostsLoading && isLoadingForTheFirstTime {
                self.isLoadingForTheFirstTime = false
                self.showProgressView()
            } else {
                self.hideProgressView()
            }
        }
    }
    private var isAddPostLoading = false
    private var isAddPostScreenVisible = false
    private var rightBarButton: UIBarButtonItem!
    private var isMessageTextViewNotEdited: Bool {
        (messageTextView.textColor == UIColor.white.withAlphaComponent(0.3)) || (messageTextView.textColor == UIColor.black.withAlphaComponent(0.3))
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpRightBarButton()
        setUpTableView()
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewsForUserInterfaceStyle()
        fetchPosts()
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewsForUserInterfaceStyle()
    }
    
    func updateViewsForUserInterfaceStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            messageTextView.layer.borderColor = UIColor.white.cgColor
            messageTextView.textColor = .white
            addPostInputPlaceholderView.backgroundColor = .white.withAlphaComponent(0.3)
        } else {
            messageTextView.layer.borderColor = UIColor.black.cgColor
            messageTextView.textColor = .black
            addPostInputPlaceholderView.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    // MARK: Actions
    @IBAction func onClickCancel(_ sender: UIButton) {
        messageTextView.resignFirstResponder()
        dismissAndClearAddPostView()
    }
    
    @IBAction func onClickPost(_ sender: UIButton) {
        messageTextView.resignFirstResponder()
        addPost()
    }
    
    @objc
    func rightBarButtonTapped() {
        if isAddPostScreenVisible {
            dismissAndClearAddPostView()
        } else {
            presentAndSetUpAddPostView()
        }
    }
    
    func setUpRightBarButton() {
        rightBarButton = UIBarButtonItem(title: "Add Post", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.tintColor = .systemBlue
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setUpTableView() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.register(PostsListItemTableViewCell.nib, forCellReuseIdentifier: PostsListItemTableViewCell.identifier)
    }
    
    func fetchPosts() {
        isPostsLoading = true
        postsTableView.reloadData()
        
        APIClient.getPosts { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.posts = data?.posts.map { Post(id: $0.id, userName: $0.user.name, createdDate: $0.createdAt.postedDate(), message: $0.text, isBookmarked: $0.isBookmarked) } ?? []
                self.noPostsPlaceholderView.isHidden = (self.posts.isEmpty ? false : true)
                self.hideFetchPostsError()
                self.postsTableView.reloadData()
            }
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.postsTableView.reloadData()
                self.noPostsPlaceholderView.isHidden = true
                self.showFetchPostsError(networkError.message)
            }
        }
    }
    
    func addPost() {
        isAddPostLoading = true
        postButton.titleLabel?.text = "Posting"
        messageTextView.isEditable = false
        
        APIClient.addPost(text: messageTextView.text) { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.postButton.titleLabel?.text = "Posted"
                self.messageTextView.isEditable = true
                self.isAddPostLoading = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.dismissAndClearAddPostView()
                }
                self.fetchPosts()
            }
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.postButton.titleLabel?.text = "Post"
                self.messageTextView.isEditable = true
                self.isAddPostLoading = false
                self.showAddPostError(networkError.message)
            }
        }
    }
    
    func setBookmark(forPostWith index: Int) {
        posts[index].isBookmarked.toggle()
        postsTableView.reloadData()
        APIClient.toggleBookmark(postId: posts[index].id) { _ in
            DashX.track(self.posts[index].isBookmarked ? "Post Bookmarked-iOS": "post Unbookmarked-iOS")
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.posts[index].isBookmarked.toggle()
                self.postsTableView.reloadData()
            }
        }
    }
    
    func dismissAndClearAddPostView() {
        addPostInputPlaceholderView.isHidden = true
        isAddPostScreenVisible = false
        showPlaceholderTextForMessageTextView()
        rightBarButton.title = "Add Post"
    }
    
    func presentAndSetUpAddPostView() {
        addPostInputPlaceholderView.isHidden = false
        isAddPostScreenVisible = true
        showPlaceholderTextForMessageTextView()
        rightBarButton.title = "Cancel"
        
        messageTextView.isEditable = true
        messageTextView.becomeFirstResponder()
        addPostErrorLabel.text = ""
        addPostErrorLabel.isHidden = true
        postButton.titleLabel?.text = "Post"
        postButton.isEnabled = false
    }
    
    func validatePostMessageTextView() {
        if messageTextView.text.isEmpty {
            postButton.isEnabled = false
            showAddPostError("Text is required!")
        } else {
            postButton.isEnabled = true
            hideAddPostError()
        }
    }
    
    func hideFetchPostsError() {
        fetchPostsErrorLabel.text = ""
        fetchPostsErrorLabel.isHidden = true
    }
    
    func showFetchPostsError(_ description: String?) {
        fetchPostsErrorLabel.text = description ?? "Something went wrong!"
        fetchPostsErrorLabel.isHidden = false
    }
    
    func hideAddPostError() {
        addPostErrorLabel.text = ""
        addPostErrorLabel.isHidden = true
    }
    
    func showAddPostError(_ description: String?) {
        addPostErrorLabel.text = description ?? "Something went wrong!"
        addPostErrorLabel.isHidden = false
    }
    
    func showPlaceholderTextForMessageTextView() {
        messageTextView.text = "Start typing"
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
    }
    
    func removePlaceholderTextForMessageTextView() {
        if isMessageTextViewNotEdited {
            messageTextView.text = ""
        }
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white : UIColor.black
    }
}

extension PostsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostsListItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostsListItemTableViewCell.identifier, for: indexPath) as! PostsListItemTableViewCell
        let rowData = posts[indexPath.row]
        cell.setUpData(post: rowData)
        cell.onClickBookmarkAction = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setBookmark(forPostWith: indexPath.row)
            }
        }
        return cell
    }
}

extension PostsListViewController: UITableViewDelegate { }

extension PostsListViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == messageTextView else { return true }
        DispatchQueue.main.async {
            self.removePlaceholderTextForMessageTextView()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == messageTextView else { return }
        DispatchQueue.main.async {
            self.validatePostMessageTextView()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == messageTextView else { return }
        DispatchQueue.main.async {
            self.validatePostMessageTextView()
        }
    }
}
