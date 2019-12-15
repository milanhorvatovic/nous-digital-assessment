//
//  ModelServiceItem.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    struct Item {
        
        let identifier: Int
        private let titleValue: String?
        private let descriptionValue: String?
        private let imageURLString: String?
        
    }
    
}

extension Model.Service.Item: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case identifier = "id"
        case titleValue = "title"
        case descriptionValue = "description"
        case imageURLString = "imageUrl"
        
    }
    
}

extension Model.Service.Item: Equatable { }

extension Model.Service.Item {
    
    var title: String {
        guard let value = self.titleValue,
            !value.isEmpty
            else {
            return ""
        }
        return value
    }
    
    var description: String {
        guard let value = self.descriptionValue,
            !value.isEmpty
            else {
            return ""
        }
        return value
    }
    
    var imageURL: URL? {
        guard let value = self.imageURLString,
            !value.isEmpty
            else {
            return nil
        }
        return URL(string: value)
    }
    
}
