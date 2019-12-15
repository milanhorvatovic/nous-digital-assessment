//
//  DataLoaderMock.swift
//  Nous Digital AssessmentTests
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

@testable import Nous_Digital_Assessment

import Alamofire

import RxSwift

final class DataLoaderMock {
    
    static func localMock() throws -> ListDataLoader {
        return Local()
    }
    
    static func realMock() throws -> ListDataLoader {
        return try DataLoader(base: "https://cloud.nousdigital.net",
                              engine: SessionManager(configuration: URLSessionConfiguration.default))
    }
    
}

extension DataLoaderMock {
    
    final class Local: ListDataLoader {
        
        func loadItems() -> Observable<[ModelType]> {
            return Observable.just(type(of: self).loadItems())
        }
        
        static func loadItems() -> [ModelType] {
            do {
            guard let path = Bundle(for: self).path(forResource: "items_v2", ofType: "json") else {
                fatalError("File not found")
            }
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Model.Service.Items.self, from: data).items
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
        
    }

}
