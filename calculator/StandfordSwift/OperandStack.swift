//
//  OperandStack.swift
//  L01_StandfordCalculator
//
//  Created by sTinGe Su on 2015/7/2.
//  Copyright (c) 2015年 sTinGe Su. All rights reserved.
//

import Foundation

class OperandStack{
  // Printable is protocol
  private enum Op {
    case Operand(Double)
    case UnaryOperation(String, Double -> Double)
    case BinaryOperation(String, (Double, Double) -> Double)
  
    var description: String {
      get {
        switch self {
        case .Operand(let operand):
          return "\(operand)"
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
  
  init() {
    func learnOp(op: Op) {
      knownOps[op.description] = op
    }
    
    knownOps["×"] = Op.BinaryOperation("×") { $0 * $1 }
    knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
    knownOps["+"] = Op.BinaryOperation("+", +)
    knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
    knownOps["√"] = Op.UnaryOperation("√", sqrt)
    
  }
  
  typealias PropertyList = AnyObject
  
  var program: PropertyList { // guaranteed to be a ProprttyList
    get {
      return opStack.map { $0.description }
//      replaced following codes:
//      var returnValue = Array<String>()
//      for op in opStack {
//        returnValue.append(op.description)
//      }
    }
    set {
      if let opSymbols = newValue as? Array<String> {
        var newOpstack = [Op]()
        for opSymbol in opSymbols {
          if let op = knownOps[opSymbol] {
            newOpstack.append(op)
          } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
            newOpstack.append(.Operand(operand))
          }
        }
        opStack = newOpstack
      }
    }
  }
  
  private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
    if !ops.isEmpty {
      var remainingOps = ops
      let op = remainingOps.removeLast()
      switch op {
      case .Operand(let operand):
        return (operand, remainingOps)
      case .UnaryOperation(_, let operation):
        let operandEvaluation = evaluate(remainingOps)
        if let operand = operandEvaluation.result {
          return (operation(operand), operandEvaluation.remainingOps)
        }
      case .BinaryOperation(_, let operation):
        let op1Evaluation = evaluate(remainingOps)
        if let operand1 = op1Evaluation.result {
          let op2Evaluation = evaluate(op1Evaluation.remainingOps)
          if let operand2 = op2Evaluation.result{
            return (operation(operand1, operand2), op2Evaluation.remainingOps)
          }
        }
      }
    }
    return (nil, ops)
  }
  func evaluate() -> Double? {
      let (result, remainder) = evaluate(opStack)
    println("\(opStack) = \(result) with \(remainder) left over")
      return result
  }
//
  func push(operand: Double) -> Double? {
    opStack.append(Op.Operand(operand))
    return evaluate()
  }
  
  func peformOperation(symbol: String) -> Double? {
    // "Optional" Op
    if let operation = knownOps[symbol] {
      opStack.append(operation)
    }
    return evaluate()
  }
}