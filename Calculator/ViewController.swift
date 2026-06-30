//Professor Michael Lee | CS4220
//Gabriel Jackson
//Jun 29, 2026
//Proj. 1 | Calculator

// MARK: Table of Contents

//Reflections:

//I was overwhlemed with the recipe book because I experimented with data persistence & CRUD like behavior, which just made the UI seem more confusing. Therefore, this assignment helped me a lot with actually comprehending why storyboard is easier for layout building (and the lecture videos showed why using nested stack views can be advantageous). Overall, this is definitely what I needed to get more comfortable with Storyboard.

//UIStackView is great because I can use 5 nested horizontal UIStackViews to hold all 20 UIButtons (5 rows * 4 buttons). Overall, setting up this layout, styling the UI components, and setting the constraints felt a lot more intuitive than the recipe book.

// MARK: Intro

//  This 'app' is a simple integer-only calculator.
//
//The interface was built in Main.storyboard and almost every button is wired to a
//   @IBAction method below (the decimal button is purely decorative and has no function since we only do integer math). The result label is wired to `displayLabel` @IBOutlet and all arithmetic state is kept here in the controller.
//
//All buttons use touchUpInside events, which triggers the relevant @IBAction code block only when a user taps the button and lifts their finger while it is still inside the button's boundaries.

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
        
        //These cases can be utilized with switch later on in the program, in which we will be able to define the function / basic integer math for each operation case.
        case add
        case subtract
        case multiply
        case divide
    }

    //Now that we defined the data type for operations, we need variables to handle the state to properly perform the math.
    
    //Note: The first two variables are optional because the first operand has to be type int and there won't always be another operation.
        
    //First, we define firstOperand as optional Int because the first operand must be an integer and we dont wan't the program to crash.
    private var firstOperand: Int?

    //Then, we define this variable to store an operation if the user taps on one.
    private var pendingOperation: Operation?

    //isEnteringDigits is assigned false at first because nothing has been typed yet. We set it to true once the user starts entering a number (so the next digit appends), and back to false after an operator or "=" so the next digit starts a fresh number.
    private var isEnteringDigits = false

    // MARK: - Lifecycle

    //This is our classic viewDidLoad function that is called after the ViewController Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Therefore, we call the function below to ensure every launch starts at zero
        updateDisplay("0")
    }

    // MARK: - Display Helpers
    
    //I defined this variable displayedValue as Int because we take the current results/operand from displayLabel.text on our main scene and return it as an Int. The "?? 0" fallback catches text that can't be parsed into an Int (like "Error" after a divide-by-zero) or a nil label, defaulting it to 0.
    private var displayedValue: Int {
        return Int(displayLabel.text ?? "0") ?? 0
    }

    //This function updates the display as a String to handle complex digits / error messages
    private func updateDisplay(_ text: String) {
        displayLabel.text = text
    }

    //This function takes our three variables (for state management) and sets them to nil/false to reset the calculator
    private func resetState() {
        firstOperand = nil
        pendingOperation = nil
        isEnteringDigits = false
    }

    
    // MARK: - Digit Entry
    
    //This outlet / function digitTapped activates whenever a digit UIbutton is tapped
    @IBAction func digitTapped(_ sender: UIButton) {
        
        
        //We assign digits to the value of the tapped digit buttons own title (currentTitle). Also, guard let is extremely important here b/c it means digits takes in an optional string to safely unwrap later.
        guard let digits = sender.currentTitle else { return }
        
        //Then, if isEnteringDigits is true (the user is mid-entry on a number)
        if isEnteringDigits {

            //We assign whatever is currently on the display label to our current constant (or "0" if the label's text is somehow nil)
            let current = displayLabel.text ?? "0"

            //Now we check what's already on screen so we can append the new digit cleanly
            if current == "0" {
                //If it's just a lone zero, we replace it so we don't end up with something like "067" (and "00" tapped on a "0" just stays "0")
                updateDisplay(digits == "00" ? "0" : digits)
            } else if current == "-0" {
                //Same idea but we keep the negative sign, so "-0" + "5" becomes "-5"
                updateDisplay(digits == "00" ? "-0" : "-" + digits)
            } else {
                //Otherwise we just add the new digit(s) onto the end of the current
                updateDisplay(current + digits)
            }
        } else {
            //Else, isEnteringDigits is false, so this digit starts a fresh number and we replace whatever was on screen with the digit the user just tapped (or "0" if they tapped "00")
            updateDisplay(digits == "00" ? "0" : digits)
            //and we flip isEnteringDigits to true since we're now mid-entry on a number
            isEnteringDigits = true
        }
    }

    // MARK: - Operations

    //This function operationTapped fires whenever one of the four operator outlet buttons is tapped
    @IBAction func operationTapped(_ sender: UIButton) {
        //First, we initialize the operation constant and use switch to read which operator the user tapped on. Each case assigns the relevant function (add, subtract) to the operation constant if its a match.
        let operation: Operation
        switch sender.currentTitle {
        case "+":           operation = .add
        case "−", "-":      operation = .subtract
        case "×", "x", "X": operation = .multiply
        case "÷", "/":      operation = .divide
        default:            return    //If the title is somehow unknown, we just ignore the tap by just returning
        }
        
        //If pendingOperation has a value (operation) AND the user is entering digits
        if pendingOperation != nil && isEnteringDigits {
           //We perform the pending operation
            performPendingOperation()
            
        } else {
            //Otherwise the number currently on screen becomes our firstOperand
            firstOperand = displayedValue
        }
        //Then we store the case : operation into pendingOperation
        pendingOperation = operation
        
        //And set isEnteringDigits to false so the next digit starts the second number from scratch (does not accumulate if another operation is tapped)
        isEnteringDigits = false
    }

    //This function equalsTapped handles the "=" (Enter) button / outlet
    @IBAction func equalsTapped(_ sender: UIButton) {
        
        //Therefore, we run the pending operation function on the first & second operands display
        performPendingOperation()
        
        //We set isEnteringDigits to false so a freshly typed digit starts a brand-new number instead of appending to the result. (Tapping an operator next still chains onto the result)
        isEnteringDigits = false
    }

   
    //This is the function that performs the math based off pendingOperation and displays the result
    private func performPendingOperation() {
        
        //First, we unwrap the relevant operator case from pendingOperation and assign it to operation. We also assign firstOperand to first. If these do not exist, we return.
        guard let operation = pendingOperation, let first = firstOperand else {
            return
        }

        //Defines our second operand constant as whatever number is currently on the display
        let second = displayedValue
        
        // Defines / initializes the type of our constant, result, as Int, since this is integer-only math
        let result: Int

        //Then we use swtich to perform the relevant operation case for each operator butto and ensures the correct math is being performed.
        switch operation {
        case .add:
            result = first + second
        case .subtract:
            result = first - second
        case .multiply:
            result = first * second
        case .divide:
            //Dividing by zero would crash the app, so we guard against it and show "Error" + reset instead of doing the division
            guard second != 0 else {
                updateDisplay("Error")
                resetState()
                //Clears the calculator (resets state to program start)
                return
            }
            result = first / second //Calculates integer division
        }

        //Finally, we show the result, keep it as firstOperand so the user can keep operating on it, and clear the pending operation by resetting it to nil.
        updateDisplay(String(result))
        firstOperand = result
        pendingOperation = nil
    }

    //This function clearTapped is our AC button, it wipes the state with resetState() and shows 0 again
    @IBAction func clearTapped(_ sender: UIButton) {
        resetState()
        updateDisplay("0")
    }

 
    //This function negateTapped is the "+/-" button, it's how we support negative numbers
    @IBAction func negateTapped(_ sender: UIButton) {
        //We negate whatever value is currently on the display and show it back
        let negated = -displayedValue
        //We update the display as a string to handle the negative sign -
        updateDisplay(String(negated))
        //We keep isEnteringDigits true so the user can keep editing this same number after flipping its sign
        isEnteringDigits = true
    }

    //This function percentTapped handles "%". Since we're integer-only, it just divides the current value by 100. This wasn't a required feature, I added it as a small convenience
    @IBAction func percentTapped(_ sender: UIButton) {
        let value = displayedValue / 100
        updateDisplay(String(value))
        isEnteringDigits = true
    }
}
