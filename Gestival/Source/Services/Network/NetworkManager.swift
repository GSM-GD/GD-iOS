import Moya

protocol NetworkManagerType: class{
    var provider: MoyaProvider<GDAPI> { get }
    
    func requestLogin(_ user: loginRequestUser) 
    
    func requestLogout()
}

final class NetworkManager: NetworkManagerType{
    static let shared = NetworkManager()
    
    var provider: MoyaProvider<GDAPI> = .init()
    
    func requestLogin(_ user: loginRequestUser)  {
        provider.request(.requestLogin(user)) { result in
            
        
        }
    }
    
    func requestLogout() {
        
    }
}

