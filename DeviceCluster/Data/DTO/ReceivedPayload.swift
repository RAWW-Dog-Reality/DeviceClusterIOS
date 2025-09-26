import Foundation

struct PayloadDTO {
    let data: Data
    let type: PayloadType
    
    func encode() -> Data {
        var data = Data([type.rawValue])
        data.append(self.data)
        return data
    }
    
    static func decode(_ data: Data) -> PayloadDTO {
        var type: PayloadType = .unknown
        
        if let first = data.first, let receivedType = PayloadType(rawValue: first) {
            type = receivedType
        }
        
        let receivedData = data.dropFirst()
        return .init(data: receivedData, type: type)
    }
    
    enum PayloadType: UInt8 {
        case unknown = 0
        case audio = 1
    }
}
