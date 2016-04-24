//
//  URLNavigableFactory.swift
//  URLNavigator
//
//  Created by Juan Cruz Ghigliani on 24/4/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public class URLNavigableFactory{
    func navigableInstance() -> URLNavigable{
        return self.navigableInstance("", values: [:])
    }
    
    func navigableInstance(URL: URLConvertible, values: [String: AnyObject]) -> URLNavigable{
        fatalError("navigableInstance(URL:values:) has not been implemented")
    }
}

public class URLNavigableWithClass:URLNavigableFactory{
    var navigable:URLNavigable.Type
    
    public init (_ navigable:URLNavigable.Type){
        self.navigable = navigable
    }
    
    override func navigableInstance(URL: URLConvertible, values: [String: AnyObject]) -> URLNavigable{
        return navigable.init(URL: URL, values: values)!
    }

}

public class URLNavigableWithStoryboard:URLNavigableFactory{
    var storyboard:String
    var identifier:String
    var bundle:NSBundle?
    

    public init (_  storyboard:String, identifier:String, bundle:NSBundle? = nil){
        self.storyboard = storyboard
        self.identifier = identifier
        self.bundle = bundle
    }

    override func navigableInstance(URL: URLConvertible, values: [String: AnyObject]) -> URLNavigable{
        return UIStoryboard(name: self.storyboard, bundle: self.bundle).instantiateViewControllerWithIdentifier(self.identifier) as! URLNavigable
    }
    
}

public class URLNavigableWithBlock:URLNavigableFactory{
    public typealias factoryBlockType = (URL: URLConvertible, values: [String: AnyObject]) -> URLNavigable

    var factoryBlock:factoryBlockType
    
    
    public init (_ block:factoryBlockType){
        self.factoryBlock = block
    }
    
    override func navigableInstance(URL: URLConvertible, values: [String: AnyObject]) -> URLNavigable{
        return self.factoryBlock(URL: URL, values: values)
    }
    
}