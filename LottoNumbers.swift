#!/usr/bin/env xcrun swift

import Foundation

class Ball: Comparable {
    let value: Int
    var count = 0
    
    init(number: Int) {
        value = number
    }
    
    func draw() {
        count++
    }
    
    var description: String {
        return "Ball \(value): \(count)"
    }
}

func <(lhs: Ball, rhs: Ball) -> Bool {
    return lhs.count < rhs.count
}

func ==(lhs: Ball, rhs: Ball) -> Bool {
    return lhs.value == rhs.value
}

class Drawing {
    let MIN_DRAWS = 500000, MIN_EXTRA_DRAWS = 0, MAX_EXTRA_DRAWS = 1000000, NUMBER_OF_PRINTS = 10
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
    
    var description: String {
        return "Drawing of \(numberOfBallsToDraw) " + (numberOfBallsToDraw == 1 ? "ball" : "balls") + " from \(smallestValue) to \(biggestValue)\n"
    }
    
    var topBalls: Slice<Ball> {
        let sortedBalls = sorted(balls.values) { $0 > $1 }
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
        var sortedBallValues = sorted(ballValues) { $0 < $1 }
        for ballValue in sortedBallValues {
            result += " (\(ballValue)) "
        }
        return result
    }
    
    func go() {
        println(description)
        let numberOfDraws = Drawing.getRandomNumber(MAX_EXTRA_DRAWS, min: MIN_EXTRA_DRAWS, offset: MIN_DRAWS)
        let increment: Int = numberOfDraws / NUMBER_OF_PRINTS
        var nextPrint = increment
        while maxCount < numberOfDraws {
            drawRandomBall()
            if (maxCount == nextPrint) {
                println(tempResult)
                nextPrint += increment
            }
        }
        println(finalResult)
    }
    
    func drawRandomBall() {
        var randomNumber = Drawing.getRandomNumber(biggestValue, min: smallestValue, offset: smallestValue)
        if let ball = balls[randomNumber] {
            ball.draw()
            maxCount = max(maxCount, ball.count)
        } else {
            println("Couldn't find a ball with value \(randomNumber)")
        }
    }
    
    class func getRandomNumber(max: Int, min: Int, offset: Int) -> Int {
        return (Int(arc4random()) % (max+1 - min)) + offset
    }
}

let arguments = Process.arguments
//arguments[0] is the file name
if arguments.count < 4 {
    println("Usage: ./LottoNumbers.swift <smallestValue> <biggestValue> <numberOfBallsToDraw>")
} else {
    //no concise way of doing optional binding on more than one value
    Drawing(smallest: arguments[1].toInt()!, biggest: arguments[2].toInt()!, amountToDraw: arguments[3].toInt()!).go()
}