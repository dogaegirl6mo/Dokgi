//
//  BookSearchVC.swift
//  Dokgi
//
//  Created by 한철희 on 6/11/24.
//

import UIKit
import Then
import SnapKit
import Kingfisher

class BookSearchVC: UIViewController {
    
    let bookManager = BookManager.shared
    
    var searchResults: [Item] = [] // 검색 결과 저장
    weak var delegate: BookSelectionDelegate?
    
    let tableView = UITableView().then {
        $0.rowHeight = 150
        $0.showsVerticalScrollIndicator = false
    }
    
    let searchBar = UISearchBar().then {
        $0.searchBarStyle = .minimal
        $0.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        $0.setPositionAdjustment(UIOffset(horizontal: -8, vertical: 0), for: .clear)
        
        $0.placeholder = "책을 검색해보세요"
        $0.searchTextField.borderStyle = .line
        $0.searchTextField.layer.borderWidth = 1
        $0.searchTextField.layer.borderColor = UIColor(resource: .searchBarLightGray).cgColor
        $0.searchTextField.layer.backgroundColor = UIColor.white.cgColor
        $0.searchTextField.layer.cornerRadius = 17
        $0.searchTextField.layer.masksToBounds = true
        $0.searchTextField.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    var isLoading = false
    var query: String = ""
    var startIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        searchBar.delegate = self
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: "BookCell")
    }
    
    private func fetchBooks(query: String, startIndex: Int) {
        isLoading = true
        bookManager.fetchBookData(queryValue: query, startIndex: startIndex) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.searchResults.append(contentsOf: response.items)
                    self.tableView.reloadData()
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error: \(error)")
                self.isLoading = false
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension BookSearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            self.query = query
            self.startIndex = 1
            self.searchResults = []
            fetchBooks(query: query, startIndex: startIndex)
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension BookSearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as? BookCell else {
            return UITableViewCell()
        }
        
        let item = searchResults[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = searchResults[indexPath.row]
        
        delegate?.didSelectBook(item)
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > (contentHeight - 100 - scrollViewHeight) && !isLoading {
            startIndex += 10
            fetchBooks(query: query, startIndex: startIndex)
        }
    }
}

