//
//  Tree.swift
//  Tree
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit

/// Implements a simple binary tree that holds a value and optional payload.
/// The type of the stored value must be `Comparable`.
class Tree<T> where T: Comparable
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter With: Source tree used to populate this instance.
    init(With Other: Tree<T>)
    {
        Merge(With: Other)
    }
    
    /// Merge another tree (with the same type `T`) with this instance.
    /// - Note: If this instant has no nodes (eg, `Root` is nil), the first node of the passed tree is
    ///         used as the new root node.
    /// - Parameter With: The other tree to merge with this instance.
    /// - parameter NewIsGreater: Comparison closure. If nil, the values are compared directly. Otherwise,
    ///                           this is a closure that returns a boolean indicating the value to add is greater than
    ///                           a given node's value. Used to determine where to insert the new value. Paramaters
    ///                           are (NewNode, ExistingNode) and true should be returned if a comparison between
    ///                           the two indicates NewValue is greater than Existing value, false otherwise.
    func Merge(With: Tree<T>, NewIsGreater Comparer: ((TreeNode<T>, TreeNode<T>) -> Bool)? = nil)
    {
        let Nodes = With.InOrderNodeTraverse()
        if _Root == nil
        {
            _Root = Nodes[0]
            for Index in 1 ..< Nodes.count
            {
                AddOtherNode(Nodes[Index], To: _Root!, NewIsGreater: Comparer)
            }
            return
        }
        for Node in Nodes
        {
            AddOtherNode(Node, To: _Root!, NewIsGreater: Comparer)
        }
    }
    
    func AddOtherNode(_ Other: TreeNode<T>, To: TreeNode<T>,
                      NewIsGreater Comparer: ((TreeNode<T>, TreeNode<T>) -> Bool)? = nil)
    {
        if let Comparitor = Comparer
        {
            if Comparitor(Other, To)
            {
                if To.Right == nil
                {
                    To.Right = Other
                    return
                }
                else
                {
                    AddOtherNode(Other, To: To.Right!, NewIsGreater: Comparer)
                }
            }
            else
            {
                if To.Left == nil
                {
                    To.Left = Other
                    return
                }
                else
                {
                    AddOtherNode(Other, To: To.Left!, NewIsGreater: Comparer)
                }
            }
            return
        }
        else
        {
            if To.Value < Other.Value
            {
                if To.Left == nil
                {
                    To.Left = Other
                    return
                }
                else
                {
                    AddOtherNode(Other, To: To.Left!)
                }
            }
            else
            {
                if To.Right == nil
                {
                    To.Right = Other
                    return
                }
                else
                {
                    AddOtherNode(Other, To: To.Right!)
                }
            }
        }
    }
    
    /// Removes all nodes of the tree including the root.
    func RemoveAll()
    {
        _Root = nil
    }
    
    func DoRemoveAll(From: TreeNode<T>?)
    {
        guard let Node = From else
        {
            return
        }
        DoRemoveAll(From: Node.Left)
        TraversalResults.append(Node.Value)
        DoRemoveAll(From: Node.Right)
    }
    
    /// Root of the tree.
    private var _Root: TreeNode<T>? = nil
    /// Returns the root of the tree node.
    public var Root: TreeNode<T>?
    {
        get
        {
            return _Root
        }
    }
    
    /// Add a new value to the tree. Will be inserted in order.
    /// - Parameter NewValue: The value to add.
    /// - Parameter With: Optional payload to add. Defaults to nil.
    func Add(NewValue: T, With Payload: Any?)
    {
        if _Root == nil
        {
            _Root = TreeNode(WithValue: NewValue, AndPayload: Payload)
        }
        else
        {
            DoAddNode(NewValue, WithPayload: Payload, To: _Root!)
        }
    }
    
    /// Add the passed value and optional payload to the tree in order.
    /// - Parameter NewValue: The value to add.
    /// - Parameter WithPayload: The optional payload to add.
    /// - Parameter To: The parent node where to add the new value.
    private func DoAddNode(_ NewValue: T, WithPayload: Any?, To: TreeNode<T>)
    {
        if To.Value < NewValue
        {
            if To.Left == nil
            {
                To.Left = TreeNode(WithValue: NewValue, AndPayload: WithPayload)
                return
            }
            else
            {
                DoAddNode(NewValue, WithPayload: WithPayload, To: To.Left!)
            }
        }
        else
        {
            if To.Right == nil
            {
                To.Right = TreeNode(WithValue: NewValue, AndPayload: WithPayload)
                return
            }
            else
            {
                DoAddNode(NewValue, WithPayload: WithPayload, To: To.Right!)
            }
        }
    }
    
    /// Add a new value to the tree. Will be inserted in order.
    /// - Parameter NewValue: The value to add.
    /// - Parameter WithPayload: Optional payload to add. Defaults to nil.
    /// - Parameter NewIsGreater: Closure that returns a boolean indicating the value to add is greater than
    ///                           a given node's value. Used to determine where to insert the new value. Paramaters
    ///                           are NewValue, ExistingValue and true should be returned if a comparison between
    ///                           the two indicates NewValue is greater than Existing value, false otherwise.
    func Add(NewValue: T, WithPayload: Any?, NewIsGreater Comparer: (T, T) -> Bool)
    {
        DoAddNode(NewValue, WithPayload: WithPayload, To: _Root!, NewIsGreater: Comparer)
    }
    
    /// Add a new value to the tree. Will be inserted in order.
    /// - Parameter NewValue: The value to add.
    /// - Parameter WithPayload: Optional payload to add. Defaults to nil.
    /// - Parameter To: The parent node where to add the new value.
    /// - Parameter NewIsGreater: Closure that returns a boolean indicating the value to add is greater than
    ///                           a given node's value. Used to determine where to insert the new value. Paramaters
    ///                           are NewValue, ExistingValue and true should be returned if a comparison between
    ///                           the two indicates NewValue is greater than Existing value, false otherwise.
    private func DoAddNode(_ NewValue: T, WithPayload: Any?, To: TreeNode<T>, NewIsGreater Comparer: (T, T) -> Bool)
    {
        if Comparer(NewValue, To.Value)
        {
            if To.Right == nil
            {
                To.Right = TreeNode(WithValue: NewValue, AndPayload: WithPayload)
                return
            }
            else
            {
                DoAddNode(NewValue, WithPayload: WithPayload, To: To.Right!, NewIsGreater: Comparer)
            }
        }
        else
        {
            if To.Left == nil
            {
                To.Left = TreeNode(WithValue: NewValue, AndPayload: WithPayload)
                return
            }
            else
            {
                DoAddNode(NewValue, WithPayload: WithPayload, To: To.Left!, NewIsGreater: Comparer)
            }
        }
    }
    
    /// Returns the values of the tree in order.
    func InOrderTraverse() -> [T]
    {
        TraversalResults.removeAll()
        DoInOrderTraverse(From: _Root)
        return TraversalResults
    }
    
    /// Holds the results of the in order value traversal.
    private var TraversalResults = [T]()
    
    /// Run the in order value traversal.
    /// - Parameter From: Node to traverse.
    func DoInOrderTraverse(From: TreeNode<T>?)
    {
        guard let Node = From else
        {
            return
        }
        DoInOrderTraverse(From: Node.Left)
        TraversalResults.append(Node.Value)
        DoInOrderTraverse(From: Node.Right)
    }
    
    /// Returns the payloads of the tree in order.
    /// - Note: If no payloads were specified for any or all original values, those nodes without payloads
    ///         will not be respresented in the returned array of payloads.
    func InOrderPayloadTraverse() -> [Any]
    {
        PayloadTraversalResults.removeAll()
        DoInOrderPayloadTraverse(From: _Root)
        return PayloadTraversalResults
    }
    
    /// Holds the results of the payload in order traversal.
    private var PayloadTraversalResults = [Any]()
    
    /// Run the in order payload traversal.
    /// - Parameter From: Node to traverse.
    func DoInOrderPayloadTraverse(From: TreeNode<T>?)
    {
        guard let Node = From else
        {
            return
        }
        DoInOrderPayloadTraverse(From: Node.Left)
        if Node.Payload != nil
        {
            PayloadTraversalResults.append(Node.Payload!)
        }
        DoInOrderPayloadTraverse(From: Node.Right)
    }
    
    /// Returns the nodes of the tree in order.
    /// - Returns: Array or nodes in order.
    public func InOrderNodeTraverse() -> [TreeNode<T>]
    {
        NodeTraverseResults.removeAll()
        DoInOrderNodeTraverse(From: _Root)
        return NodeTraverseResults
    }
    
    /// Run the in order node traversal.
    /// - Parameter From: The node to traverse.
    private func DoInOrderNodeTraverse(From: TreeNode<T>?)
    {
        guard let Node = From else
        {
            return
        }
        DoInOrderNodeTraverse(From: Node.Left)
        NodeTraverseResults.append(Node)
        DoInOrderNodeTraverse(From: Node.Right)
    }
    
    /// Holds the nodes of the node traversal.
    private var NodeTraverseResults = [TreeNode<T>]()
}

