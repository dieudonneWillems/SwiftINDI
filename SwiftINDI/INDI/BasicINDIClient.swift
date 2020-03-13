//
//  BasicINDIClient.swift
//  SwiftINDI
//
//  Created by Don Willems on 10/03/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation
import SwiftSocket

public class BasicINDIClient {
    
    public let server : String
    public let port : Int
    
    public init(server: String, port: Int) {
        self.server = server
        self.port = port
        
        let client = TCPClient(address: self.server, port: Int32(port))
        switch client.connect(timeout: 1) {
          case .success:
            switch client.send(string: "<getProperties version=\"1.7\"/>" ) {
              case .success:
                sleep(1)
                guard let data = client.read(1024*10) else {
                    print("Did not recieve data")
                    return
                }
                print("received data")
                if let response = String(bytes: data, encoding: .utf8) {
                  print("******** RESPONSE ********\n\(response)")
                }
              case .failure(let error):
                print(error)
            }
          case .failure(let error):
            print(error)
        }
    }
}
