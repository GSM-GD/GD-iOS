import Moya

enum GDAPI{
    case requestLogin(loginRequestUser)
    case requestRegsiter(registerRequestUser)
    case requestLogout
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
        }
    }
    
    var method: Method {
        switch self{
        case .requestLogin, .requestRegsiter:
            return .post
        case .requestLogout:
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
        }
    }
    
    var headers: [String : String]? {
        switch self{
        case .requestLogin, .requestRegsiter:
            return ["Content-Type": "multipart/form-data"]
        case .requestLogout:
            return nil
        }
    }
    
    
}
