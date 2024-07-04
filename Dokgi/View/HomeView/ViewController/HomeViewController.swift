//
//  HomeViewController.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/4/24.
//

import CoreData
import RxSwift
import RxCocoa
import SnapKit
import UIKit

class HomeViewController: UIViewController, HomeViewDelegate {
 
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    let homeView = HomeView()
            
    var levelCollectionViewSelectedIndex = 0
    var nowPage: Int = 0 {
        didSet {
            self.homeView.indicatorDots.currentPage = nowPage
        }
    }
    let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        bindViewModel()
        bannerTimer()
        setFloatingButton()
        CoreDataManager.shared.readPassage() // 추가된 구절 반영
        homeView.delegate = self
        homeView.setConfigureUI(viewModel: viewModel)
        
        self.view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cloudKitDataSetting(_:)), name: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
    }
    
    @objc func cloudKitDataSetting(_ notification: Notification) {
        if let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
            as? NSPersistentCloudKitContainer.Event {
            switch cloudEvent.type {
                case .import:
                    print("An import finished!")
                    CoreDataManager.shared.readPassage()
                default: break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        CoreDataManager.shared.readPassage()
    }
    
    func setupConstraints() {
        view.backgroundColor = .white
        view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupCollectionView() {
        homeView.currentLevelCollectionView.dataSource = self
        homeView.currentLevelCollectionView.delegate = self
        homeView.todayVersesColletionView.dataSource = self
        homeView.todayVersesColletionView.delegate = self
        homeView.todayVersesColletionView.register(TodayPassageCell.self, forCellWithReuseIdentifier: TodayPassageCell.identifier)
        homeView.currentLevelCollectionView.register(CurrentLevelCell.self, forCellWithReuseIdentifier: CurrentLevelCell.identifier)
    }
    
    func bindViewModel() {
        // 현재 레벨
        viewModel.currentLevel
            .subscribe(onNext: { [ weak self ] value in
                self?.selectLevel(value, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 현재 레벨의 달성도(퍼센트)
        viewModel.currentLevelPercent
            .subscribe(onNext: { [ weak self ] value in
                guard let self else { return }
                self.homeView.lengthSlider.value = Float(value)
                homeView.nextLengthLabel.text = "다음 레벨까지 \(Int(Float(viewModel.currentLevelPercent.value) * 100)) % 달성했습니다!"
                self.homeView.currentLevelBubble.snp.remakeConstraints {
                    $0.width.equalTo(38)
                    $0.height.equalTo(41)
                    $0.top.equalTo(self.homeView.lengthSlider.snp.bottom)
                    $0.centerX.equalTo(self.homeView.lengthSlider.snp.leading).offset(self.homeView.lengthSlider.frame.width * CGFloat(self.homeView.lengthSlider.value))
                }
            })
            .disposed(by: disposeBag)
        
        // 현재 레벨 이미지
        viewModel.currentLevelImage
            .subscribe(onNext: { [ weak self ] image in
                self?.homeView.currentLevelImage.image = image
            })
            .disposed(by: disposeBag)
        
        // 구절 랜덤 5개
        viewModel.randomVerses
            .subscribe(onNext: { [weak self] value in
                self?.homeView.todayVersesColletionView.reloadData()
                self?.homeView.indicatorDots.numberOfPages = 5
            })
            .disposed(by: viewModel.disposeBag)
    }

    func selectLevel(_ level: Int, animated: Bool = true) {
        let index = max(0, min(level - 1, viewModel.levelCards.count - 1))
        let indexPath = IndexPath(item: index, section: 0)
        
        homeView.currentLevelCollectionView.reloadData() // 데이터 업데이트시 콜렉션뷰 리로드
        homeView.currentLevelCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    
        levelCollectionViewSelectedIndex = index
        updateCurrentLevelCollectionViewCell()
    }
    
    func updateCurrentLevelCollectionViewCell() {
        let prevIndex = max(0, levelCollectionViewSelectedIndex - 1)
        let currIndex = levelCollectionViewSelectedIndex
        let nextIndex = min(levelCollectionViewSelectedIndex + 1, viewModel.levelCards.count - 1)
        
        let prevCell = homeView.currentLevelCollectionView.cellForItem(at: IndexPath(row: Int(prevIndex), section: 0)) as? CurrentLevelCell
        let currCell = homeView.currentLevelCollectionView.cellForItem(at: IndexPath(row: Int(currIndex), section: 0)) as? CurrentLevelCell
        let nextCell = homeView.currentLevelCollectionView.cellForItem(at: IndexPath(row: Int(nextIndex), section: 0)) as? CurrentLevelCell
        
        if prevIndex != currIndex { prevCell?.transformToSmall() }
        currCell?.transformToStandard()
        if nextIndex != currIndex { nextCell?.transformToSmall() }
    }
    
    // 오늘의 구절 자동 넘기기
    func bannerTimer() {
        let _: Timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
            self.bannerMove()
        }
    }
    // 배너 움직이는 매서드
    func bannerMove() {
        if nowPage == 4 {
            scrollToFirstPage()
        } else {
            scrollNextToPage(nowPage)
        }
    }
    
    // 첫번째 페이지로 이동
    func scrollToFirstPage() {
        homeView.todayVersesColletionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: true)
        nowPage = 0
    }

    // 다음 페이지 이동
    func scrollNextToPage(_ page: Int) {
        nowPage += 1
        homeView.todayVersesColletionView.scrollToItem(at: IndexPath(item: nowPage, section: 0), at: .right, animated: true)
    }
    
    // 홈 상단에 설정 페이지 이동
    func didTapSettingButton() {
        let settingVC = SettingViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
        settingVC.tabBarController?.tabBar.isHidden = true
        settingVC.navigationController?.navigationBar.isHidden = false
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == homeView.currentLevelCollectionView {
            let currentLevel = viewModel.currentLevel
            return min(currentLevel.value + 1, viewModel.levelCards.count)
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == homeView.currentLevelCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentLevelCell.identifier, for: indexPath) as? CurrentLevelCell else { return UICollectionViewCell() }
            
            cell.setCellConfig(viewModel.levelCards[indexPath.item])
            
            // 다음레벨 가리기
            if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
                cell.hideView.isHidden = false
                cell.setupNextLevelCell(viewModel.currentLevel.value)
            } else {
                cell.hideView.isHidden = true
            }
            
            if indexPath.item + 1 == viewModel.currentLevel.value {
                let passages: [String] = viewModel.passages.value.map { $0.passage }
                let length = viewModel.getVerseLength(from: passages)
                cell.lengthLabel.text = MetricUtil.formatLength(length: length)
            }
            
            // 현재 보여지는 셀 크기 : Standard
            if levelCollectionViewSelectedIndex == indexPath.item {
                cell.transform = CGAffineTransform.identity
            }
            else {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayPassageCell.identifier, for: indexPath) as? TodayPassageCell else { return UICollectionViewCell() }
            
            let randomVerses = viewModel.randomVerses.value
            let passages: [String] = viewModel.passages.value.map { $0.passage }
            if passages.isEmpty || indexPath.item >= passages.count {
                let explainTexts = ["구절을 기록해주세요!", "오늘의 구절은 최대 5개까지 보여집니다", "매일 보여지는 구절은 기록한 구절 중 랜덤으로 보여집니다", "다른 구절을 보고 싶으시면 구절탭을 확인해주세요", "독기와 함께 오늘도 즐거운 독서와 기록 하세요"]
                self.homeView.indicatorDots.numberOfPages = 5
                cell.verse.text = explainTexts[indexPath.item]
            } else {
                cell.verse.text = randomVerses[indexPath.item]
            }
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 컬렉션 뷰의 크기에 맞게 셀 크기 설정
        if collectionView == homeView.todayVersesColletionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            if contentSizeCategory.rawValue == "UICTContentSizeCategoryXXXL" {
                return CGSize(width: 300, height: 195)
            } else {
                return CGSize(width: 300, height: 164)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    // 현재 드래그 되는 셀 작아지게
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == homeView.currentLevelCollectionView {
            let currentCell = homeView.currentLevelCollectionView.cellForItem(at: IndexPath(row: Int(levelCollectionViewSelectedIndex), section: 0)) as? CurrentLevelCell
            currentCell?.transformToSmall()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == homeView.currentLevelCollectionView {
            guard scrollView == homeView.currentLevelCollectionView else { return }
            
            // pointee == 스크롤 도착 좌표
            targetContentOffset.pointee = scrollView.contentOffset
            
            let flowLayout = homeView.currentLevelCollectionView.collectionViewLayout as! CurrentLevelCollectionFlowLayout
            let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
            let offset = targetContentOffset.pointee
            let horizontalVelocity = velocity.x
            
            var selectedIndex = levelCollectionViewSelectedIndex
            
            switch horizontalVelocity {
                // 스크롤 시
            case _ where horizontalVelocity > 0:
                selectedIndex = levelCollectionViewSelectedIndex + 1
            case _ where horizontalVelocity < 0:
                selectedIndex = levelCollectionViewSelectedIndex - 1
                
                // 정지 후에 스크롤 할 떄
            case _ where horizontalVelocity == 0:
                let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
                let roundedIndex = round(index)
                selectedIndex = Int(roundedIndex)
            default:
                print("Incorrect velocity for collection view")
            }
            
            let safeIndex = max(0, min(selectedIndex, viewModel.currentLevel.value))
            let selectedIndexPath = IndexPath(item: safeIndex, section: 0)
            homeView.currentLevelCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
            
            levelCollectionViewSelectedIndex = selectedIndexPath.item
            
            updateCurrentLevelCollectionViewCell()
        } else if scrollView == homeView.todayVersesColletionView {
            // 사용자가 오늘의 구절을 넘겼을 때
            let pageWidth = scrollView.frame.size.width
            let targetXContentOffset = targetContentOffset.pointee.x
            let page = Int(targetXContentOffset / pageWidth)
            self.homeView.indicatorDots.currentPage = page
            self.nowPage = page
        }
    }
}
