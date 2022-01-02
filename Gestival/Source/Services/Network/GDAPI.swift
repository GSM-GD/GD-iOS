import Moya

enum GDAPI{
    case requestLogin(loginRequestUser)
    case requestRegsiter(registerRequestUser)
    case requestLogout
    case requestPost(requestPost)
    case requestSave([Save])
    case requestAllPost
    case requestLoad(String)
}

extension GDAPI: TargetType{
    var baseURL: URL {
        return URL(string: "http://10.120.74.91:8000")!
    }
    
    var path: String {
        switch self{
        case .requestLogin:
            return "/users/login/"
        case .requestRegsiter:
            return "/users/signup/"
        case .requestLogout:
            return "/users/logout/"
        case .requestPost:
            return "/post/upload/"
        case .requestAllPost:
            return "/post/all/"
        case .requestSave:
            return "/objects/save/"
        case let .requestLoad(name):
            return "/objects/\(name)/"
        }
    }
    
    var method: Method {
        switch self{
        case .requestLogin, .requestRegsiter, .requestPost, .requestSave:
            return .post
        case .requestLogout, .requestAllPost, .requestLoad:
            return .get
        }
    }
    
    var task: Task {
        switch self{
        case let .requestLogin(req):
            let formdata: [MultipartFormData] = [
                MultipartFormData(provider: .data(req.email.data(using: .utf8) ?? .init()),
                                  name: "email"),
                MultipartFormData(provider: .data(req.password.data(using: .utf8) ?? .init()),
                                  name: "password")
            ]
            return .uploadMultipart(formdata)
        case let .requestRegsiter(req):
            let form: [MultipartFormData] = [
                MultipartFormData(provider: .data(req.name.data(using: .utf8) ?? .init()),
                                  name: "name"),
                MultipartFormData(provider: .data(req.email.data(using: .utf8) ?? .init()),
                                  name: "email"),
                MultipartFormData(provider: .data(req.password.data(using: .utf8) ?? .init()),
                                  name: "password")
            ]
            return .uploadMultipart(form)
        case .requestLogout:
            return .requestPlain
        case let .requestPost(post):
            let form: [MultipartFormData] = [
                MultipartFormData(provider: .data(post.imageData),
                                  name: "image",fileName: "\(post.title)\(post.content).jpeg",
                                  mimeType: "image/jpeg"),
                MultipartFormData(provider: .data(post.title.data(using: .utf8) ?? .init()),
                                  name: "title"),
                MultipartFormData(provider: .data(post.content.data(using: .utf8) ?? .init()),
                                  name: "content")
            ]
            
            return .uploadMultipart(form)
        case let .requestSave(saves):
            return .requestJSONEncodable(saves)
        case .requestAllPost:
            return .requestPlain
        case .requestLoad:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self{
        case .requestLogin, .requestRegsiter, .requestPost, .requestSave:
            return ["Content-Type": "multipart/form-data"]
        case .requestLogout, .requestAllPost, .requestLoad:
            return nil
        }
    }
    
    
}
