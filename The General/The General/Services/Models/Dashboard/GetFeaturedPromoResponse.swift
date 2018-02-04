//
//  GetFeaturedPromoResponse.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/19/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct GetFeaturedPromoResponse: Decodable {

    let type: String?
    let imageUrl: String?
    let actionUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case extra = "extra"
        
        case type
        case imageUrl = "image_url"
        case actionUrl = "action_url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let extraValues = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .extra) {
            self.type = try? extraValues.decode(String.self, forKey: .type)
            self.imageUrl = try? extraValues.decode(String.self, forKey: .imageUrl)
            self.actionUrl = try? extraValues.decode(String.self, forKey: .actionUrl)
        } else {
            self.type = nil
            self.imageUrl = nil
            self.actionUrl = nil
        }
    }
}
