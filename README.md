# 팀원 Clone 이후 세팅 가이드

## 1단계: 패키지 설치
```bash
flutter pub get
```

## 2단계: Flutter 환경 설정
```bash
flutter doctor --android-licenses
```
> y 전부 입력

```bash
flutter config --no-enable-windows-desktop
```

## 3단계: 실행 확인
```bash
flutter run
```
정상 실행되면 준비 완료! ✅

---

## 4단계: 작업 시작 (매번 이 순서로!)

### 1. 최신 코드 받기
```bash
git pull origin main
```

### 2. 본인 브랜치 생성
```bash
git checkout -b feature/기능이름
```

### 3. 작업 후 올리기
```bash
git add .
git commit -m "feat: 기능 설명"
git push origin feature/기능이름
```

### 4. GitHub에서 PR 생성
1. GitHub 레포 접속
2. **Compare & pull request** 클릭
3. `feature/기능이름` → `main` 방향 확인
4. 설명 작성 → **Create pull request**
5. 팀장 Merge 후 완료 ✅
