//
//  CLBLRUCache.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2021/11/30.
//

import Foundation
import UIKit

class CLBLRUCache<Key: Hashable, Value> {

    private var capacity:Int
    private var map:[Key:Node]
    //虚拟头结点
    private var first:Node
    //虚拟尾节点
    private var last:Node
    
    private class Node {
        public var key:Key?
        public var value:Value?
        public var prev:Node?
        public var next:Node?
        
        init(key:Key? = nil, value:Value? = nil) {
            self.key = key
            self.value = value
        }
    }
    
    init(_ capacity: Int) {
        self.capacity = capacity
        self.map = Dictionary(minimumCapacity: capacity)
        self.first = Node()
        self.last = Node()
        first.next = last
        last.prev = first
    }
    
    func get(_ key: Key) -> Value? {
        guard let node = map[key] else {
            return nil
        }
        remove(node: node)
        addBehindFirst(node)
        return node.value
    }
    
    
    /// 加入缓存
    /// - Parameters:
    ///   - key: 使用的key（hashable）
    ///   - value: 值
    /// - Returns: 返回 淘汰的 （Key，Value）
    func put(_ key: Key, _ value: Value) -> (key: Key, value: Value)? {
        if let node = map[key] {
            node.value = value
            remove(node:node)
            addBehindFirst(node)
            return nil
        } else {
            if map.count >= self.capacity { // 删除 最后一个 node
                // remove node from Map
                let lastNode = (last.prev?.key).flatMap({map.removeValue(forKey: $0)})
                // remove node from LinkList
                lastNode.map({remove(node: $0)})
                // return turple
                return lastNode.map({ node in
                    return (node.key!, node.value!)
                })
            }
            // add new node
            let newNode = Node(key: key, value: value)
            // add new node to Map
            map[key] = newNode
            // add new node to LindList
            addBehindFirst(newNode)
            
        }
        return nil
        
    }
    
    func clear() {
        
        self.map.removeAll()
        
        // 防止循环引用，需要释放引起对象闭环的指针
        // 从first释放 正向指针
        var tempNode = self.first.next
        while tempNode != nil {
            let next = tempNode?.next
            tempNode?.next = nil
            tempNode = next
        }
        // 两端释放
        self.first.next = nil
        self.last.next = nil
    }
    
    private func remove(node:Node) {
        let prev = node.prev
        let next = node.next
        
        prev?.next = next
        next?.prev = prev
        
    }
    private func addBehindFirst(_ node:Node) {
        let oldFirst = first.next
        //
        first.next = node
        node.prev = first
        //
        node.next = oldFirst
        oldFirst?.prev = node
        
    }
}
