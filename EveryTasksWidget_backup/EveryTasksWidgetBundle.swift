//
//  EveryTasksWidgetBundle.swift
//  EveryTasksWidget
//
//  Created by cham on 8/3/25.
//

import WidgetKit
import SwiftUI

@main
struct EveryTasksWidgetBundle: WidgetBundle {
    var body: some Widget {
        EveryTasksWidget()
        EveryTasksWidgetControl()
        EveryTasksWidgetLiveActivity()
    }
}
