//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
	
	let swifter = Swifter(consumerKey: TwitterAPI(named: "Twitter_API"),
						  consumerSecret: TwitterAPI(named: "Twitter_API_secret"))
	let sentimentClassifier = try! TweetSentimentClassifier(configuration: MLModelConfiguration.init())

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
		swifter.searchTweet(using: textField.text!, lang: "en", count: 100, tweetMode: .extended) { (results, metadata) in
			
			var tweets = [TweetSentimentClassifierInput]()
			
			for i in 0 ..< 100 {
				if let tweet = results[i]["full_text"].string {
					let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
					tweets.append(tweetForClassification)
				}
			}
			
			do {
				let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
				var sentimentScore = 0
				
				for prediction in predictions {
					let sentiment = prediction.label
					if sentiment == "Neg" {
						sentimentScore -= 1
					} else if sentiment == "Pos" {
						sentimentScore += 1
					}
				}
				self.adaptSentimentLabel(globalSentimentScore: sentimentScore)
			} catch {
				print(error)
			}
			
		} failure: { (error) in
			print("There was an aerror with the Twitter API Request, \(error)")
		}
    }
	
	func adaptSentimentLabel(globalSentimentScore sentimentScore: Int) {
		if sentimentScore > 20 {
			self.sentimentLabel.text = "😍"
		} else if sentimentScore > 10 {
			self.sentimentLabel.text = "😃"
		} else if sentimentScore > 0 {
			self.sentimentLabel.text = "🙂"
		} else if sentimentScore == 0 {
			self.sentimentLabel.text = "😐"
		} else if sentimentScore > -10 {
			self.sentimentLabel.text = "😕"
		} else if sentimentScore > -20 {
			self.sentimentLabel.text = "😡"
		} else {
			self.sentimentLabel.text = "🤮"
		}
	}
    
}


fileprivate func TwitterAPI(named name: String) -> String {
	guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
	  fatalError("Couldn't find file 'Secrets.plist'.")
	}
	let plist = NSDictionary(contentsOfFile: filePath)
	guard let api = plist?.object(forKey: name) as? String else {
	  fatalError("Couldn't find key '\(name)' in 'Secrets.plist'.")
	}
	return api
}
