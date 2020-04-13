//
//  OrderedDictionary.swift
//  URLNavigator
//
//  Created by Jerome Pasquier on 28/01/2019.
//

import Foundation

struct OrderedDictionary<Key: Hashable, Value> {
    var keys = [Key]()
    var values = [Key: Value]()
    
    var count: Int {
        return self.keys.count
    }
    
    subscript(index: Int) -> Value? {
        get {
            let key = self.keys[index]
            return self.values[key]
        }
        set(newValue) {
            let key = self.keys[index]
            if newValue != nil {
                self.values[key] = newValue
            } else {
                self.values.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            return self.values[key]
        }
        set(newValue) {
            if let newVal = newValue {
                let oldValue = self.values.updateValue(newVal, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            } else {
                self.values.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            }
        }
    }
    
}

extension OrderedDictionary: CustomStringConvertible {
    var description: String {
        let isString = type(of: self.keys[0]) == String.self
        var result = "["
        for key in keys {
            result += isString ? "\"\(key)\"" : "\(key)"
            result += ": \(self[key]!), "
        }
        result = String(result.dropLast(2))
        result += "]"
        return result
    }
}

extension OrderedDictionary: Sequence {
    func makeIterator() -> AnyIterator<Value> {
        var counter = 0
        return AnyIterator {
            guard counter<self.keys.count else {
                return nil
            }
            let next = self.values[self.keys[counter]]
            counter += 1
            return next
        }
    }
}
