//Project 1
//CS4220 | Prof. Michael Lee

//Reflections:

//This helped a lot with comprehending how easy it is to stack visual elements into one view.

//  Created by Gabriel Jackson on 6/27/26.
//
//  This 'app' is a simple integer-only calculator.
//
//  The interface was built in Main.storyboard and every button is wired to a
//   @IBAction method below. The result label is wired to
//  `displayLabel` @IBOutlet and all arithmetic state is kept here in the controller.
//

import UIKit
//default apple import for UI

//Our root scene:
class ViewController: UIViewController {

    // MARK: - Outlets

    //This is the outlet for displayLabel to display the current results in the calculator
    @IBOutlet weak var displayLabel: UILabel!

    // MARK: - Calculator State

    //There are 4 operators in our integer calculator and will need similar functions/variables to compute the operands (digits). This is why we need to define enum Operation to hold handle each operation as a case
    
    private enum Operation {
        case add
        case subtract
        case multiply
        case divide
    }

    //Now that we defined the data type for operations, we need variables to handle the state to properly perform the math.
    
    //Note: The first two variables are optional because the first operand has to be type int and there won't always be another operation.
    
    //?This allows us to use isEnteringDigits to prevent the program from crashing because it will continue so long that stays true or false?
    
    //First, we define firstOperand as optional Int because the first operand must be an integer and we dont wan't the program to crash.
    private var firstOperand: Int?

    //Then, we define this variable to store an operation if the user taps on one.
    private var pendingOperation: Operation?

    /// Tracks whether the digits currently shown were typed by the user as part
    /// of the *current* number. When this is `false`, the next digit tapped
    /// starts a brand-new number instead of being appended to what's on screen.
    /// This is what lets results flow into the next calculation without needing
    /// to press Clear in between.
    ///
    ///
    //This variable is assigned false at first because when a user enters digits after completing an operation, we can set it to true to clear the calculator without requiring the user to clear
    private var isEnteringDigits = false

    // MARK: - Lifecycle

    //This is our classic viewDidLoad function that is called after the ViewController Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Therefore, we call the function below to ensure every launch starts at zero
        updateDisplay("0")
    }

    // MARK: - Display Helpers
    
    //Now, we need some helpers to handle the values for display with basic error handling

    /// The integer value currently shown on the display. Falls back to 0 if the
    /// text can't be parsed (e.g. it currently reads "Error").
    //
    //We define this variable displayedValue to return the current results/operand in the calculator as a displayLabel.text on our main scene. OR 0 if it can't be parsed
    private var displayedValue: Int {
        return Int(displayLabel.text ?? "0") ?? 0
    }

    /// Sets the text shown on the display label.
    ///
    //This function updates the display as a String to handle complex digits / error messages
    private func updateDisplay(_ text: String) {
        displayLabel.text = text
    }

    /// Clears all in-progress calculation state (but does not touch the display).
    //This function takes our three variables (for state management) and sets them to nil/false to reset the calculator
    private func resetState() {
        firstOperand = nil
        pendingOperation = nil
        isEnteringDigits = false
    }

    // MARK: - Digit Entry

    /// Handles taps on the number buttons (0–9 and the "00" shortcut).
    /// The digit(s) to add are read straight from the button's title.
    ///
    //This outlet / function digitTapped handles whenever a digit title is tapped
    @IBAction func digitTapped(_ sender: UIButton) {
        //We use currentTitle because it recognizes when a user taps on a title and lets us initialize the constant with a nil value
        guard let digits = sender.currentTitle else { return }
        //Then, if isEnteringDigits exists (which is true and the statement below runs)
        if isEnteringDigits {
            let current = displayLabel.text ?? "0"
            //Assigns the currentTitle.displayLabel.text to our current constant or 0
            
            //
            if current == "0" {
                // Replace a lone leading zero so we don't get "07".
                updateDisplay(digits == "00" ? "0" : digits)
            } else if current == "-0" {
                // Same idea, but keep the negative sign: "-0" + "5" -> "-5".
                updateDisplay(digits == "00" ? "-0" : "-" + digits)
            } else {
                updateDisplay(current + digits)
            }
        } else {
            // Starting a fresh number (first digit after launch, an operator,
            // or "="). "00" on a fresh number is just "0".
            updateDisplay(digits == "00" ? "0" : digits)
            isEnteringDigits = true
        }
    }

    // MARK: - Operations

    /// Handles taps on the four operator buttons (÷, ×, −, +).
    /// The specific operation is determined from the button's title.
    @IBAction func operationTapped(_ sender: UIButton) {
        let operation: Operation
        switch sender.currentTitle {
        case "+":           operation = .add
        case "−", "-":      operation = .subtract   // U+2212 minus sign
        case "×", "x", "X": operation = .multiply
        case "÷", "/":      operation = .divide
        default:            return                   // unknown button, ignore
        }

        if pendingOperation != nil && isEnteringDigits {
            // The user already had a pending operation and then typed a second
            // number before tapping another operator (e.g. "2 + 3 ×").
            // Resolve the previous operation first so calculations chain
            // correctly even without pressing "=".
            performPendingOperation()
        } else {
            // Otherwise the number currently on screen becomes the left operand.
            firstOperand = displayedValue
        }

        pendingOperation = operation
        // The next digit should begin the second number from scratch.
        isEnteringDigits = false
    }

    /// Handles the "=" (Enter) button: performs the most recently tapped
    /// operation on the two numbers entered.
    @IBAction func equalsTapped(_ sender: UIButton) {
        performPendingOperation()
        // After "=", a freshly typed digit starts a new number, but tapping an
        // operator will chain on top of the result we just produced.
        isEnteringDigits = false
    }

    /// Carries out the stored operation using `firstOperand` and whatever number
    /// is currently on the display, then shows the result. The result is kept as
    /// the new `firstOperand` so the user can keep operating on it.
    private func performPendingOperation() {
        guard let operation = pendingOperation, let first = firstOperand else {
            // Nothing to do (e.g. "=" pressed with no operation queued).
            return
        }

        let second = displayedValue
        let result: Int

        switch operation {
        case .add:
            result = first + second
        case .subtract:
            result = first - second
        case .multiply:
            result = first * second
        case .divide:
            // Integer division by zero would crash, so guard against it.
            guard second != 0 else {
                updateDisplay("Error")
                resetState()
                return
            }
            result = first / second
        }

        updateDisplay(String(result))
        firstOperand = result        // allow chaining: result feeds the next op
        pendingOperation = nil
    }

    // MARK: - Other Buttons

    /// Clear / AC button: resets the calculator back to zero.
    @IBAction func clearTapped(_ sender: UIButton) {
        resetState()
        updateDisplay("0")
    }

    /// "+/-" button: flips the sign of the number currently on screen so the
    /// user can enter and compute with negative numbers.
    @IBAction func negateTapped(_ sender: UIButton) {
        let negated = -displayedValue
        updateDisplay(String(negated))
        // Keep editing this same number after flipping its sign.
        isEnteringDigits = true
    }

    /// "%" button: integer-only percent, i.e. divide the current value by 100.
    /// (Not a required feature, included as a small convenience.)
    @IBAction func percentTapped(_ sender: UIButton) {
        let value = displayedValue / 100
        updateDisplay(String(value))
        isEnteringDigits = true
    }
}
