import Foundation

extension Array {

    subscript (safe index: Int) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
