import Foundation

protocol DataManagerInjectable {
    func injectWith(dataManager: DataManager)
}

protocol SetInjectable {
    func injectWith(set: Set)
}
