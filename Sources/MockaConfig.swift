//
//  MockaConfig.swift
//  Mocka
//
//  Created by Markus Gasser on 24.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import Foundation


public class MockaConfig {

    public static var failureReporter: (message: String, file: String, line: UInt) -> Void = { message, file, line in
        fatalError("\(file):\(line): \(message)")
    }
}
