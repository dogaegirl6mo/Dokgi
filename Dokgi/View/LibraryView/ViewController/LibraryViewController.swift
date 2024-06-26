//
//  LibrarySearchViewController.swift
//  Dokgi
//
//  Created by t2023-m0095 on 6/4/24.
//
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class LibraryViewController: BaseLibraryAndPassageViewController {
    
    let libraryCollectionView = LibraryCollectionView()
    
    let libraryViewModel = LibraryViewModel()
    let disposeBag = DisposeBag()
    
    private var isFiltering: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabelText(title: "서재", placeholder: "기록한 책 또는 책의 저자를 검색해보세요", noResultsMessage: "기록한 책이 없어요\n구절을 등록해 보세요")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        CoreDataManager.shared.readBook()
        //        if sortButton.sortButtonTitleLabel.text == "오래된순" {
        //
        //            self.libraryViewModel.dataOldest()
        //        }
        //        self.libraryCollectionView.reloadData()
    }
    
    override func configureUI() {
        libraryCollectionView.delegate = self
        libraryCollectionView.dataSource = self
        
        view.addSubview(libraryCollectionView)
        
        libraryCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        view.sendSubviewToBack(libraryCollectionView)
    }
    
    override func setBinding() {
        CoreDataManager.shared.bookData.subscribe(with: self) { (self, data) in
            self.libraryCollectionView.isHidden = data.count < 0
            self.noResultsLabel.isHidden = data.count > 0
            if self.isFiltering { self.noResultsLabel.text = "검색결과가 없습니다." }
            self.libraryCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidBegin).subscribe(with: self) { (self, _) in
            self.isFiltering = true
            self.searchBar.showsCancelButton = true
        }.disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked.subscribe(with: self) { (self, _) in
            self.searchBar.resignFirstResponder()
            self.searchBar.showsCancelButton = false
            self.isFiltering = false
        }.disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked.subscribe(with: self) { (self, _) in
            self.searchBar.resignFirstResponder()
            self.searchBar.showsCancelButton = false
            self.isFiltering = false
            self.searchBar.text = ""
        }.disposed(by: disposeBag)
        
        searchBar.rx.text.debounce(.milliseconds(250), scheduler: MainScheduler.instance).subscribe(with: self) { (self, text) in
            CoreDataManager.shared.readBook(text: text ?? "")
            if self.sortButton.sortButtonTitleLabel.text == "최신순" {
                self.libraryViewModel.dataLatest()
            } else {
                self.libraryViewModel.dataOldest()
            }
        }.disposed(by: disposeBag)
    }
    //MARK: -버튼 클릭 시
    override func latestButtonAction() {
        self.libraryViewModel.dataLatest()
    }
    
    override func oldestButtonAction() {
        self.libraryViewModel.dataOldest()
    }
}

//MARK: - CollectionView
extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataManager.shared.bookData.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCell.identifier, for: indexPath) as? LibraryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let book = CoreDataManager.shared.bookData.value[indexPath.item]
        cell.authorNameLabel.text = book.author
        cell.bookNameLabel.text = book.title
        if let url = URL(string: book.image) {
                    cell.bookImageView.kf.setImage(with: url)
                }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookDetailViewController = BookDetailViewController()
        bookDetailViewController.viewModel.bookInfo.accept(CoreDataManager.shared.bookData.value[indexPath.item])
        self.navigationController?.pushViewController(bookDetailViewController, animated: true)
    }
}
