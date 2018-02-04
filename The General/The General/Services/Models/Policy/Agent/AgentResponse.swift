//
//  AgentResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 05/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct AgentResponse: Decodable {

    let mailingAddress: String
    let mailingCity: String
    let mailingState: String
    let mailingZip: String
    let homePhone: String
    let workPhone: String
    let garagingAddress: String?
    let garagingCity: String?
    let garagingState: String?
    let garagingZip: String?
    let thirdPartyName: String?
    let thirdPartyAddress1: String?
    let thirdPartyAddress2: String?
    let thirdPartyCity: String?
    let thirdPartyState: String?
    let thirdPartyZip: String?
    let agentName: String
    let agentAddress: String
    let agentCity: String
    let agentState: String
    let agentZip: String
    let agentPhone: String
    let agentEmail: String
    let insuredName: String
    
}
