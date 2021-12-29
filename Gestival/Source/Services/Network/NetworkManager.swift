import Moya

protocol NetworkManagerType: class{
    var provider: MoyaProvider<GDAPI> { get }
    
    func requestLogin(_ user: loginRequestUser) async throws -> loginResponseUser
    
    func requestLogout()
}

enum GDError: Error{
    case emailOrPasswordIncorrect
}

final class NetworkManager: NetworkManagerType{
    static let shared = NetworkManager()
    
    var provider: MoyaProvider<GDAPI> = .init()
    
    func requestLogin(_ user: loginRequestUser) async throws -> loginResponseUser{
        try await withCheckedThrowingContinuation({ config in
            provider.request(.requestLogin(user)) { result in
                switch result{
                case let .success(res):
                    if res.statusCode == 400{
                        config.resume(throwing: GDError.emailOrPasswordIncorrect)
                    }
                    let response = try? JSONDecoder().decode(loginResponseUser.self, from: res.data)
                    print("asdf")
                    print(response)
                    config.resume(returning: response ?? .init(name: "", email: "", password: ""))
                    
                case let .failure(err):
                    config.resume(throwing: err)
                
                }
            }
            
        })
    }
    
    func requestLogout() {
        
    }
}

