//
//  BinarySearchTree.swift
//  BinarySearchTree
//
//  Created by Stuart Rankin on 8/5/21.
//

import Foundation

class BinarySearchTree<T: Comparable>: Equatable
{
    static func == (lhs: BinarySearchTree<T>, rhs: BinarySearchTree<T>) -> Bool
    {
        if lhs.Payload == nil
        {
            return false
        }
        if rhs.Parent == nil
        {
            return false
        }
        return lhs.Payload == rhs.Payload
    }
    
    var Parent: BinarySearchTree<T>? = nil
    var Left: BinarySearchTree<T>? = nil
    var Right: BinarySearchTree<T>? = nil
    var Payload: T!
    
    init(_ Payload: T)
    {
        self.Payload = Payload
    }
    
    init(_ NodeSet: [T])
    {
        if !NodeSet.isEmpty
        {
            self.Payload = NodeSet.first
            for EachNode in NodeSet.dropFirst()
            {
                self.Insert(EachNode)
            }
        }
    }
    
    var IsRoot: Bool
    {
        return Parent == nil
    }
    
    var IsLeafNode: Bool
    {
        return Left == nil && Right == nil
    }
    
    var IsLeftChild: Bool
    {
        if let LeftNode = Parent?.Left
        {
            return LeftNode == self
        }
        return false
    }
    
    var IsRightChild: Bool
    {
        if let RightNode = Parent?.Right
        {
            return RightNode == self
        }
        return false
    }
    
    func Insert(_ Value: T)
    {
        if Value < self.Payload
        {
            if let LeftNode = Left
            {
                LeftNode.Insert(Value)
            }
            else
            {
                Left = BinarySearchTree(Value)
                Left?.Parent = self
            }
        }
        else
        {
            if let RightNode = Right
            {
                RightNode.Insert(Value)
            }
            else
            {
                Right = BinarySearchTree(Value)
                Right?.Parent = self
            }
        }
    }
    
    public func Search(For: T) -> BinarySearchTree?
    {
        var Node: BinarySearchTree? = self
        while let SomeNode = Node
        {
            if Payload < SomeNode.Payload
            {
                Node = SomeNode.Left
            }
            else
                if Payload > SomeNode.Payload
            {
                    Node = SomeNode.Right
                }
            else
            {
                return Node
            }
        }
        return nil
    }
    
    func ProcessInOrder(_ Process: ((T) -> Void))
    {
        Left?.PreOrder(Process)
        Process(Payload)
        Right?.PreOrder(Process)
    }
    
    func PreOrder(_ Process: ((T) -> Void))
    {
        Process(Payload)
        Left?.PreOrder(Process)
        Right?.PreOrder(Process)
    }
    
    func PostPorder(_ Process: ((T) -> Void))
    {
        Left?.PostPorder(Process)
        Right?.PostPorder(Process)
        Process(Payload)
    }
}
