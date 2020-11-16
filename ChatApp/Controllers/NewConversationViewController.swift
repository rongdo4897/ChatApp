//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/20/20.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    /// - Truyền dữ liệu về màn hình ConversationViewController
    public var completion: (([String: String]) -> (Void))?
    
    /// - Progress spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    /// - Danh sách User trên database
    private var users = [[String: String]]() // all users
    /// - Danh sách User trả về khi tìm kiếm
    private var results = [[String: String]]() // result did when search
    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for Users..."
        return search
    }()
    
    /// - Table hiển thị kết quả tìm kiếm
    private let tableView:UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    /// - label không có kểt quả trả về
    private let noResultLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.width, height: 0))
        tableView.separatorInset.right = 15
        
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width / 4,
                                     y: (view.height - 200) / 2,
                                     width: view.width / 2,
                                     height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Tableview delegate , datasource
extension NewConversationViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Bắt đầu cuộc trò chuyện (Click row table view)
        let targetUserData = results[indexPath.row]
        // click xong truyền dữ liệu rồi ẩn màn hình
        dismiss(animated: true) { [weak self] in
            // Gán dữ liệu cho closure completion để truyền về màn hình trước đó
            self?.completion?(targetUserData)
        }
    }
}

//MARK: - Search bar delegate
extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text , !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    /// - Tìm kiếm User
    func searchUsers(query: String) {
        // kiểm tra xem mảng có kết quả firebase không
        if hasFetched {
            // Nếu nó có -> Lọc kết quả
            filterUsers(with: query)
            
        } else {
            // nếu không, hãy tìm nạp rồi lọc
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }
    }
    
    /// - Trả về kết quả tìm kiếm sau khi search
    func filterUsers(with term: String) {
        // Cập nhật UI: Hiển thị kết quả hoặc hiển thị lable no results
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        // lấy kết qủa tìm kiếm
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            // Trả về một giá trị Boolean cho biết liệu chuỗi có bắt đầu bằng tiền tố được chỉ định hay không.
            return name.hasPrefix(term.lowercased()) || name.hasSuffix(term.lowercased())
        })
        
        self.results = results
        
        updateUI()
    }
    
    /// - Cập nhật UI
    func updateUI() {
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
