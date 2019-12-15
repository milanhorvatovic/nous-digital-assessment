//
//  ListViewModel.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import Strongify
import RxSwift
import RxRelay
import RxSwiftExt
import RxOptional
import Action

protocol ListDataLoader {
    
    typealias ModelType = Model.Service.Item
    
    func loadItems() -> Observable<[ModelType]>
    
}

extension DataLoader: ListDataLoader { }

protocol ListViewModelProtocol {
    
    typealias ModelType = Model.Service.Item
    
    var data: Observable<[ModelType]> { get }
    var error: Observable<Swift.Error> { get }
    var isLoading: Observable<Bool> { get }
    
    var searchTerm: BehaviorRelay<String> { get }
    
    var fetchAction: Action<Void, [ModelType]> { get }
    
    init(dataLoader: ListDataLoader)
    
}

final class ListViewModel: ListViewModelProtocol {
    
    let dataLoader: ListDataLoader
    
    private let disposeBag = DisposeBag()
    
    private let receivedDataSubject = BehaviorRelay<[ModelType]>(value: [])
    
    private let dataSubject = PublishSubject<[ModelType]>()
    var data: Observable<[ModelType]> {
        return self.dataSubject
            .asObservable()
            .distinctUntilChanged()
    }
    var error: Observable<Swift.Error> {
        return self.fetchAction.underlyingError
    }
    
    var isLoading: Observable<Bool> {
        return self.fetchAction.executing
    }
    
    let searchTerm = BehaviorRelay<String>(value: "")
    
    private(set) lazy var fetchAction: Action<Void, [ModelType]> = self.createFetchAction()
    
    init(dataLoader: ListDataLoader) {
        self.dataLoader = dataLoader
        
        self.fetchAction
            .elements
            .bind(to: self.receivedDataSubject)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.receivedDataSubject,
                                 self.searchTerm)
            .map({ (items, term) -> [ModelType] in
                guard !term.isEmpty else {
                    return items
                }
                let term = term.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return items.filter(matching: Predicate { $0.title.lowercased().contains(term) } || Predicate { $0.description.lowercased().contains(term) } )
            })
            .distinctUntilChanged()
            .bind(to: self.dataSubject)
            .disposed(by: self.disposeBag)
    }
    
}

// MARK: - Create
extension ListViewModel {
    
    private func createFetchAction() -> Action<Void, [ModelType]> {
        return Action { [unowned self] () -> Observable<[ModelType]> in
            return self.dataLoader.loadItems()
        }
    }
    
}
