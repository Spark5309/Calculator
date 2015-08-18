//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gordon Ho on 8/6/15.
//  Copyright (c) 2015 Gordon Ho. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Constant(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Constant(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    private var orderOperation = [String:Int]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }

        learnOp(Op.Constant("π"))
        
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))

        orderOperation["√"] = 100
        orderOperation["sin"] = 100
        orderOperation["cos"] = 100
        orderOperation["✕"] = 50
        orderOperation["÷"] = 50
        orderOperation["+"] = 10
        orderOperation["-"] = 10
        
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(let symbol):
                if symbol == "π" {
                    return (M_PI, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
//        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushConstant(symbol:String) -> Double? {
        if let constant = knownOps[symbol] {
            opStack.append(constant)
        }
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func traverse(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Constant(let symbol):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandTraversal = traverse(remainingOps)
                if let operand = operandTraversal.result {
                    return (symbol + "(" + operand + ")", operandTraversal.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                var historyOperation : String
                let op1Traversal = traverse(remainingOps)
                if let operand1 = op1Traversal.result {
                    let op2Traversal = traverse(op1Traversal.remainingOps)
                    if let operand2 = op2Traversal.result {
                        if symbol == "÷" || symbol == "-" {
                            historyOperation = operand2 + symbol + operand1
                        } else {
                            historyOperation = operand1 + symbol + operand2
                        }
                        return (historyOperation, op2Traversal.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func traverse() -> String? {
        let (result, remainder) = traverse(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }

    func showHistory() -> String? {
        var history = " "
        
        if !opStack.isEmpty {
            for ops in opStack {
                history += "\(ops) "
            }
        }
        println(history)
        
        
        return traverse()
    }
    
    func clearCalculator() {
        opStack = []
    }
    
}