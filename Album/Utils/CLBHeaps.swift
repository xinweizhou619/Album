//
//  CLBHeaps.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2021/11/30.
//

import Foundation

protocol CLAHeapProtocal {
    associatedtype Element
    func size() -> Int
    func isEmpty() -> Bool
    
    func clear()
    
    func add(e:Element)
    
    func peek() -> Element?
    func remove() -> Element?
    func replace(e:Element) -> Element?
}

///  Binary Heap 二叉队（完全二叉堆）
///  内部有Array 实现， i 是 index，n 节点数量
//  i = 0, 它是根节点
//  i > 0, 父节点编号 floor(  i - 1 / 2 )
//  如果 2i + 1 <= n – 1它的左子节点的索引为 2i + 1
//  如果 2i + 1 > n – 1 ，它无左子节点
//  如果 2i + 2 ≤ n – 1 ，它的右子节点的索引为 2i + 2
//  如果 2i + 2 > n – 1 ，它无右子节点

// 大顶堆
class CLABinaryHeap<E>: CLAHeapProtocal {
    
    typealias Element = E
    
    private(set) var elements:[E] = []
    private var capacity:Int
    private var comparator:Comparator
    
    // 批量建堆
    init(elements:[E], comparator:@escaping Comparator) {
        self.capacity = Int.max
        self.comparator = comparator
        // 复制原始数据
        self.elements = elements
        //
        heapify()
        print(self.elements)
    }
    //
    private func heapify() {
        // 自上而下的上滤
        for i in 1..<elements.count {
            shiftUp(index: i)
        }
        
//        // 自下而上的下滤
//        let start = elements.count >> 1 - 1
//        for i in (0...start).reversed() {
//            shiftDown(index: i)
//        }
    }
    
    init(capacity:Int = 10, comparator:@escaping Comparator) {
        self.capacity = capacity
        self.comparator = comparator
    }
    
    func size() -> Int {
        return elements.count
    }
    func isEmpty() -> Bool {
        return elements.count == 0
    }
    
    func clear() {
        elements.removeAll()
    }
    
    func add(e:E)  {
        if elements.count == capacity {
            fatalError("Count of elements must be less than Capacity")
        } else {
            elements.append(e)
            shiftUp(index: elements.count - 1)
        }
        
    }
    
    func peek() -> E? {
        return elements.first
    }
    func remove() -> E? {
        return elements.first.map { e in
            // 最后一个覆盖第一个元素
            let last = elements.last!
            elements[0] = last
            elements.removeLast()
            // 下滤
            shiftDown(index: 0)
            return e
        }
    }
    func replace(e:E) -> E? {
//        let element = remove()
//        add(e: e)
//        return element
    
        
        if let first = elements.first {
            elements[0] = e
            shiftDown(index: 0)
            return first
        } else {
            elements.append(e)
            return nil
        }
    }
    
    private func shiftUp(index: Int) {
//        var currentI = index
//        while currentI > 0 {
//            let pIndex = (currentI - 1) >> 1
//            let p = elements[pIndex]
//            let e = elements[currentI]
//            if compare(e1: e, e2: p) == .orderedDescending {
//                elements[currentI] = p
//                elements[pIndex] = e
//                currentI = pIndex
//            } else {
//                break
//            }
//        }
        
        var currentI = index
        let e = elements[currentI]
        while currentI > 0 {
            let pIndex = (currentI - 1) >> 1
            let p = elements[pIndex]
            if compare(e1: e, e2: p) == .orderedDescending {
                elements[currentI] = p
                currentI = pIndex
            } else {
                break
            }
        }
        
        elements[currentI] = e
        
    }
    private func shiftDown(index: Int) {
        var current = index
        let e = elements[current]
        // 非叶子节点数目
        let half = elements.count >> 1
        
        while current < half {
            // 有子节点 意味着
            // 1、只有左子节点
            // 2、有两个子节点
            
            // 左边
            var cIndex = current << 1 + 1
            var c = elements[cIndex]
            
            // 右边 然后选出最大值
            let rightCIndex = cIndex + 1
            if rightCIndex < elements.count {
                let rightC = elements[rightCIndex]
                if compare(e1: rightC, e2: c) == .orderedDescending {
                    c = rightC
                    cIndex = rightCIndex
                }
            }
            
            if compare(e1: c, e2: e) == .orderedDescending {
                elements[current] = c
                current = cIndex
            } else {
                break
            }
        }
    
        elements[current] = e
        
    }
    // Comparable
    private func compare(e1: E, e2: E) -> ComparisonResult {
        return self.comparator(e1, e2)
    }
    
}
