import Moya

protocol NetworkManagerType: class{
    var provider: MoyaProvider<GDAPI> { get }
    
    func requestLogin(_ user: loginRequestUser) async throws -> authResponseUser
    
    func requestRegister(_ user: registerRequestUser) async throws -> authResponseUser
    
    func requestLogout()
}

enum GDError: String, Error{
    case emailOrPasswordIncorrect = "이메일/닉네임이 일치하지 않습니다."
    case emailOrnameIsAlreadyExist = "이메일/닉네임이 이미 존재합니다."
}

final class NetworkManager: NetworkManagerType{
    static let shared = NetworkManager()
    
    var provider: MoyaProvider<GDAPI> = .init()
    
    func requestLogin(_ user: loginRequestUser) async throws -> authResponseUser{
         try await withCheckedThrowingContinuation({ config in
            provider.request(.requestLogin(user)) { result in
                switch result{
                case let .success(res):
                    
                    let response = try? JSONDecoder().decode(authResponseUser.self, from: res.data)
                    print(response)
                    if res.statusCode == 400{
                        config.resume(throwing: GDError.emailOrPasswordIncorrect)
                        return
                    }
                    config.resume(returning: response ?? .init(name: "", email: "", password: ""))
                    
                case let .failure(err):
                    config.resume(throwing: err)
                    return
                }
            }
            
        })
    }
    
    func requestRegister(_ user: registerRequestUser) async throws -> authResponseUser {
        try await withCheckedThrowingContinuation({ config in
            provider.request(.requestRegsiter(user)) { result in
                switch result{
                case let .success(res):
                    if res.statusCode == 400{
//                        config.resume(throwing: GDError.emailOrnameIsAlreadyExist)
                    }
                    let response = try? JSONDecoder().decode(authResponseUser.self, from: res.data)
                    print("ASDFD")
                    print(response)
                    config.resume(returning: response ?? .init(name: "", email: "", password: ""))
                case let .failure(err):
                    config.resume(returning: .init(name: "", email: "", password: ""))
                    
//                    config.resume(throwing: err)
                }
            }
        })
    }
    
    
    func requestLogout() {
        provider.request(.requestLogout) { result in
            switch result{
            case let .success(res):
                print(try! res.mapJSON())
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }
}

