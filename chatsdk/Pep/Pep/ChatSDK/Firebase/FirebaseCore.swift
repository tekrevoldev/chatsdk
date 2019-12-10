//
//  CoreFirebase.swift
//  BasicStructureUpdate
//
//  Created by Apple on 06/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

class FirebaseCore {
    var path: Nodes?
    var subPath: String?
    var child: String?
    var subChild: String?
    
    public init(path: Nodes?, subPath: String? = nil, child: String? = nil) {
        self.path = path
        self.subPath = subPath
        self.child = child
    }
    
    func getRef() -> DatabaseReference {
        
        var reference: DatabaseReference = Database.database().reference(withPath: Nodes.Base.rawValue)
        
        if let path = self.path {
            reference = reference.child(path.rawValue)
        }
    
        if let subPath = self.subPath {
            reference = reference.child(subPath)
        }
        
        if let child = self.child {
            reference = reference.child(child)
        }
        
        if let subChild = self.subChild {
            reference = reference.child(subChild)
        }
        
        return reference
    }
    
    func getSingleData<T: Codable>(type: T.Type, completion:  @escaping (Bool, T?) -> ()) {
        getRef().observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if snapshot.exists(), let dict = snapshot.value as? [String: Any] {
                completion(true, self.convertDictToObj(dict: dict, type: type, key: snapshot.key))
            } else {
                completion(false, nil)
            }
        })
    }
    
    func getCollection<T: Codable>(type: T.Type, eventType: DataEventType = .value, sortBy: NodeProperties? = nil, completion:  @escaping (Bool, [T]?) -> ()) {
        var databaseQuery = getRef().queryLimited(toFirst: UInt(Constants.FETCH_DATA_LIMIT))
        if let sortBy = sortBy {
            databaseQuery = databaseQuery.queryOrdered(byChild: sortBy.rawValue)
        }
        
        addObserver(eventType: eventType, type: type, databaseQuery: databaseQuery, completion: completion)
        
    }
    
    func saveValue(data: [String:Any], completion: @escaping (_ isSuccess: Bool) -> Void, autoId: Bool = false) -> String {
        if autoId {
            let ref = getRef().childByAutoId()
            ref.updateChildValues(data) { (error, ref) in
                completion(error == nil)
            }
            return ref.key ?? ""
        } else {
            getRef().updateChildValues(data) { (error, ref) in
                completion(error == nil)
            }
        }
        
        return ""
        
    }
    
    func searchData<T: Codable>(keyword: String, node: Nodes ,type: T.Type, completion: @escaping (Bool, [T]?) -> ()) {
        getRef().queryOrdered(byChild: node.rawValue).queryStarting(atValue: keyword).queryEnding(atValue: keyword +  "\u{f8ff}").queryLimited(toFirst: UInt(Constants.FETCH_DATA_LIMIT)).observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if snapshot.exists(), let dict = snapshot.value as? [String: Any] {
                completion(true, self.convertDictToArray(dict: dict, type: type))
            } else {
                completion(false, nil)
            }
        })
    }
    
    func fetchByQueryOrderd<T: Codable>(childPath: String ,type: T.Type, eventsType: [DataEventType] = [.value], completion: @escaping (Bool, [T]?) -> ()) {
        
        let databaseQuery = getRef().queryEqual(toValue: childPath).queryLimited(toFirst: UInt(Constants.FETCH_DATA_LIMIT))
        
        eventsType.forEach { (item) in
            addObserver(eventType: item, type: type, databaseQuery: databaseQuery, completion: completion)
        }
    }
    
    func fetch<T: Codable>(type: T.Type, eventsType: [DataEventType] = [.value], completion: @escaping (Bool, T?) -> (), observeForeEver: Bool = false) {
        
        let databaseQuery = getRef().queryLimited(toFirst: UInt(Constants.FETCH_DATA_LIMIT))
        
        eventsType.forEach { (item) in
            addObserver(eventType: item, type: type, databaseQuery: databaseQuery, completion: completion, observeForeEver: observeForeEver)
        }
    }
    
    func addObserver<T: Codable>(eventType: DataEventType = .value,type: T.Type, databaseQuery: DatabaseQuery, completion:  @escaping (Bool, [T]?) -> (), observeForeEver: Bool = false) {
        if eventType == .value && !observeForeEver {
            databaseQuery.observeSingleEvent(of: eventType, with: { snapshot in
                if snapshot.exists(), let dict = snapshot.value as? [String: Any], let obj = self.convertDictToArray(dict: dict, type: type) {
                    completion(true, obj)
                } else {
                    completion(false, nil)
                }
            })
        } else {
            databaseQuery.observe(eventType, with: { snapshot in
                if snapshot.exists(), let dict = snapshot.value as? [String: Any], let obj = self.convertDictToObj(dict: dict, type: type, key: snapshot.key) {
                    var arr: [T] = []
                    arr.append(obj)
                    completion(true, arr)
                } else {
                    completion(false, nil)
                }
            })
        }
    }
    
    func addObserver<T: Codable>(eventType: DataEventType = .value,type: T.Type, databaseQuery: DatabaseQuery, completion:  @escaping (Bool, T?) -> (), observeForeEver: Bool = false) {
        if eventType == .value && !observeForeEver {
            databaseQuery.observeSingleEvent(of: eventType, with: { snapshot in
                if snapshot.exists(), let dict = snapshot.value as? [String: Any], let obj = self.convertDictToObj(dict: dict, type: type, key: snapshot.key) {
                    completion(true, obj)
                } else {
                    completion(false, nil)
                }
            })
        } else {
            databaseQuery.observe(eventType, with: { snapshot in
                if snapshot.exists(), let dict = snapshot.value as? [String: Any], let obj = self.convertDictToObj(dict: dict, type: type, key: snapshot.key) {
                    completion(true, obj)
                } else {
                    completion(false, nil)
                }
            })
        }
    }
    
    private func convertDictToObj<T: Codable>(dict: [String: Any], type: T.Type, key: String) -> T? {
        do {
            
            let obj = try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: dict))
            if let obj = obj as? FirebaseBaseModel {
                obj.key = key
            }
            return obj
        } catch {
            print("convertDictToObj => error")
        }

        return nil
    }
    
    private func convertDictToArray<T: Codable>(dict: [String: Any], type: T.Type) -> [T]? {
        if JSONSerialization.isValidJSONObject(dict) {
            print("convertDictToArray => JSON Valid")
        }
        var array: [T] = []
        
        for (key, value) in dict {
            do {
                let obj = try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: value, options: .prettyPrinted))
                if let obj = obj as? FirebaseBaseModel {
                    obj.key = key
                }
                array.append(obj)
                print("key : " + key)
            }
            catch {
                print("convertDictToArray => error : " + error.localizedDescription)
            }
        }

        return array
    }

    func nextId() -> String {
       return getRef().childByAutoId().key ?? ""
    }
    
}
