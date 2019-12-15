//
//  DataLoader.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxSwift
import RxSwiftExt

import Alamofire
import RxAlamofire

final class DataLoader {
    
    enum InitError: Swift.Error {
        
        case invalidBase
        
    }
    
    enum LoadingError: Swift.Error {
        
        case network
        case noConnection
        case mapping
        
    }
    
    let baseURL: URL
    let engine: NetworkEngine
    
    // MARK: - Init
    init(base: String,
         engine: NetworkEngine) throws {
        guard let url = URL(string: base) else {
            throw Error(with: InitError.invalidBase)
        }
        self.baseURL = url
        self.engine = engine
    }
    
    // MARK: -
    // MARK: Load
    func loadItems() -> Observable<[Model.Service.Item]> {
        do {
            let request = try self._constructRequest(with: "/s/rNPWPNWKwK7kZcS/download")
            return self.engine
                .perform(request: request)
                //.debug("Received data:")
                .catchError({ (error) -> Observable<Data> in
                    guard let urlError = error as? URLError,
                        [URLError.networkConnectionLost,
                         URLError.timedOut].contains(urlError.code) else {
                        return Observable.error(Error(with: LoadingError.network, underlyingError: error))
                    }
                    return Observable.error(Error(with: LoadingError.noConnection, underlyingError: error))
                })
                .map({ (data) -> Model.Service.Items in
                    return try JSONDecoder().decode(Model.Service.Items.self,
                                                    from: data)
                })
                .catchError({ (error) -> Observable<Model.Service.Items> in
                    guard error is DecodingError else {
                        return Observable.error(error)
                    }
                    return Observable.error(Error(with: LoadingError.mapping,
                                                  underlyingError: error))
                })
                .map({ (items) -> [Model.Service.Item] in
                    return items.items
                })
                //.debug("Received items:")
                .share(replay: 1,
                       scope: .forever)
        }
        catch {
            return Observable.error(error)
        }
    }
   
    // MARK: - Private
    private func _constructRequest(with relativePath: String) throws -> Request {
        return try Request(base: self.baseURL,
                           relativePath: relativePath)
    }
    
}

extension DataLoader.InitError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidBase:
            return "An instance couldn't be constructed due to invalid base URL string representation. Please contact support."
        }
    }
    
}

extension DataLoader.LoadingError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .network:
            return "The operation couldn’t be completed due to complication(s) with the network. Please check your connection."
        case .noConnection:
            return "The operation couldn’t be completed due to there is no internet connection. Please check your connection."
        case .mapping:
            return "The operation couldn’t be completed due to error(s) with mapping. Please contact support."
        }
    }
    
}
