//
//  DashXUtils.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 30/06/22.
//

import Foundation
import DashX

class DashXUtils {
    // Client using shared/default instance
    static let client1 = getClient()
    
    static func getClient() -> DashXClient {
        DashX.setPublicKey(to: "Obmgjd5Ail9L1UBzI7RpPz2Y")
        DashX.setBaseURI(to: "https://api.dashx-staging.com/graphql")
        DashX.setTargetEnvironment(to: "staging")
        return DashX
    }
    
    static func trackEventClient() {
        client1.track("DashboardScreenViewed", withData: ["user": "DashXDemo"])
    }
    
    static func performIdentify(user: User) {
        let userDetails: [String: Any] = [
            "uid": user.id == nil ? "" : String(user.id!),
            "email": user.email == nil ? "" :  user.email!,
            "name": user.name,
            "firstName": user.firstName == nil ? "" : user.firstName!,
            "lastName": user.lastName == nil ? "" : user.lastName!
        ]
        do {
            try client1.identify(user.id == nil ? "" : String(user.id!), withOptions: userDetails as NSDictionary)
        } catch {
            print("Error: \(error)")
        }
    }
}
