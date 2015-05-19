//
//  WeatherViewController.swift
//  FireWeather
//
//  Created by Andela Developer on 5/13/15.
//  Copyright (c) 2015 Andela. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    var rootRef = Firebase(url:"https://fireweather.firebaseio.com/")

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var containerView: UIView!
    var weatherArray = [Weather]()
    
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var rainfall: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshWeatherForcast(self)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            if let json = JSON(snapshot.value!) as JSON?{
                
                self.title = json["cities", "lagos,ng", "dailyForcast", "name"].stringValue
                self.weatherType.text = json["cities", "lagos,ng", "dailyForcast", "weather", 0, "description"].stringValue
                var temp = json["cities", "lagos,ng", "dailyForcast", "main", "temp"].double
                self.temperature.text = String(Int(round(temp!))) + "\u{00B0}"
                self.weatherImage.image = UIImage(named: json["cities", "lagos,ng", "dailyForcast", "weather", 0, "main"].stringValue)
                self.humidity.text = json["cities", "lagos,ng", "dailyForcast", "main", "humidity"].stringValue + "%"
                if let rain = json["cities", "lagos,ng", "dailyForcast", "rain", "3h"].stringValue as String?{
                    self.rainfall.text = rain + "mm"
                } else {
                    self.rainfall.text = "0mm"
                }
                self.windSpeed.text = json["cities", "lagos,ng", "dailyForcast", "wind", "speed"].stringValue + "mph"
                self.setBackgroundColor(self.firstView, temperature: String(Int(round(json["cities", "lagos,ng", "dailyForcast", "main", "temp_min"].double!))))
                self.navigationController?.navigationBar.barTintColor = self.firstView.backgroundColor
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
                
                var jsonArray = json["cities", "lagos,ng", "5DaysForcast"] as JSON
                for(var i=1; i<6; i++) {
                    var weather = Weather(weatherImage: jsonArray[i, "weather", "main"].stringValue,
                        day: jsonArray[i, "day"].stringValue,
                        minTemperature: jsonArray[i, "temperature", "min"].stringValue,
                        maxTemperature: jsonArray[i, "temperature", "max"].stringValue)
                    self.weatherArray.append(weather)
                }
                self.createBottomViews()
            }
        })
    }
    
    @IBAction func refreshWeatherForcast(sender: AnyObject) {
        request(.GET, "http://fire-weather.herokuapp.com/api/v1/")
        .responseJSON{(request, response, data, error) in
            println(data)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackgroundColor(myview: UIView, temperature: String) {
        var temp: Int = temperature.toInt()!
        if(temp < 18) {
            myview.backgroundColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        }else if(temp < 23 && temp >= 18) {
            myview.backgroundColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0)
        }else if(temp < 28 && temp >= 23) {
            myview.backgroundColor = UIColor(red: 71/255.0, green: 147/255.0, blue: 71/255.0, alpha: 1.0)
        }else if(temp < 33 && temp >= 28) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 173/255.0, blue: 92/255.0, alpha: 1.0)
        }else if(temp < 38 && temp >= 33) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 163/255.0, blue: 71/255.0, alpha: 1.0)
        }else if(temp < 43 && temp >= 38) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 153/255.0, blue: 0/255.0, alpha: 1.0)
        }else if(temp > 43) {
            myview.backgroundColor = UIColor(red: 230/255.0, green: 138/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
    
    func createBottomViews() {
        for(var count:CGFloat = 0; count<5; count++) {
            var viewHeight:CGFloat = self.containerView.frame.size.height / 5
            let bottomView: UIView = UIView()
            bottomView.frame = CGRectMake(0, self.containerView.frame.origin.y + count * viewHeight, self.containerView.frame.size.width, self.containerView.frame.size.height / 5)
            setBackgroundColor(bottomView, temperature: weatherArray[Int(count)].minTemperature)
            self.view.addSubview(bottomView)
            
            let dayLabel: UILabel = UILabel()
            let minTempLabel: UILabel = UILabel()
            let maxTempLabel: UILabel = UILabel()
            let imageView: UIImageView = UIImageView()
            
            imageView.image = UIImage(named: weatherArray[Int(count)].weatherImage)
            
            dayLabel.text = weatherArray[Int(count)].day
            dayLabel.textColor = UIColor.whiteColor()
            dayLabel.font = UIFont(name: "AvenirNext-DemiBold", size: CGFloat(17))
            
            minTempLabel.text = weatherArray[Int(count)].minTemperature + "\u{00B0}"
            minTempLabel.textColor = UIColor.whiteColor()
            minTempLabel.font = UIFont(name: "AvenirNext-DemiBold", size: CGFloat(14))
            
            maxTempLabel.text = " / " + weatherArray[Int(count)].maxTemperature + "\u{00B0}"
            maxTempLabel.textColor = UIColor.whiteColor()
            maxTempLabel.font = UIFont(name: "AvenirNext-DemiBold", size: CGFloat(17))
            
            dayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            minTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            maxTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            bottomView.addSubview(dayLabel)
            bottomView.addSubview(minTempLabel)
            bottomView.addSubview(maxTempLabel)
            bottomView.addSubview(imageView)

            var dayLabelConstraintX = NSLayoutConstraint(item: dayLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
            var dayLabelConstraintY = NSLayoutConstraint(item: dayLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(dayLabelConstraintX)
            bottomView.addConstraint(dayLabelConstraintY)
            
            var maxTempLabelConstraintX = NSLayoutConstraint(item: maxTempLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10)
            var maxTempLabelConstraintY = NSLayoutConstraint(item: maxTempLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(maxTempLabelConstraintX)
            bottomView.addConstraint(maxTempLabelConstraintY)
            
            var minTempLabelConstraintX = NSLayoutConstraint(item: minTempLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: maxTempLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            var minTempLabelConstraintY = NSLayoutConstraint(item: minTempLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(minTempLabelConstraintX)
            bottomView.addConstraint(minTempLabelConstraintY)
            
            var imageViewConstraintX = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: minTempLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -10)
            var imageViewConstraintY = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            var imageViewContraintHeight = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Height, multiplier: 0.75, constant: 0)
            var imageViewConstraintWidth = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            bottomView.addConstraint(imageViewConstraintX)
            bottomView.addConstraint(imageViewConstraintY)
            bottomView.addConstraint(imageViewContraintHeight)
            bottomView.addConstraint(imageViewConstraintWidth)
        }
    }

}








