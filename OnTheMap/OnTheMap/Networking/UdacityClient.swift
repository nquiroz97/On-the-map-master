//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Neri Quiroz on 11/18/20.
//

import Foundation

class UdacityClient: NSObject {
    
    static let appKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    struct Auth {
        static var sessionId: String? = nil
        static var key = ""
        static var firstName = "Neri"
        static var lastName = "Quiroz"
        static var objectId = ""
    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case udacitySignUp
        case udacityLogin
        case getStudentLocations
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        
        var stringValue: String {
            switch self {
            case .udacitySignUp:
                return "https://auth.udacity.com/sign-up"
            case .udacityLogin:
                return Endpoints.base + "/session"
            case .getStudentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation/" + Auth.objectId
            case .getLoggedInUserProfile:
                return Endpoints.base + "/users/" + Auth.key
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    override init() {
        super.init()
    }
 
    class func shared() -> UdacityClient {
        struct Singleton {
            static var shared = UdacityClient()
        }
        return Singleton.shared
    }
    
    // MARK: Log In
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        RequestHelperMethods.taskForPOSTRequest(url: Endpoints.udacityLogin.url, apiType: "Udacity", responseType: LoginResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                getLoggedInUserProfile(completion: { (success, error) in
                    if success {
                        print("Logged in user's profile fetched.")
                    }
                })
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    // MARK: Get Logged In User's Name
    
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        RequestHelperMethods.taskForGETRequest(url: Endpoints.getLoggedInUserProfile.url, apiType: "Udacity", responseType: StudentProfile.self) { (response, error) in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get user's profile.")
                completion(false, error)
            }
        }
    }
    
    // MARK: Log Out
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.udacityLogin.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    // MARK: Get All Students
    
    class func getStudentLocations(completion: @escaping ([StudentsLocations]?, Error?) -> Void) {
        RequestHelperMethods.taskForGETRequest(url: Endpoints.getStudentLocations.url, apiType: "Parse", responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    // MARK: Add a Location
   
    class func addStudentLocation(information: StudentsLocations, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelperMethods.taskForPOSTRequest(url: Endpoints.addLocation.url, apiType: "Parse", responseType: CreateNewStudentLocationResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response, response.createdAt != nil {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    // MARK: Update Location
 
    class func updateStudentLocation(information: StudentsLocations, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelperMethods.taskForPOSTRequest(url: Endpoints.updateLocation.url, apiType: "Parse", responseType: UpdateStudentLocationResponse.self, body: body, httpMethod: "PUT") { (response, error) in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }

}
