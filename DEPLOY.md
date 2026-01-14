# 🚀 게임 배포 가이드 (How to Deploy)

이 게임을 다른 사람들과 함께 플레이하려면 웹 호스팅 서비스에 배포해야 합니다.
가장 추천하는 두 가지 무료 방법을 안내해 드립니다.

## 방법 1: GitHub Pages (추천 ✨)
Git과 GitHub를 사용 중이라면 가장 깔끔하고 관리가 쉬운 방법입니다.

1. **GitHub 저장소 생성**
   - [GitHub](https://github.com/)에 로그인 후 `New Repository`를 클릭합니다.
   - 저장소 이름(예: `weapon-master`)을 입력하고 `Create repository`를 누릅니다.

2. **코드 업로드 (터미널)**
   - VS Code 터미널(Ctrl+`)을 열고 아래 명령어를 순서대로 입력하여 로컬 코드를 GitHub에 올립니다.
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git branch -M main
   git remote add origin https://github.com/[당신의아이디]/[저장소이름].git
   git push -u origin main
   ```
   *(이미 remote가 설정되어 있다면 `git push`만 하면 됩니다)*

3. **Pages 활성화**
   - GitHub 저장소 페이지의 **Settings** 탭으로 이동합니다.
   - 좌측 메뉴에서 **Pages**를 클릭합니다.
   - **Branch** 설정에서 `main` (또는 `master`)을 선택하고 `/root` 경로를 설정한 뒤 **Save**를 누릅니다.

4. **완료!**
   - 1~2분 뒤 상단에 생성된 **주소(URL)**가 표시됩니다. 친구들에게 이 링크를 공유하세요!

---

## 방법 2: Netlify Drop (가장 쉬움 ⚡)
Git 명령어가 어렵거나 귀찮다면 이 방법을 사용하세요.

1. [Netlify Drop](https://app.netlify.com/drop) 사이트에 접속합니다. (로그인이 필요할 수 있습니다)
2. 내 컴퓨터의 `weapon-master` 폴더를 통째로 브라우저 화면의 **"Drag and drop your site output folder here"** 영역에 드래그합니다.
3. 업로드가 완료되면 즉시 랜덤한 주소로 사이트가 배포됩니다.
4. **Site Settings**에서 `Change site name`을 눌러 주소를 예쁘게 바꿀 수 있습니다.

---

## ⚠️ 3D 텍스처 주의사항
배포된 환경에서는 브라우저 보안 정책(CORS) 문제가 해결되므로, **3D 배경 텍스처가 정상적으로 로드되어 보일 것입니다.** 로컬에서 보이지 않던 문제도 배포하면 해결됩니다!
