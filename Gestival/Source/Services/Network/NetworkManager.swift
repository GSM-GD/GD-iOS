import Moya

protocol NetworkManagerType: class{
    var provider: MoyaProvider<GDAPI> { get }
    
    func requestLogin(_ user: loginRequestUser) async throws -> authResponseUser
    
    func requestRegister(_ user: registerRequestUser) async throws -> authResponseUser
    
    func requestLogout()
    
    func requestPost(_ post: requestPost) async throws -> responsePost
    
    func requestSave(_ objects: [Save]) async throws -> [Save]
    
    func requestAllPost() async throws -> [Post]
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
    
    func requestPost(_ post: requestPost) async throws -> responsePost{
        try await withCheckedThrowingContinuation { config in
            provider.request(.requestPost(post)) { result in
                switch result{
                case let .success(res):
                    do{
                        print(try res.mapJSON())
                        let response = try JSONDecoder().decode(responsePost.self, from: res.data)
                        config.resume(returning: response)
                    }catch{
                        config.resume(throwing: GDError.emailOrnameIsAlreadyExist)
                    }
                case let .failure(err):
                    config.resume(throwing: err)
                }
                
            }
        }
    }
    
    func requestSave(_ objects: [Save]) async throws -> [Save] {
        
        try await withCheckedThrowingContinuation({ config in
            
            let objs = objects.filter{ $0.objectName.isEmpty == false }
            print(objs)
            provider.request(.requestSave(objs)) { result in
                switch result{
                case let .success(res):
                    do{
                        let saves = try JSONDecoder().decode([Save].self, from: res.data)
                        config.resume(returning: saves)
                    }catch{
                        config.resume(throwing: GDError.emailOrnameIsAlreadyExist)
                    }
                case let .failure(err):
                    config.resume(throwing: err)
                }
            }
        })
    }
    
    func requestAllPost() async throws -> [Post] {
        try await withCheckedThrowingContinuation({ config in
            provider.request(.requestAllPost) { result in
                switch result{
                case let .success(res):
                    do{
                        let posts = try JSONDecoder().decode([Post].self, from: res.data)
                        config.resume(returning: posts)
                    }catch{
                        config.resume(throwing: GDError.emailOrnameIsAlreadyExist)
                    }
                case let .failure(err):
                    config.resume(throwing: err)
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

