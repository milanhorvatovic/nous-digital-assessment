//
//  ListModel.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import RxDataSources

struct ListSection {
    
    var header: String = "section"
    var items: [Model.Service.Item]
    
}

extension Model.Service.Item: IdentifiableType {
    
    var identity: Int {
        return self.identifier
    }
    
}

extension ListSection: AnimatableSectionModelType {

    var identity: String {
        return self.header
    }
    
    init(original: ListSection, items: [Model.Service.Item]) {
        self = original
        self.items = items
    }

}
