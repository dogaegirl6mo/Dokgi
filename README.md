<img src="https://capsule-render.vercel.app/api?type=waving&color=0:F3F5FF,100:E8EEFF&height=300&section=header&text=Dokgi&fontSize=70&fontColor=4361AE&fontAlign=80&desc=독기&descAlign=94&descAlignY=55&animation=twinkling" />

<div align="center">

[![appStore](https://user-images.githubusercontent.com/50910456/173174832-7d395623-ceb3-4796-b718-22e550af6934.svg)](https://apps.apple.com/kr/app/%EB%8F%85%EA%B8%B0/id6504522434)
  
![Generic badge](https://img.shields.io/badge/Version-1.0.1-critical?labelColor=%2523789BFD&color=%252353D9FF.svg)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fdogaegirl6mo%2FDokgi&count_bg=%2353D9FF&title_bg=%23709FFF&icon=&icon_color=%23E7E7E7&title=&edge_flat=false)](https://hits.seeyoufarm.com)



</div>

## 👀 설명

<img width="1000" alt="스크린샷 2024-06-26 오후 12 45 42" src="https://github.com/dogaegirl6mo/Dokgi/assets/129073316/1f362e92-9434-4af1-9c80-81d6cdc38289">
</br>
</br>

**독서 기록을 간편하게!**

책을 읽으며 감동적인 구절을 만났을 때, 마음 깊이 새기고 싶지 않으신가요?

**독기**는 당신이 읽은 책 속 구절을 간편하게 기록하고, 특별한 순간을 영원히 간직할 수 있도록 도와줍니다. 마음에 드는 구절을 기록하고, 얼마나 기록했는지 레벨을 통해 알아보세요!

</br>


## 🔌 Develop Environment

- Language : Swift 5.10
- iOS Deployment Target : 17.0
- Xcode : 15.3


## 💻 Technical Skills

- UIKit
- WidgetKit
- MVVM
- CoreData

## 📓 Library

### SPM

- RxSwift
- SnapKit
- Then
- Kingfisher
- IQKeyboardManagerSwift

  </br>

## 🧑‍💻 Contributors

<div align="center"> 
  
| [김예슬](https://github.com/suri0000) | [송정훈](https://github.com/qkwmapel) | [김시온](https://github.com/tldhs27) | [임현정](https://github.com/Imhnjng) | [한철희](https://github.com/myhan601) |
|:---:|:---:|:---:|:---:|:---:|
|<img width="100" alt="Suri" src="https://avatars.githubusercontent.com/u/129073316?v=4">|<img width="100" alt="송정훈" src="https://github.com/dogaegirl6mo/Dokgi/assets/161270615/2f3460ff-2c42-42a8-939e-80d01be142c9">|<img width="100" alt="김시온" src="https://github.com/dogaegirl6mo/Dokgi/assets/129073316/345d7363-d04d-485a-9a59-8071914305b8">|<img width="100" alt="임현정" src="https://github.com/dogaegirl6mo/Dokgi/assets/161270615/c14fd3c2-8283-4aff-ac20-2bfaf3233fbe">|<img width="100" alt="한철희" src="https://avatars.githubusercontent.com/u/59227948?v=4">|

</div>



##
*  **김예슬** 
    - 앱 디자인
    - 책 상세 화면 개발
    - 위젯 개발
    - 컴포넌트 생성
    - CloudKit 연결 구현
 
*  **송정훈** 
    - 설정 화면 개발
    - 구절 상세보기 화면 개발
    - 다이나믹 폰트 등록
    - CoreData 모델 설계 및 연결
 
*  **김시온** 
    - 앱 디자인
    - 앱 아이콘 디자인
    - 구절 화면 개발
    - 내 서재 화면 개발
    - 런치 스크린 구현

*  **임현정**
    - 네이버 도서 검색 API 네트워킹
    - 데이터 모델 생성
    - 메인화면 - 오늘의 구절 개발
    - 메인화면 - 현재 구절 길이 개발
 
*  **한철희**
    - 구절 추가 화면 개발
    - 탭바 구현
    - 구절 스캔 OCR 구현
  
<br>

## 🛠️ 기술적 의사결정
* **MVVM과 RXSwift의 도입 이유** 
  - 코드의 간결화 : ViewModel을 사용하여 View와 Model의 의존성을 줄이고 코드가 분리 되어 더 이해하기 쉽게 구현 가능
  - 비동기 처리의 용의성 : 다양한 비동기 작업을 일관성 있게 처리할 수 있고 이를 통해 복잡한 비동기 흐름을 간단하게 관리할 수 있음
 
* **CoreData 도입 이유**
    - 사용자들끼리 공유해야하는 사항이 존재 하지 않음으로 내부 DB만으로 기능 구현이 가능
    - 개발 리소스를 iOS 설계 개발에 집중시키기 위해 : 아키텍처 학습에 리소스 집중, 소셜 로그인 구현 필요 x
  <details>
  <summary><b>CoreData 설계도</b></summary>
  <img width="390" alt="image" src="https://github.com/dogaegirl6mo/Dokgi/assets/161270615/ce268f37-51d9-4f5b-84ae-1d14eb7070bb">
  </details>
    
* **CloudKit 도입 이유**
    - 앱 내 데이터를 클라우드에 저장하여, 사용자가 앱을 삭제하더라도 데이터가 영구적으로 보존됨
    - 서버 관리가 필요 없기 때문에 iOS 설계 개발에 집중 가능
    - Apple 생태계에 완벽하게 통합되어 있어 Apple 기기에 자동 동기화 가능
 
 </br>

## 💥 트러블 슈팅   
* **Components, Extension을 활용하여 중복 코드를 최소화**
  <details>
  <summary><b>Extension & 컴포넌트화</b></summary>
  <img width="616" alt="image" src="https://github.com/dogaegirl6mo/Dokgi/assets/161270615/6390b934-2f7d-4c60-8a79-74749d980a69">
  </details>

</br>

## 🌱 Update
- 개발기간 : 2024.05 ~ 2024.07
- version 1.0.0 : 앱 스토어 출시 ( 24.06.19 )
- version 1.0.1 : 다크모드, 구절 복사 기능, CoreData Model 변경, 오류 수정 ( 24.06.26 )
- version 1.0.2 : 구절 스캔 기능 개선 ( 24.06.27 )
- version 1.0.3 : 사용성 개선 ( 24.06.27 )
