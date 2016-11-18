//
//  GCDBlackBox.swift
//  TightKnit
//
//  Created by Adam Zarn on 11/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    DispatchQueue.main.async() {
        updates()
    }
}
