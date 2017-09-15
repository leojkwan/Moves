import Foundation

// An observer that can subscribe to an Observable
// Because an observable holds references Observer,
// this class must be disposable.
public class Observer<T>: Disposable, CustomStringConvertible {
  
  public let key: UUID
  public weak var owner: Observable<T>?
  
  public init(owner: Observable<T>, key: UUID) {
    self.owner = owner
    self.key = key
  }
  
  public func dispose() {
    self.owner?.removeObserver(with: key)
  }
  
  public var description: String {
    return "Observer - key: \(key), owner: \(String(describing: owner))"
  }
}
