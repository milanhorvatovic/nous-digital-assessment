//
//  ListViewModelTests.swift
//  Nous Digital AssessmentTests
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import XCTest

@testable import Nous_Digital_Assessment

import RxSwift
import Action

import RxTest

class ListViewModelTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var viewModel: ListViewModel!
    var mocked: [ListViewModel.ModelType]!
    
    override func setUp() {
        super.setUp()
        
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.mocked = DataLoaderMock.Local.loadItems()
    }
    
    func test_local_data_fetch() {
        do {
            self.viewModel = try ListViewModel(dataLoader: self.prepareLocalDataLoader())
            let data = self.scheduler.createObserver([ListViewModel.ModelType].self)
            
            self.viewModel
                .data
                .bind(to: data)
                .disposed(by: self.disposeBag)
            
            self.scheduler.createColdObservable([.next(1, ())])
                .bind(to: self.viewModel.fetchAction)
                .disposed(by: self.disposeBag)
            self.scheduler.start()
            
            XCTAssertEqual(data.events, [.next(1, self.mocked)])
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_local_data_search() {
        do {
            self.viewModel = try ListViewModel(dataLoader: self.prepareLocalDataLoader())
            let data = self.scheduler.createObserver([ListViewModel.ModelType].self)
            
            self.viewModel
                .data
                .bind(to: data)
                .disposed(by: self.disposeBag)
            
            self.scheduler.createColdObservable([.next(10, ())])
                .bind(to: self.viewModel.fetchAction)
                .disposed(by: self.disposeBag)
            self.scheduler.createColdObservable([
                .next(20, "welle"),
                .next(30, "weLLe"),
                .next(40, "stark"),
                .next(50, "Welle"),
                .next(60, ""),
            ])
                .bind(to: self.viewModel.searchTerm)
                .disposed(by: self.disposeBag)
            self.scheduler.start()
            
            let welleSample = self.mocked.filter(matching: Predicate { $0.title.lowercased().contains("welle") } || Predicate { $0.description.lowercased().contains("welle") } )
            let starkSample = self.mocked.filter(matching: Predicate { $0.title.lowercased().contains("stark") } || Predicate { $0.description.lowercased().contains("stark") } )
            
            XCTAssertEqual(data.events, [
                .next(10, self.mocked),
                .next(20, welleSample),
                .next(40, starkSample),
                .next(50, welleSample),
                .next(60, self.mocked),
            ])
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

}

extension ListViewModelTests {
    
    private func prepareLocalDataLoader() throws -> ListDataLoader {
        try DataLoaderMock.localMock()
    }
    
    private func prepareRealDataLoader() throws -> ListDataLoader {
        try DataLoaderMock.realMock()
    }
    
}