/// Wrapper for nodes in the `Tree` class. Holds the node value an an optional payload.
class TreeNode<T> where T: Comparable
{
    /// Initializer.
    /// - Parameter WithValue: Node's value. Must be `Comparable`.
    /// - Parameter AndPayload: Optional payload.
    init(WithValue: T, AndPayload: Any?)
    {
        _Value = WithValue
        _Payload = AndPayload
    }
    
    /// Holds the optional payload.
    private var _Payload: Any? = nil
    /// Get or set the payload.
    public var Payload: Any?
    {
        get
        {
            return _Payload
        }
        set
        {
            _Payload = newValue
        }
    }
    
    /// Holds the value of the nose.
    private var _Value: T!
    /// Get or set the value of the node.
    public var Value: T
    {
        get
        {
            return _Value
        }
        set
        {
            _Value = newValue
        }
    }
    
    /// Holds the left child node.
    private var _Left: TreeNode<T>? = nil
    /// Get or set the left child node. If nil, left node hasn't been set yet.
    public var Left: TreeNode<T>?
    {
        get
        {
            return _Left
        }
        set
        {
            _Left = newValue
        }
    }
    
    /// Holds the right child node.
    private var _Right: TreeNode<T>? = nil
    /// Get or set the right child node. If nil, right node hasn't been set yet.
    public var Right: TreeNode<T>?
    {
        get
        {
            return _Right
        }
        set
        {
            _Right = newValue
        }
    }
}
