#!/usr/bin/env xcrun swift

import Foundation

class Ball: Comparable {
    let value: Int
    var count = 0
    
    init(number: Int) {
        value = number
    }
    
    func draw() {
        count += 1
    }
    
    var description: String {
        return "Ball \(value): \(count)"
    }
    
    func reset() {
        count = 0
    }
}

func <(lhs: Ball, rhs: Ball) -> Bool {
    return lhs.count < rhs.count
}

func ==(lhs: Ball, rhs: Ball) -> Bool {
    return lhs.value == rhs.value
}

protocol Drawing {
    var finalResult: String { get }
    func go()
    func reset()
}

class CompositeDrawing : Drawing {
    var drawings: [Drawing] = []
    
    init() {}
    
    var finalResult: String {
        var result = "Final composite result:\n"
        for drawing in drawings {
            result += drawing.finalResult + "\n\n"
        }
        return result
    }
    
    func go() {
        for drawing in drawings {
            drawing.go()
        }
        print(finalResult)
    }
    
    func reset() {
        for drawing in drawings {
            drawing.reset()
        }
    }
    
    func append(drawing: Drawing) {
        drawings.append(drawing)
    }
}

class IndividualDrawing : Drawing {
    let MIN_DRAWS = 500000, MIN_EXTRA_DRAWS = 0, MAX_EXTRA_DRAWS = 50000000, NUMBER_OF_PRINTS = 10
    let smallestValue, biggestValue, numberOfBallsToDraw: Int
    var balls = Dictionary<Int, Ball>()
    var maxCount = 0
    
    init(smallest: Int, biggest: Int, amountToDraw: Int) {
        assert(biggest > smallest)
        assert(smallest > 0)
        assert(amountToDraw > 0)
        smallestValue = smallest
        biggestValue = biggest
        numberOfBallsToDraw = amountToDraw
        for index in smallestValue...biggestValue {
            balls.updateValue(Ball(number: index), forKey: index)
        }
    }
    
    convenience init(drawingDefinition: [String]) {
        self.init(smallest:Int(drawingDefinition[0])!, biggest:Int(drawingDefinition[1])!, amountToDraw:Int(drawingDefinition[2])!)
    }
    
    var description: String {
        return "Drawing of \(numberOfBallsToDraw) " + (numberOfBallsToDraw == 1 ? "ball" : "balls") + " from \(smallestValue) to \(biggestValue)\n"
    }
    
    var topBalls: ArraySlice<Ball> {
        let sortedBalls = balls.values.sorted { $0 > $1 }
        let onlyTopBalls = sortedBalls[0..<numberOfBallsToDraw]
        return onlyTopBalls
    }
    
    var tempResult: String {
        var temp = "\(maxCount) repetitions:\n"
        for ball in topBalls {
            temp += ball.description + "\n"
        }
        return temp
    }
    
    var finalResult: String {
        var result = "Final result: \(maxCount) repetitions:\n"
        var ballValues: [Int] = []
        for ball in topBalls {
            ballValues.append(ball.value)
        }
        let sortedBallValues = ballValues.sorted { $0 < $1 }
        for ballValue in sortedBallValues {
            result += " (\(ballValue)) "
        }
        return result
    }
    
    func go() {
        print(description)
        let numberOfDraws = IndividualDrawing.getRandomNumber(max: MAX_EXTRA_DRAWS, min: MIN_EXTRA_DRAWS, offset: MIN_DRAWS)
        let increment: Int = numberOfDraws / NUMBER_OF_PRINTS
	print("Increment: \(increment)")
        var nextPrint = increment
        while maxCount < numberOfDraws {
            drawRandomBall()
            if (maxCount == nextPrint) {
                print(tempResult)
                nextPrint += increment
            }
        }
        print(finalResult)
    }
    
    func drawRandomBall() {
        let randomNumber = IndividualDrawing.getRandomNumber(max: biggestValue, min: smallestValue, offset: smallestValue)
        if let ball = balls[randomNumber] {
            ball.draw()
            maxCount = max(maxCount, ball.count)
        } else {
            print("Couldn't find a ball with value \(randomNumber)")
        }
    }
    
    func reset() {
        for ball in balls.values {
            ball.reset()
        }
        maxCount = 0
    }
    
    class func getRandomNumber(max: Int, min: Int, offset: Int) -> Int {
        return Int.random(in: min..<(max+1))
    }
}

let arguments = CommandLine.arguments
print("Enter number of individual drawings:")
let numberOfDrawings = Int(readLine()!)!
let compositeDrawing = CompositeDrawing()
for index in 1...numberOfDrawings {
    print("Define individual drawing \(index): <smallestValue> <biggestValue> <numberOfBallsToDraw>")
    let drawingDefinition = readLine()!.components(separatedBy: " ")
    let individualDrawing = IndividualDrawing(drawingDefinition: drawingDefinition)
    compositeDrawing.append(drawing: individualDrawing)
}
print("Enter number of repetitions:")
let numberOfRepetitions = Int(readLine()!)!
var result = "\n\n=============================\n\nFinal results, summarized:\n"
for index in 1...numberOfRepetitions {
    compositeDrawing.go()
    result += "Drawing \(index):\n"
    result += compositeDrawing.finalResult + "\n"
    compositeDrawing.reset()
}
print(result)
