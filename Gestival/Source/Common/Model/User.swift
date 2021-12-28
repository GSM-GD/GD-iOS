struct loginRequestUser: Codable{
    let email: String
    let password: String
}

struct registerRequestUser: Codable{
    let name: String
    let email: String
    let password: String
}
