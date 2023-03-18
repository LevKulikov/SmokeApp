//
//  SmokeWidgetBundle.swift
//  SmokeWidget
//
//  Created by Лев Куликов on 05.02.2023.
//

import WidgetKit
import SwiftUI

@main
struct SmokeWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmokeWidget()
        SmokeWidgetLiveActivity()
    }
}
