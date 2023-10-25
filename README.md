
# RPS GAME
<img src="https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=Swift&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Xcode-147EFB?style=flat-square&logo=Xcode&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=Firebase&logoColor=white"/></a>

<!-- <img src="https://img.shields.io/badge/기술명-색상코드?style=flat-square&logo=기술명&logoColor=색상"/></a> -->

## 서비스 내용
> 실시간 일대일 가위바위보 게임 ✌🏻✊🏾✋

## App Icon ##
<img width="100" height="100" alt="app" src="https://user-images.githubusercontent.com/80871083/191462645-55f4f54e-9f37-4e67-ab17-bdeaea5bfa45.png">

## 프로젝트 기간 및 팀구성

개발 기간 (22.06.05~ 22.07.01)

팀: 서동운(domb), 신동훈(ehd)

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

## 프로젝트 내 역할

1. 프로젝트 구성 및 모델 설계
2. 사용자 목록 화면 구현, 게임 화면 구현
3. 실시간 초대 서비스 구현, 사용자의 상태에 따른 분기처리작업
4. Firebase를 활용한 비정규화 DB테이블 설계, api 통신 구현

## 기술 스택
- MVC
- storyboard(+ xib), UIKit
- kakaoSDKAuth, KakaoSDKUser
- GoogleSignIn
- CocoaPods

## 기능
1. 카카오 구글 소셜로그인 구현
2. 홈화면 사용자 리스트 확인, 게임초대 및 사용자 정보 열람
3. 가위바위보 게임
4. 게임 참여자 간 채팅 서비스

## 핵심 경험

✅  Firebase- RealTime Database를 사용한 비정규화 테이블 설계
> Firebase 툴을 활용하여 사용자 정보와 게임정보를 실시간 연동
> 가위바위보 및 채팅 기능 구현

✅ Oauth를 이용한 구글, 카카오 간편로그인
> auth 2.0 인증을 사용한 3rd-party login를 활용하여 간편로그인 구현 경험

✅ Code 및 storyboard를 사용하여 UI 구현
> 각 방식으로 AutoLayout을 적용하여 UI를 구현해보고 장단점 경험


✅ extension을 사용한 View의 레이아웃 세팅기능 구현

```
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
...
}
```
