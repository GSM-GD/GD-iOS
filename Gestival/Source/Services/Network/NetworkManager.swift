import Moya
import Foundation
import Firebase
import FirebaseStorage

enum GDError: String, Error{
    case emailOrPasswordIncorrect = "이메일/닉네임이 일치하지 않습니다."
    case emailOrnameIsAlreadyExist = "이메일/닉네임이 이미 존재합니다."
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    var provider: MoyaProvider<GDAPI> = .init()
    
    func requestLogin(_ user: loginRequestUser) async throws -> authResponseUser{
         try await withCheckedThrowingContinuation({ config in
            provider.request(.requestLogin(user)) { result in
                switch result{
                case let .success(res):
                    
                    let response = try? JSONDecoder().decode([authResponseUser].self, from: res.data)
                    print(response)
                    if res.statusCode == 400{
                        config.resume(throwing: GDError.emailOrPasswordIncorrect)
                        return
                    }
                    config.resume(returning: response?.first ?? .init(name: "", email: "", password: ""))
                    
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
    
    func uploadImage(_ data: Data) async throws -> String {
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/feed/\(fileName)")
        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL().absoluteString
        return url
    }
    
    func requestPost(_ post: requestPost) async throws {
        let url = try await uploadImage(post.imageData)
        let data: [String: Any] = [
            "url": url
        ]
        _ = Firestore.firestore().collection("/feed").addDocument(data: data)
    }
    
    func requestAllPost() async throws -> [Post] {
        let docs = try await Firestore.firestore().collection("/feed").getDocuments()
        var res: [Post] = []
        for snapshot in docs.documents {
            let dict = snapshot.data()
            res.append(.init(url: dict["url"] as? String ?? ""))
        }
        return res
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
    
    func requestLoad(_ name: String) async throws -> [Load] {
        try await withCheckedThrowingContinuation({ config in
            provider.request(.requestLoad(name)) { result in
                switch result{
                case let .success(res):
                    do{
                        let loaded = try JSONDecoder().decode([Load].self, from: res.data)
                        config.resume(returning: loaded)
                    }catch{
                        config.resume(throwing: GDError.emailOrPasswordIncorrect)
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

