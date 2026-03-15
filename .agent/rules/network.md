# TookTook iOS — 네트워크 · DTO · 에러 · DesignSystem 규칙

---

## 규칙 N-1. API 요청은 `TargetType` enum으로 Domain Interface에 정의한다

> **이유**: enum 케이스로 모델링하면 잘못된 URL·메서드·파라미터를 컴파일 타임에 방지할 수 있다.

```swift
// Domain/XxxService/Interface/API/AuthAPIRequest.swift
public enum AuthAPIRequest {
    case login(request: LoginRequest)
    case logout
    case delete(reasonType: String, reason: String?)
}

extension AuthAPIRequest: TargetType {
    public var baseURL: String {
        switch self {
        case .delete: return API.apiBaseHost + "/v2"
        default:      return API.apiBaseHost + "/v1"
        }
    }
    public var path: String {
        switch self {
        case .login:  return "/auth/login"
        case .logout: return "/auth/logout"
        case .delete: return "/member"
        }
    }
    public var method: HTTPMethod {
        switch self {
        case .login, .logout: return .post
        case .delete:         return .delete
        }
    }
    public var parameters: RequestParams {
        switch self {
        case .login(let req):               return .body(req)
        case .logout:                       return .requestPlain
        case .delete(let type, let reason):
            var params: [String: String] = ["reasonType": type]
            if let reason { params["reason"] = reason }
            return .body(params)
        }
    }
}
```

---

## 규칙 N-2. APIClient는 Feature에서 직접 사용하지 않는다

```swift
// ❌ Feature에서 직접
@Dependency(APIClient.self) var apiClient
let result = try await apiClient.apiRequest(request: AuthAPIRequest.login(...))

// ✅ Domain Service를 통해
@Dependency(AuthService.self) var authService
try await authService.login(request)
```

---

## 규칙 N-3. 서버 URL은 반드시 `API.apiBaseHost`를 사용한다

```swift
// ❌ 하드코딩 금지
let url = "https://api.example.com/v1"

// ✅
public var baseURL: String { API.apiBaseHost + "/v1" }

// API.apiBaseHost 내부 (참고)
public static var apiBaseHost: String {
    #if DEV
    return "https://" + ServerEnvironment.current.baseURL + "/api"
    #else
    return "https://" + ServerEnvironment.prod.baseURL + "/api"
    #endif
}
```

---

## 규칙 N-4. API 응답 디코딩은 제네릭 메서드를 사용한다

```swift
// ✅ 제네릭 메서드 — 래퍼(APIResponse<T>) 자동 처리
let result = try await apiClient.apiRequest(
    request: AuthAPIRequest.login(request: req),
    as: LoginResponse.self
)

// 응답이 없는 경우
try await apiClient.apiRequest(request: AuthAPIRequest.logout, as: EmptyResponse.self)
```

---

## 규칙 N-5. DTO는 `Decodable`만 채택한다

```swift
// ❌ Codable 채택 금지 — 역할 혼재
public struct PostData: Codable { ... }

// ✅ 수신 전용
public struct PostData: Decodable, Equatable { ... }
```

---

## 규칙 N-6. 서버 필드명과 앱 필드명이 다를 때 `CodingKeys`로 매핑한다

```swift
public struct ProfileMemberData: Decodable, Equatable {
    public var memberId: Int?
    public var nickname: String
    public var profileImageURL: String?

    enum CodingKeys: String, CodingKey {
        case memberId
        case nickname
        case profileImage
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decodeIfPresent(Int.self, forKey: .memberId)
        nickname = (try? container.decode(String.self, forKey: .nickname)) ?? ""
        let image = (try? container.decodeIfPresent(ImageData.self, forKey: .profileImage)) ?? .init()
        profileImageURL = image.thumbnail.isEmpty ? nil : image.thumbnail
    }
}
```

---

## 규칙 N-7. DTO → Model 변환 책임은 Domain Service가 가진다

```
DTO 정의     → Core/CoreDTO/Interface 또는 Domain/XxxService/Interface/DTO
DTO → Model  → Domain/XxxService/Sources (Service 구현체)
Model → View → Feature Reducer (core 함수)
```

---

## 규칙 N-8. 모든 네트워크 에러는 `NetworkError`로 표현한다

```swift
public enum NetworkError: Error, Equatable {
    case requestError(_ description: String)   // 잘못된 요청
    case apiError(_ errorResponse: ErrorResponse)  // 서버 4xx
    case decodingError           // JSON 파싱 실패
    case serverError             // 서버 5xx
    case networkConnectionError  // 연결 불가
    case timeOutError            // 타임아웃
    case authorizationError      // 401
    case tokenRefreshFailed      // 토큰 갱신 실패 → AppCore까지 전파 → 강제 로그아웃
    case forceUpdateNeeded       // 강제 업데이트
    case cancelled               // 요청 취소
}
```

---

## 규칙 N-9. `tokenRefreshFailed`는 반드시 `AppCore`까지 전파한다

```swift
// AppCore에서 처리
case .tokenRefreshFailed:
    return .run { send in
        await apiClient.cancelAllRequests()
        keychainClient.delete(key: KeychainClientKeys.accessToken.rawValue)
        keychainClient.delete(key: KeychainClientKeys.refreshToken.rawValue)
        await send(.moveToLogin)
    }
```

---

## 규칙 N-10. `catch` 블록에서 에러를 무시하지 않는다

```swift
// ❌ 에러 무시 — 사용자·개발자 모두 원인을 알 수 없음
return .run { send in
    let result = try? await service.fetch()
    await send(.dataLoaded(result ?? []))
}

// ✅ 명시적 에러 처리
return .run { send in
    do {
        let result = try await service.fetch(apiClient)
        await send(.dataLoaded(result))
    } catch let error as NetworkError {
        await send(.fetchFailed(error))
    } catch {
        await send(.fetchFailed(.unknownError))
    }
}
```

---

## 규칙 N-11. 에러 메시지는 `NetworkError.errorMessage`를 활용한다

```swift
// ❌ 하드코딩
await send(.showAlert(message: "서비스에 문제가 발생했습니다."))

// ✅ NetworkError의 errorMessage 활용
case .fetchFailed(let error):
    state.errorMessage = error.errorMessage
    return .none
```

---

## 규칙 N-12. DesignSystem 토큰을 사용한다

```swift
// ❌ 하드코딩
Text("제목")
    .font(.system(size: 18, weight: .bold))
    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))

// ✅ DesignSystem 토큰
Text("제목")
    .font(Typography.titleBold)
    .foregroundColor(Color.textStrong)
```

- 컬러: `Color.xxx` 토큰 사용
- 폰트: `Typography.xxx` 사용
- 이미 존재하는 공통 컴포넌트를 중복 구현 금지
