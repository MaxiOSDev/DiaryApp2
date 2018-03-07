//
//  LocationManager.swift
//  Diary App
//
//  Created by Max Ramirez on 2/20/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}
// Straight up taught all of these from the courses, mainly Resturant Reviews Course
enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedCoordinates(_ coordinate: Coordinate)
    func failedWithError(_ error: LocationError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    
    init(delegate: LocationManagerDelegate?, permissionDelegate: LocationPermissionsDelegate?) {
        self.delegate = delegate
        self.permissionDelegate = permissionDelegate
        super.init()
        manager.delegate = self
    }
    
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: return true
        default: return false
        }
    }
    
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        } else if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func requestLocation() {
        //     manager.requestLocation() // Slow at accquiring location
        manager.startUpdatingLocation() // Fast at getting location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            permissionDelegate?.authorizationSucceeded()
            requestLocation()
        } else {
            permissionDelegate?.authorizationFailedWithStatus(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        
        switch error.code {
        case .locationUnknown, .network: delegate?.failedWithError(.unableToFindLocation)
        case .denied: delegate?.failedWithError(.disallowedByUser)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        
        let coordinate = Coordinate(location: location)
        print("Coordinates \(coordinate.latitude) \(coordinate.longitude)")
        delegate?.obtainedCoordinates(coordinate)
    }
}
