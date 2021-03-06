//
//  LowNetworkClass.swift
//  StudentsApp
//
//  Created by Владислав Захаров on 27.10.17.
//  Copyright © 2017 Владислав Захаров. All rights reserved.
//

import UIKit

class LowNetworkClass: NSObject {
    
    func sendDataWith<T>(URL: String, type: T.Type, andCompletitionBlock: @escaping (T?) -> Void, dataToSend:String?) where T:Decodable{
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 7.0
        sessionConfiguration.timeoutIntervalForResource = 7.0
        
        let defaultSession = URLSession(configuration: sessionConfiguration)
        var dataTask: URLSessionDataTask?
        dataTask?.cancel()
        
        let encodedString = URL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        if var urlComponents = URLComponents(string: encodedString!) {
            guard let url = urlComponents.url else {
                print("BadComponents.url")
                andCompletitionBlock(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = "data=\(dataToSend ?? "null")"
            request.httpBody = postString.data(using: .utf8)
            dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { dataTask = nil }
                //If Error of connection came
                if let error = error {
                    let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                    print(errorMessage)
                    andCompletitionBlock(nil)
                } else if let data = data,
                    //If connection is good and we got something
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do{
                        let decoder = JSONDecoder()
                        print("Init data respons \(data)")
                        let studyPlaceUnit = try decoder.decode(type, from: data)
                        //print(studyPlaceUnit)
                        andCompletitionBlock(studyPlaceUnit)
                    } catch{
                        print("Error with parsing json. \(error.localizedDescription)")
                        andCompletitionBlock(nil)
                    }
                }else{
                    print("No error, but statusCode != 200")
                    andCompletitionBlock(nil)
                }
            }
            dataTask?.resume()
        }else{
            andCompletitionBlock(nil)
            print("BadComponents with string")
        }
    }
    
    func getJsonWith<T>(URL: String, type: T.Type, andCompletitionBlock: @escaping (T?) -> Void) where T:Decodable{
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 7.0
        sessionConfiguration.timeoutIntervalForResource = 7.0
        
        let defaultSession = URLSession(configuration: sessionConfiguration)
        var dataTask: URLSessionDataTask?
        dataTask?.cancel()
        
        let encodedString = URL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        if var urlComponents = URLComponents(string: encodedString!) {
            guard let url = urlComponents.url else {
                print("BadComponents.url")
                andCompletitionBlock(nil)
                return
            }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                //If Error of connection came
                if let error = error {
                    let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                    print(errorMessage)
                    andCompletitionBlock(nil)
                } else if let data = data,
                    //If connection is good and we got something
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do{
                        let decoder = JSONDecoder()
                        print("Init data respons \(data)")
                        let studyPlaceUnit = try decoder.decode(type, from: data)
                        //print(studyPlaceUnit)
                        andCompletitionBlock(studyPlaceUnit)
                    } catch{
                        print("Error with parsing json. \(error.localizedDescription)")
                        andCompletitionBlock(nil)
                    }
                }else{
                    print("No error, but statusCode != 200")
                    andCompletitionBlock(nil)
                }
            }
            dataTask?.resume()
        }else{
            andCompletitionBlock(nil)
            print("BadComponents with string")
        }
    }
    
    func jetRawJson(URL: String, andCompletitionBlock: @escaping (Any?) -> Void){
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 15.0
        sessionConfiguration.timeoutIntervalForResource = 15.0
        
        let defaultSession = URLSession(configuration: sessionConfiguration)
        var dataTask: URLSessionDataTask?
        dataTask?.cancel()
        
        let encodedString = URL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        if var urlComponents = URLComponents(string: encodedString!) {
            guard let url = urlComponents.url else {
                print("BadComponents.url")
                andCompletitionBlock(nil)
                return
            }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                //If Error of connection came
                if let error = error {
                    let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                    print(errorMessage)
                    andCompletitionBlock(nil)
                } else if let data = data,
                    //If connection is good and we got something
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do{
                        //let type = studyPlaceResponse.self
                        let json = try JSONSerialization.jsonObject(with: data)
                        //print("Got JSON - \(json)")
                        andCompletitionBlock(json)
                    } catch{
                        print("Error with parsing json")
                        andCompletitionBlock(nil)
                    }
                }else{
                    print("No error, but statusCode != 200")
                    andCompletitionBlock(nil)
                }
            }
            dataTask?.resume()
        }else{
            andCompletitionBlock(nil)
            print("BadComponents with string")
        }
    }
    
}
