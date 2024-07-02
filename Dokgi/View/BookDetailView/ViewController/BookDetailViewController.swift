//
//  BookDetailViewController.swift
//  Dokgi
//
//  Created by 예슬 on 6/10/24.
//

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class BookDetailViewController: UIViewController {
    let viewModel = BookDetailViewModel()
    private var disposeBag = DisposeBag()
    
    private let contentsView = UIView()
    private let gradientLayerView = UIView()
    private let buttonBackgroundView = UIView()
    private let buttonBackgroundLayer = CAGradientLayer()
    private let gradientLayer = CAGradientLayer()
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let backgroundBookImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let backgroundImageBlurView = UIVisualEffectView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.6)
        $0.effect = UIBlurEffect(style: .light)
        $0.alpha = 0.8
    }
    
    private let bookImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
        $0.clipsToBounds = true
    }
    
    private let bookInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    private let bookTitleLabel = UILabel().then {
        $0.font = Pretendard.semibold.dynamicFont(style: .headline)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let authorLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.numberOfLines = 2
        $0.textColor = .alarmSettingText
        $0.textAlignment = .center
    }
    
    private let firstDateRecordStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    private let firstRecordDateTitleLabel = UILabel().then {
        $0.text = "처음 기록 날짜"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textAlignment = .left
        $0.textColor = .black
    }
    
    private let dateLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .alarmSettingText
        $0.textAlignment = .right
    }
    
    private let passageTitleLabel = UILabel().then {
        $0.text = "구절"
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textColor = .black
    }
    
    private let passageTableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 289
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.backgroundColor = .white
    }

    private let addPassageButton = AddPassageButton().then {
        $0.setButtonTitle("구절 추가하기")
    }

    let backButton = BackButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        passageTableView.dataSource = self
        passageTableView.delegate = self
        passageTableView.register(PassageTableViewCell.self, forCellReuseIdentifier: PassageTableViewCell.identifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.rx.tap.subscribe(with: self) { (self, _) in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        setConstraints()
        bindViewModel()
        tappedAddPassageButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        blurLayer(layer: gradientLayer, view: gradientLayerView)
        blurLayer(layer: buttonBackgroundLayer, view: buttonBackgroundView)
        CoreDataManager.shared.readBook()
        CoreDataManager.shared.bookData.subscribe { data in
            let book = data.filter { $0.title == self.viewModel.bookInfo.value.title }
            self.viewModel.bookInfo.accept(book[0])
        }.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.bookInfo
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { (self, bookInfo) in
                self.setBookInfo(bookInfo)
                self.passageTableView.reloadData()
                self.updatePassageTableHeight()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - UI
    private func setConstraints() {
        view.addSubviews([scrollView, buttonBackgroundView, addPassageButton])
        scrollView.addSubview(contentsView)
        contentsView.addSubviews([backgroundBookImage,
                                  backgroundImageBlurView,
                                  gradientLayerView,
                                  bookImage,
                                  bookInfoStackView,
                                  firstDateRecordStackView,
                                  passageTitleLabel,
                                  passageTableView])
        
        [bookTitleLabel, authorLabel].forEach {
            bookInfoStackView.addArrangedSubview($0)
        }
        
        [firstRecordDateTitleLabel, dateLabel].forEach {
            firstDateRecordStackView.addArrangedSubview($0)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(self.view)
            $0.bottom.equalTo(buttonBackgroundView.snp.top)
        }
        
        contentsView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        passageTableView.snp.makeConstraints {
            $0.top.equalTo(passageTitleLabel.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(96 * viewModel.bookInfo.value.passages.count)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        backgroundBookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bookInfoStackView.snp.top)
        }
        
        backgroundImageBlurView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bookInfoStackView.snp.top)
        }
        
        gradientLayerView.snp.makeConstraints {
            $0.bottom.equalTo(backgroundImageBlurView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.09)
        }
        
        bookImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(174)
            $0.height.equalTo(bookImage.snp.width).multipliedBy(1.4)
        }
        
        bookInfoStackView.snp.makeConstraints {
            $0.top.equalTo(bookImage.snp.bottom).offset(50)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        firstDateRecordStackView.snp.makeConstraints {
            $0.top.equalTo(bookInfoStackView.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        firstRecordDateTitleLabel.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
        
        passageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(firstDateRecordStackView.snp.bottom).offset(42)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        addPassageButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalTo(buttonBackgroundView)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.top.equalTo(addPassageButton)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func blurLayer(layer: CAGradientLayer, view: UIView) {
        let colors: [CGColor] = [
            UIColor(white: 1.0, alpha: 0.0).cgColor,
            UIColor(white: 1.0, alpha: 1.0).cgColor
        ]
        
        layer.type = .axial
        layer.colors = colors
        
        DispatchQueue.global(qos: .userInitiated).async {
            var startPoint = CGPoint(x: 0.5, y: 0.0)
            let endPoint: CGPoint
            
            if view == self.buttonBackgroundView {
                startPoint = CGPoint(x: 0.5, y: -0.8)
                endPoint = CGPoint(x: 0.5, y: 0.5)
            } else {
                endPoint = CGPoint(x: 0.5, y: 0.8)
            }
            
            DispatchQueue.main.async {
                layer.frame = view.bounds
                layer.startPoint = startPoint
                layer.endPoint = endPoint
                view.layer.addSublayer(layer)
            }
        }
    }
    
    private func setBookInfo(_ bookInfo: Book) {
        bookTitleLabel.text = bookInfo.title
        authorLabel.text = bookInfo.author
        dateLabel.text = viewModel.setFirstRecordDate()
        
        if let url = URL(string: bookInfo.image) {
            bookImage.kf.setImage(with: url)
            backgroundBookImage.kf.setImage(with: url)
        }
    }
    
    private func updatePassageTableHeight() {
        passageTableView.snp.updateConstraints {
            $0.height.equalTo(96 * viewModel.bookInfo.value.passages.count)
        }
    }
    
    private func tappedAddPassageButton() {
        addPassageButton.rx.tap.subscribe(with: self) { (self, _) in
            let addVerseVC = AddPassageViewController()
            addVerseVC.viewModel.showUi = true
            addVerseVC.viewModel.selectedBook = self.viewModel.makeAddVerseViewData()
            self.navigationController?.pushViewController(addVerseVC, animated: true)
            addVerseVC.displayBookInfo()
        }.disposed(by: disposeBag)
    }
}
// MARK: - PassageTableView
extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookInfo.value.passages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PassageTableViewCell.identifier, for: indexPath) as? PassageTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.setPassageData(passage: viewModel.bookInfo.value.passages[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}
