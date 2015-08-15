//
//  ViewController.swift
//  CalculatorBrain
//
//  Created by Tatiana Kornilova on 2/5/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var tochka: UIButton! {
        didSet {
            tochka.setTitle(decimalSeparator, forState: UIControlState.Normal)
        }
    }

    let decimalSeparator =  NSNumberFormatter().decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTypingANumber = false

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            
             //----- Не пускаем избыточную точку ---------------
            if (digit == decimalSeparator) && (display.text?.rangeOfString(decimalSeparator) != nil) { return }
           
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit != decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
                                                                              { display.text = digit ; return }
            //--------------------------------------------------
            
            display.text = display.text! + digit
            
        } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
                history.text = history.text!.rangeOfString("=") != nil ? String((history.text!).characters.dropLast()) :  history.text
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            history.text = history.text!.rangeOfString("=") != nil ? String((history.text!).characters.dropLast()) :  history.text
            history.text =  history.text! + " " + operation + "="

            switch operation {
                
            case "×": performOperation { $0 * $1 }
            case "÷": performOperation { $1 / $0 }
            case "+": performOperation { $0 + $1 }
            case "−": performOperation { $1 - $0 }
            case "√": performOperation ( sqrt)
            case "sin": performOperation (sin)
            case "cos": performOperation (cos)
            case "π": performOperation   { M_PI }
            case "±": performOperation   { -$0 }
            default: break
                
            }
         }
    }
    
     @nonobjc func performOperation (operation: () -> Double ){
        displayValue = operation ()
        enter()
    }
 
    @nonobjc func performOperation (operation: Double -> Double ){
        if operandStack.count >= 1 {
            displayValue = operation (operandStack.removeLast())
            enter()
        } else {
            displayValue = nil
        }
    }

    
    @nonobjc  func performOperation (operation: (Double, Double) -> Double ){
        if operandStack.count >= 2 {
            displayValue = operation (operandStack.removeLast() , operandStack.removeLast())
            enter()
        } else {
            displayValue = nil
        }
    }
    
    
    var operandStack = Array <Double>()
 
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber {
             history.text =  history.text! + " " + display.text!
        }
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            operandStack.append(value)
        }else {
            displayValue = nil
        }
       print("operandStack = \(operandStack)")
     }
    
    @IBAction func clearAll(sender: AnyObject) {
          history.text =  " "
          displayValue = 0
    }
 
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!).characters.count > 1 {
                display.text = String((display.text!).characters.dropLast())
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
               return numberFormatter().numberFromString(displayText)?.doubleValue
            }
            return nil
        }
        set {
            if (newValue != nil) {
               display.text = numberFormatter().stringFromNumber(newValue!)
            } else {
                display.text = "Error "
            }
            userIsInTheMiddleOfTypingANumber = false

        }
    }
    
    func numberFormatter () -> NSNumberFormatter{
        let numberFormatterLoc = NSNumberFormatter()
        numberFormatterLoc.numberStyle = .DecimalStyle
        numberFormatterLoc.maximumFractionDigits = 10
        numberFormatterLoc.notANumberSymbol = "Error"
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
}

