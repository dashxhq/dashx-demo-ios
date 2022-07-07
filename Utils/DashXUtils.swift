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
    static let client2 = getClient2()
    
    // Client using explicit instance
    static let client1 = DashXClient(withPublicKey: "R7De1FaPwj6JkG1aDICbO82V",
                                    baseURI: "https://api.dashx-staging.com/graphql")
    
    static func getClient2() -> DashXClient {
//        DashX.setPublicKey(to: "R7De1FaPwj6JkG1aDICbO82V")
//        DashX.setBaseURI(to: "https://api.dashx-staging.com/graphql")
        
        return DashX
    }
    static func trackEventClient2() {
        client2.track("DashboardScreenViewed", withData: ["user": "DashXDemo"])
    }
}
