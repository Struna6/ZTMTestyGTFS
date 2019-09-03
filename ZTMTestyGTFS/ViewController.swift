//
//  ViewController.swift
//  ZTMTestyGTFS
//
//  Created by Karol Struniawski on 02/09/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

class Vehicle : Decodable, Comparable, Hashable, NSCopying{
    func copy(with zone: NSZone? = nil) -> Any {
        return Vehicle(Lines: Lines, Brigade: Brigade, Lat: Lat, Lon: Lon, Distance: distance!)
    }
    
    static func < (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.distance ?? 0 < rhs.distance ?? 0
    }
    
    static func > (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.distance ?? 0 > rhs.distance ?? 0
    }
    
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.distance == rhs.distance && lhs.Brigade == rhs.Brigade && lhs.Lat == rhs.Lat && lhs.Lon == rhs.Lon
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(distance)
        hasher.combine(Brigade)
        hasher.combine(Lat)
        hasher.combine(Lon)
    }
    
    var Lines : String
    var Brigade : String
    var Lat : Double
    var Lon : Double
    var distance : Int?
    var distanceOffset : Int?
    var status : VehicleStatus?
    var degrees : Double?
    
    func getImageView(mapViewRotation : Double) -> UIImageView?{
        var imageView : UIImageView?
        guard (degrees != nil) else {return nil}
        if let st = status{
            if st == .coming{
                imageView = UIImageView(image: UIImage(named: "greenArrow"))
            }else if st == .recede{
                imageView = UIImageView(image: UIImage(named: "redArrow"))
            }else if st == .stay{
                imageView = UIImageView(image: UIImage(named: "yellowArrow"))
            }
        }
        imageView?.transform = .init(rotationAngle: CGFloat(degrees! + mapViewRotation))
        return imageView
    }
    
    init(Lines : String, Brigade : String, Lat : Double, Lon : Double){
        self.Lines = Lines
        self.Brigade = Brigade
        self.Lat = Lat
        self.Lon = Lon
    }
    
    init(Lines : String, Brigade : String, Lat : Double, Lon : Double, Distance: Int){
        self.Lines = Lines
        self.Brigade = Brigade
        self.Lat = Lat
        self.Lon = Lon
        self.distance = Distance
    }
}

enum VehicleStatus : Decodable{
    init(from decoder: Decoder) throws {
        self = .none
    }
    case coming
    case recede
    case stay
    case none
}

extension VehicleStatus{
    var value : UIColor{
        get{
            switch self {
            case .coming:
                return UIColor(red:0.05, green:0.50, blue:0.25, alpha:1.00)
            case .recede:
                return UIColor(red:0.50, green:0.00, blue:0.01, alpha:1.00)
            case .stay:
                return UIColor(red:0.99, green:0.49, blue:0.04, alpha:1.00)
            case .none:
                return UIColor.black
            }
        }
    }
}

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: "https://www.ztm.poznan.pl/pl/dla-deweloperow/getGtfsRtFile?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ0ZXN0Mi56dG0ucG96bmFuLnBsIiwiY29kZSI6MSwibG9naW4iOiJtaFRvcm8iLCJ0aW1lc3RhbXAiOjE1MTM5NDQ4MTJ9.ND6_VN06FZxRfgVylJghAoKp4zZv6_yZVBu_1-yahlo&file=vehicle_positions.pb")!
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            do{
                let pos = try TransitRealtime_FeedMessage(serializedData: data, extensions: nil, partial: true, options: .init())
                var vehicles = [Vehicle]()
                for row in pos.entity{
                    let lineNum = row.vehicle.trip.routeID
                    let lat = row.vehicle.position.latitude
                    let lon = row.vehicle.position.longitude
                    let brigade = row.vehicle.vehicle.id
                    let vehicle = Vehicle(Lines: lineNum, Brigade: brigade, Lat: Double(lat), Lon: Double(lon))
                    vehicles.append(vehicle)
                }
                for veh in vehicles{
                    print(veh.Lines)
                }
            }catch{
                print(error)
            }
        }
        task.resume()
    }
}

