//
//  PassageCollectionView.swift
//  Dokgi
//
//  Created by t2023-m0095 on 6/21/24.
//
import Then
import UIKit

class PassageCollectionVC: UICollectionViewController, PassageCollectionViewLayoutDelegate, PassageCollectionViewCellDelegate {
    
    weak var passageVC: PassageViewController?
    let viewModel = PassageViewModel()
    var isEditingMode: Bool = false
    var isFiltering: Bool = false
    
    lazy var passageCollectionView: UICollectionView = {
        let layout = PassageCollectionViewLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 2, left: 14, bottom: 15, right: 14)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PassageCollectionViewCell.self, forCellWithReuseIdentifier: PassageCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    var searchResultItems: [(String, Date)] = [] {
        didSet {
            if let layout = passageCollectionView.collectionViewLayout as? PassageCollectionViewLayout {
                layout.invalidateCache()
            }
            
            passageCollectionView.reloadData()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let passageVC = passageVC else { return 0 } // viewController가 nil인 경우 0 반환
        let cellCount = passageVC.viewModel.paragraphData.value.count
        let resultCount = passageVC.searchResultItems.count
        let itemCount = isFiltering ? resultCount : cellCount
        
        PassageView().emptyMessageLabel.isHidden = itemCount > 0
        if isFiltering { PassageView().emptyMessageLabel.text = "검색결과가 없습니다." }
        
        return itemCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassageCollectionViewCell.identifier, for: indexPath) as? PassageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setColor(with: indexPath)
        cell.deleteButton.isHidden = !isEditingMode
        cell.delegate = self
        
        let (text, date) = isFiltering ? searchResultItems[indexPath.item] : viewModel.paragraphData.value[indexPath.item]
        cell.paragraphLabel.text = text
        let dateString = String(date.toString()).suffix(10)
        cell.dateLabel.text = String(dateString)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        let text = isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0
        let date = isFiltering ? searchResultItems[indexPath.item].1 : viewModel.paragraphData.value[indexPath.item].1
        return calculateCellHeight(for: text, for: date.toString(), in: collectionView)
    }
    
    func heightForText(_ text: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0  // 멀티라인
        label.preferredMaxLayoutWidth = width
        label.lineBreakMode = .byCharWrapping
        label.font = Pretendard.regular.dynamicFont(style: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(constraintSize)
        
        return size.height
    }
    
    func heightForDateText(_ date: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.font = Pretendard.regular.dynamicFont(style: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.text = date
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = label.sizeThatFits(constraintSize)
        
        return size.height
    }
    
    func calculateCellHeight(for text: String, for date: String, in collectionView: UICollectionView) -> CGFloat {
        let cellPadding: CGFloat = 6
        let leftRightinsets: CGFloat = 15 * 2
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right + cellPadding * 4)) / 2 - leftRightinsets + 0.5
        
        let paragraphLabelHeight = heightForText(text, width: width)
        let paragraphDateSpacing: CGFloat = 30
        let dateLabelHeight: CGFloat = heightForDateText(date, width: width)
        let topBottomPadding: CGFloat = 14 * 2
        return paragraphLabelHeight + paragraphDateSpacing + dateLabelHeight + topBottomPadding
    }
    
    func tappedDeleteButton(in cell: PassageCollectionViewCell) {
        guard let indexPath = passageCollectionView.indexPath(for: cell) else { return }
        self.viewModel.selectParagraph(text: isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0, at: indexPath.item)
        var currentParagraph = isFiltering ? searchResultItems : viewModel.paragraphData.value
        currentParagraph.remove(at: indexPath.item)
        viewModel.paragraphData.accept(currentParagraph)
        searchResultItems = currentParagraph
        CoreDataManager.shared.deleteData(verse: viewModel.detailParagraph.value)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modalVC = PassageDetailViewController()
        
        viewModel.selectParagraph(text: isFiltering ? searchResultItems[indexPath.item].0 : viewModel.paragraphData.value[indexPath.item].0, at: indexPath.item)
        modalVC.viewModel.detailParagraph.accept(viewModel.detailParagraph.value)
        present(modalVC, animated: true, completion: nil)
    }
}

