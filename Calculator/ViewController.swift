//
//  ViewController.swift
//  Calculator
//
//  Created by Gordon Ho on 8/6/15.
//  Copyright (c) 2015 Gordon Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    var userEnteredADecimal = false
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if !(digit == "." && userEnteredADecimal) {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        if digit == "." {
            userEnteredADecimal = true
        }
    }
    
    
    @IBAction func clearButtonPressed(sender: UIButton) {
        brain.clearCalculator()
        history.text = " "
        display.text = "0"
        userIsInTheMiddleOfTypingANumber = false
        userEnteredADecimal = false
    }
    
    @IBAction func removeDigit(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            if !display.text!.isEmpty {
                let x = dropLast(display.text!)
                if x.isEmpty {
                    display.text = "0"
                    userIsInTheMiddleOfTypingANumber = false
                    userEnteredADecimal = false
                } else {
                    display.text = x
                }
            }
        }
    }
    
    @IBAction func constantPIEntered(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let constant = sender.currentTitle {
            if let result = brain.pushConstant(constant) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        history.text = brain.showHistory()
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        history.text = brain.showHistory()
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        userEnteredADecimal = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        history.text = brain.showHistory()
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
            userEnteredADecimal = false
        }
    }
    
}

