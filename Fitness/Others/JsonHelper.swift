import Foundation

class JsonHelper{
    
    public func toJson<T: Encodable>(type: T) -> String?{
        
        let encoder: JSONEncoder = JSONEncoder()
        let jsonData = try? encoder.encode(type.self)
        
        if jsonData == nil{
            return nil
        }
        
        return String(data: jsonData!, encoding: .utf8)
    }
    
    public func toObject<T: Decodable>(type: T.Type, json: String) -> T?{
        
        let decoder: JSONDecoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else{
            return nil
        }
        
        return try? decoder.decode(type.self, from: data)
    }
}
