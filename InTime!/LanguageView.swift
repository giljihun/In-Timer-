//
//  SettingView.swift
//  What Mins?
//
//  Created by mobicom on 2023/06/30.
//

import SwiftUI

struct LangaugeView: View {
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            Text(StringData().currentLanguageTitle)
                .font(.largeTitle)
                .bold()

            Image("flag")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(40)

            Text(StringData().currentLanguageContents)
                .font(.title)
            }
    }
}

struct LangaugeView_Previews: PreviewProvider {
    static var previews: some View {
        LangaugeView()
    }
}
