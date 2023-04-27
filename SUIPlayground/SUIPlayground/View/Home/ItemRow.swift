//
//  MenuItemView.swift
//  SUIPlayground
//
//  Created by Chen Xiao on 2023/3/31.
//

import SwiftUI

struct ItemRow: View {
    let item: MenuItem
    var body: some View {
        HStack {
            Image(systemName: item.image.sysName)
            Text(item.title)
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemRow(item: .example)
    }
}
