//
//  AddVerseVC.swift
//  Dokgi
//
//  Created by 한철희 on 6/4/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit
import VisionKit

protocol BookSelectionDelegate: AnyObject {
    func didSelectBook(_ book: Item)
}

class AddPassageViewController: UIViewController {
    
    let viewModel = AddPassageViewModel()
    private let containerView = AddPassageContainerView()
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        setupActions()
        updateCharacterCountLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupViews() {
        view.backgroundColor = .white
        containerView.pageSegment.selectedIndex = 0
        viewModel.onRecognizedTextUpdate = { [weak self] recognizedText in
            self?.updateTextView(with: recognizedText)
        }
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.keywordCollectionView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: KeywordCollectionViewCell.identifier)
        containerView.keywordCollectionView.delegate = self
        containerView.keywordCollectionView.dataSource = self
        containerView.keywordField.delegate = self
        containerView.verseTextView.delegate = self
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.snp.width)
            $0.height.greaterThanOrEqualTo(1000)
        }
    }
    
    func setupActions() {
        containerView.scanButton.addTarget(self, action: #selector(scanButtonTapped(_:)), for: .touchUpInside)
        containerView.searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        containerView.recordButton.addTarget(self, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
        containerView.keywordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        containerView.pageSegment.buttons.enumerated().forEach { index, button in
            button.addTarget(self, action: #selector(pageSegmentButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func scanButtonTapped(_ sender: UIButton) {
        viewModel.visionKit(presenter: self)
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        let bookSearchVC = BookSearchViewController()
        bookSearchVC.delegate = self
        present(bookSearchVC, animated: true, completion: nil)
    }
    
    @objc func pageSegmentButtonTapped(_ sender: UIButton) {
        guard let index = containerView.pageSegment.buttons.firstIndex(of: sender) else { return }
        containerView.pageSegment.selectedIndex = index
        viewModel.pageType = index == 0 ? "Page" : "%"
    }
    
    @objc func recordButtonTapped(_ sender: UIButton) {
        if containerView.searchButton.isHidden == false {
            showAlert(title: "책 정보 기록", message: "책 검색을 눌러 책 정보를 기록해주세요")
            return
        }
        
        if containerView.verseTextView.text.isEmpty || containerView.verseTextView.text == "텍스트를 입력하세요" {
            showAlert(title: "구절 입력", message: "구절을 입력해 주세요")
            return
        }
        
        if containerView.pageNumberTextField.text?.isEmpty == true {
            showAlert(title: "페이지", message: "페이지를 입력해 주세요")
            return
        }
        
        if let pageNumber = Int(containerView.pageNumberTextField.text ?? "") {
            if viewModel.pageType == "Page" && pageNumber <= 0 {
                showAlert(title: "페이지 값 오류", message: "0 이상을 입력하세요.")
                return
            } else if viewModel.pageType == "%" && pageNumber > 100 {
                showAlert(title: "% 값 오류", message: "100이하를 입력하세요.")
                return
            }
        } else {
            showAlert(title: "입력 값 오류", message: "숫자를 입력하세요.")
            return
        }
        
        viewModel.saveVerse(selectedBook: viewModel.selectedBook,
                            verseText: containerView.verseTextView.text ?? "",
                            pageNumberText: containerView.pageNumberTextField.text ?? "",
                            pageType: viewModel.pageType,
                            keywords: viewModel.keywords) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showAlert(title: "경고", message: "모든 필수 정보를 입력해주세요.")
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func updateCharacterCountLabel() {
        viewModel.updateCharacterCountText(for: containerView.verseTextView.text, label: containerView.characterCountLabel)
    }

    func displayBookInfo() {
        if let book = viewModel.selectedBook {
            containerView.infoView.titleLabel.text = book.title
            containerView.infoView.titleLabel.font = Pretendard.semibold.dynamicFont(style: .headline)
            containerView.infoView.titleLabel.textColor = .black
            containerView.infoView.authorLabel.text = book.author
            if let url = URL(string: book.image) {
                containerView.infoView.imageView.kf.setImage(with: url)
                containerView.infoView.imageView.contentMode = .scaleAspectFill
            }
        }
        containerView.infoViewOverLapView.isHidden = true
        containerView.searchButton.isHidden = true
    }
    
    private func updateTextView(with text: String) {
        if containerView.verseTextView.text.isEmpty || containerView.verseTextView.textColor == .placeholderText {
            containerView.verseTextView.text = text
            containerView.verseTextView.textColor = .label
            containerView.verseTextView.font = Pretendard.regular.dynamicFont(style: .body)
            updateCharacterCountLabel()
        }
    }

    func removeKeyword(at indexPath: IndexPath) {
        let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
        viewModel.keywords.remove(at: reversedIndex)
        containerView.keywordCollectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension AddPassageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let keyword = textField.text, !keyword.isEmpty {
            if viewModel.keywords.count < 11 { // 10일 경우 alert 반복
                viewModel.keywords[textField.tag] = keyword
                containerView.keywordCollectionView.reloadData()
            } else {
                showAlert(title: "알림", message: "키워드는 최대 10개까지 입력할 수 있습니다.")
            }
        }
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            if !viewModel.keywords.contains("") {
                if viewModel.keywords.count < 10 {
                    viewModel.keywords.append("")
                    containerView.keywordCollectionView.reloadData()
                    textField.tag = viewModel.keywords.count - 1
                } else {
                    showAlert(title: "알림", message: "키워드는 최대 10개까지 입력할 수 있습니다.")
                }
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if viewModel.keywords.count > textField.tag {
                viewModel.keywords[textField.tag] = text
            }
            containerView.keywordCollectionView.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        return newText.count <= 20
    }
}

// MARK: - CollectionView
extension AddPassageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeywordCollectionViewCell.identifier, for: indexPath) as? KeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
        let keyword = viewModel.keywords[reversedIndex]
        cell.xButton.isHidden = false
        cell.keywordLabel.text = keyword
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let reversedIndex = viewModel.keywords.count - 1 - indexPath.item
        let keyword = viewModel.keywords[reversedIndex]
        let font = Pretendard.regular.dynamicFont(style: .callout)
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = (keyword as NSString).size(withAttributes: attributes)
        let cellWidth = textSize.width + 40
        let cellHeight: CGFloat = 34
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - 텍스트뷰 placeholder
extension AddPassageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard containerView.verseTextView.textColor == .placeholderText else { return }
        containerView.verseTextView.textColor = .label
        containerView.verseTextView.font = Pretendard.regular.dynamicFont(style: .body)
        containerView.verseTextView.text = nil
        updateCharacterCountLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "텍스트를 입력하세요"
            textView.textColor = .placeholderText
        }
        updateCharacterCountLabel()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        
        if currentCount > 200 {
            textView.text = String(textView.text.prefix(200))
            containerView.characterCountLabel.text = "200/200"
        } else {
            updateCharacterCountLabel()
        }
    }
}

// MARK: - 스캔
extension AddPassageViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        if scan.pageCount > 0 {
            let scannedImage = scan.imageOfPage(at: 0)
            viewModel.recognizeText(from: scannedImage)
        }
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        print("스캔 실패: \(error.localizedDescription)")
    }
}

// MARK: - 데이터 전달
extension AddPassageViewController: BookSelectionDelegate {
    func didSelectBook(_ book: Item) {
        viewModel.selectedBook = book
        displayBookInfo()
    }
}

