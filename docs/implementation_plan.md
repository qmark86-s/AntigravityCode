# 🎨 3D 배경 퀄리티 향상 계획 (Phase 4)

## 🎯 목표
CSS 기반의 가짜 3D 배경을 **완전한 3D 텍스처 환경**으로 전환합니다. `assets/textures` 폴더의 고품질 텍스처를 활용하여 바닥, 벽, 천장을 실제 3D 메쉬로 구현하고, 스테이지 테마에 따라 동적으로 변경합니다.

## 📋 분석 및 접근 방식

### 현황
- **현재**: `index.html`의 CSS (`.tunnel-container`, `.wall-left`, etc.)로 터널 효과를 흉내내고 있음. 바닥(`ground`)만 실제 3D 메쉬로 존재하지만 평범한 색상/노이즈 사용.
- **문제**: 3D 캐릭터와 배경의 이질감, 낮은 텍스처 품질, 진정한 입체감 부족.
- **리소스**: `assets/textures/` 내에 다양한 테마별 텍스처(floor, wall, ceiling) 존재 확인.

### 개선 방안
1. **Real 3D Tunnel**: 바닥, 양쪽 벽, 천장을 `THREE.PlaneGeometry`로 생성하여 캐릭터를 감싸는 터널 형태 구축.
2. **Texture Mapping**: 각 테마(숲, 던전, 용암동굴, 얼음성, 마왕성)에 맞는 텍스처 매핑.
3. **Texture Scrolling**: 텍스처 좌표(`offset`)를 애니메이션하여 실제 이동하는 느낌 구현 (Infinite Scroll).
4. **Lighting Interaction**: 실제 3D 메쉬이므로 조명(PointLight, AmbientLight)과 상호작용하여 입체감 극대화.

## 🛠 상세 구현 계획

### 1. 텍스처 관리 시스템 (`Game3D` 클래스)
- `themeTextures` 객체 정의: 각 테마별 텍스처 경로 매핑
- `TextureLoader` 로드 및 캐싱 로직
- 텍스처 설정: `WrapT = RepeatWrapping`, `WrapS = RepeatWrapping`, `Anisotropy` 적용

### 2. 3D 환경 구축 (`createEnvironment` 수정)
- 기존 `ground` 및 `road` 재구성 (Road는 바닥 텍스처에 포함되어 있을 수 있으므로 확인 필요, 없으면 Decal 처럼 겹치기)
- **New Meshes**:
    - `wallLeft`: 왼쪽 벽 평면
    - `wallRight`: 오른쪽 벽 평면
    - `ceiling`: 천장 평면 (필요 시 Skybox와 조화 고려)
- **Geometry**: 길게 뻗은 터널 형태 (Z축 100~200 유닛)

### 3. 테마 업데이트 로직 (`updateBackgroundTheme` 수정)
- 테마 변경 시 해당 텍스처 로드 및 Material Map 교체
- 색상 틴트(Color Tint) 적용으로 같은 텍스처도 다른 느낌 연출 (예: Cave -> Lava Cave)

### 4. 애니메이션 (`animate` 수정)
- 캐릭터 이동 속도에 맞춰 텍스처 `offset.y` (또는 `x`) 지속 업데이트
- CSS 애니메이션 의존성 제거

### Phase 5: Extended Progression & Polish

- **Goal:** Extend gameplay to 200 Stages.
- **Cycle System:**
    - Monsters 1-20 repeal every 20 stages.
    - **Visual Variation:** Monsters in higher cycles (Stage 21+) get a **Color Tint** (Hue Rotate) to distinguish them from the original versions.
    - Logic: `HueRotation = floor((Stage - 1) / 20) * 45 deg` (shifts color every cycle).
- **Balance:**
    - Continue the "Overlap" growth curve (2.1x per Stage).
    - **Note:** At Stage 200, stats will reach ~10^64. Ensure `NumFormat` handles this or accept scientific notation (already implemented).
    - **Wave Balance:** Keep 10 Waves per Stage.

### Phase 6: Polish & Quality Assurance (Proposed)
- **Visual Impact (Juice):**
    - **Camera Shake:** Subtle camera shake on player attack/critical hits.
    - **Hit Flash:** Monster sprite flashes white briefly when hit.
    - **Damage Text:** Update CSS animation for "pop" effect and ensure readability for large numbers.
- **Code Optimization:**
    - **Texture Caching:** Enable `THREE.Cache.enabled = true` to prevent re-fetching backgrounds.
    - **Refactoring:** Move hardcoded balance constants (`BASE_HP`, growth factors) to a dedicated `GameBalance` object.
- **Mobile/UX:**
    - **Touch Feedback:** Visual ripple on screen tap.
    - **Audio Hook:** Skeleton structure for Audio Manager (BGM/SFX placeholders).

## 📅 파일 변경 목록

### [index.html](file:///c:/Users/idopa/.gemini/antigravity/scratch/weapon-master/index.html)

#### `Game3D` 클래스
- `constructor`: `textureLoader` 초기화
- `createEnvironment`: 벽, 천장 메쉬 생성 및 초기 텍스처 적용 코드 추가
- `updateBackgroundTheme`: 테마별 텍스처 교체 로직 구현
- `animate`: 텍스처 스크롤링 로직 추가

#### `Monster` 관련
- Update `meet()` to handle 20+ stages pattern mapping.
- Update `meet()` to apply CSS `filter: hue-rotate()` to the monster image.
- Verify `NumFormat` handles ultra-large numbers (extend suffixes if needed).

## 🧪 검증 계획

### 1. 자동화 테스트 (Browser Subagent)
- **테마 전환 테스트**: 스테이지 1(숲), 21(던전), 41(용암동굴) 등 강제 이동 후 배경 변경 확인
- **스크롤 테스트**: 캐릭터 이동 시 벽/바닥 텍스처가 뒤로 밀리는지 시각적 확인

### 2. 육안 검수
- 텍스처 품질 (깨짐 없는지, 반복 자연스러운지)
- 조명 효과 (벽에 빛 반사 등)
- 성능 (프레임 드랍 여부) - 텍스처 해상도 고려

## ⚠️ 주의사항
- 텍스처 로딩 시간 동안 깜빡임 방지 (Preloading 또는 비동기 처리)
- 텍스처 크기가 클 경우 메모리 관리 주의 (이미 확인 결과 적절함)
- `assets/textures` 경로가 올바른지 확인 (상대 경로 vs 절대 경로)
