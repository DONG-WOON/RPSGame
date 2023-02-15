
# RPS GAME
<img src="https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=Swift&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Xcode-147EFB?style=flat-square&logo=Xcode&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=Firebase&logoColor=white"/></a>

<!-- <img src="https://img.shields.io/badge/기술명-색상코드?style=flat-square&logo=기술명&logoColor=색상"/></a> -->

## 소개

> 나의 가위바위보 ✌🏻✊🖐🏾 실력은 어느정도일까?? 
> 깜찍한 가위바위보 게임으로 우리 승부를 겨뤄보자 ㅎㅎ!!


## App Icon ##
<img width="100" height="100" alt="app" src="https://user-images.githubusercontent.com/80871083/191462645-55f4f54e-9f37-4e67-ab17-bdeaea5bfa45.png">

## 프로젝트 기간

프로토타입 개발 기간 (22.06.05~ 22.07.01)<br/>
리팩토링 기간 (22.09.15~ 22.09.21)

## UI(스크린샷)
<p align="center">
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191463826-62188627-df5b-4112-93dc-4224212cc0e8.png">
 
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191464070-49c6d7d8-9490-42b6-ba47-79cb25e8abf4.png">
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191464296-40612188-1cfa-4374-988d-a55af9e33637.png">
</p>


<p align="center">
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191464375-4b9a02a5-5079-4e89-ac53-584ac1afc00b.png">
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191464412-e8a39476-bb11-4073-949b-d78a59f032de.png">
  <img width="250" src = "https://user-images.githubusercontent.com/80871083/191464532-cd68a45a-4092-4b68-ba48-5b3c3bd61283.png">
</p>


<!-- /*<img width="250" src = "">*/ -->


## 진행방식

- 프로젝트 내부에서 공통과 메인 파트를 나누고 각자 설계

      - 공통: 프로젝트 구성 및 모델 설계 및 네트워크 통신 및 리팩토링
      - 🔥 EHD: UI 및 디자인 설계, 채팅 서비스, play sound 구현
      - 🍀 domb: 파이어베이스 데이터베이스 디자인 및 API 설계, 초대 서비스 구현, 게임 구현
  
- 기능구현, 버그 수정 등의 처리후 커밋으로 기록 남기고 상대방과 공유

## 사용기술

### 디자인 패턴
> Architecture - MVC패턴<br/>
> Delegate패턴

### 프레임워크
> UIKit  <br/> 
> AVFoundation

### 라이브러리
    CocoaPods을 활용한 SDK 설치 및 활용

> **데이터베이스 저장 및 불러오기 기능 활용**
- Firebase/Core
- Firebase/Database
- Firebase/Auth
- Firebase/Storage

> **구글 로그인 및 사용자 정보 활용**
- GoogleSignIn

> **카카오 로그인 및 사용자 정보 활용**
- KakaoSDKCommon
- KakaoSDKAuth
- KakaoSDKUser

## 핵심 경험

☑️  Firebase- RealTime Database
> 서버 구축 없이 Firebase가 제공하는 RealTime Database를 활용하여 사용자 정보와 게임정보를 실시간 연동하여 앱의 기능들을 구현

☑️ Oauth를 이용한 구글, 카카오 간편로그인
> Third- Party- Login을 제공하는 카카오와 구글의 SDK를 활용하여 간편로그인 구현 경험

☑️ Code 및 storyboard를 사용하여 UI 구현
> 각 방식으로 AutoLayout을 적용하여 UI를 구현해보고 장단점 경험 

