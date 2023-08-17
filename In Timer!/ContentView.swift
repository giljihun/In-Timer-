//
//  ContentView.swift
//  What Mins?
//
//  Created by 길지훈 on 2023/06/01.
//

import SwiftUI
import AVFAudio
import UIKit
import UserNotifications

struct ContentView: View {
    
    let taskIdentifier = "com.example.myBackgroundTask"
    
    // 화면 자동 잠금 기능 비활성화
    init() {
            UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @State private var currentTime: String = ""
    @State private var selectedInterval: Int = 1
    @State private var isUpdatingTime = false
    @State private var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en-US"
    @State private var targetTimeWorkItem: DispatchWorkItem?
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("sectionText") var sectionText: String = UserDefaults.standard.string(forKey: "sectionText") ?? "Country Language Settings"
    @AppStorage("LangText") var LangText: String = UserDefaults.standard.string(forKey: "LangText") ?? "Language"
    @AppStorage("ActText") var ActText: String = UserDefaults.standard.string(forKey: "ActText") ?? "⚡️ Activating ⚡️"
    @AppStorage("InvText") var InvText: String = UserDefaults.standard.string(forKey: "InvText") ?? "Interval:"
    @AppStorage("MinText") var MinText: String = UserDefaults.standard.string(forKey: "MinText") ?? "Min"
    @AppStorage("StartText") var StartText: String = UserDefaults.standard.string(forKey: "StartText") ?? "Start"
    @AppStorage("StopText") var StopText: String = UserDefaults.standard.string(forKey: "StopText") ?? "Stop"
    @AppStorage("Text_1m") var Text_1m: String = UserDefaults.standard.string(forKey: "Text_1m") ?? "1m"
    @AppStorage("Text_3m") var Text_3m: String = UserDefaults.standard.string(forKey: "Text_3m") ?? "3m"
    @AppStorage("Text_5m") var Text_5m: String = UserDefaults.standard.string(forKey: "Text_5m") ?? "5m"
    @AppStorage("Text_10m") var Text_10m: String = UserDefaults.standard.string(forKey: "Text_10m") ?? "10m"
    @AppStorage("Text_30m") var Text_30m: String = UserDefaults.standard.string(forKey: "Text_30m") ?? "30m"
    @AppStorage("Text_60m") var Text_60m: String = UserDefaults.standard.string(forKey: "Text_60m") ?? "60m"
    
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false
    @State private var isFirstPlace: String = ""

    @State private var btn1_selected: Bool = false
    @State private var btn3_selected: Bool = false
    @State private var btn5_selected: Bool = false
    @State private var btn10_selected: Bool = false
    @State private var btn30_selected: Bool = false
    @State private var btn60_selected: Bool = false
    
    @AppStorage("speakMode") private var speakMode: Bool = true
    @AppStorage("voiceMode") var voiceMode: String = UserDefaults.standard.string(forKey: "voiceMode") ?? "Voice Mode"
    @AppStorage("vibMode") var vibMode: String = UserDefaults.standard.string(forKey: "vibMode") ?? "Vibration Mode"
    
    @State private var showToast = false
    @State private var hideToastTask: DispatchWorkItem?
    
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    
    var body: some View {
        
        ZStack {
            if isUpdatingTime {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height) * 0.9 // 너비와 높이 중 작은 값으로 크기 조정

                        Circle()
                            .stroke(
                                Color.pink.opacity(0.5),
                                lineWidth: size * 0.09 // 크기에 비례하여 선 두께 조정
                            )
                            .frame(width: size, height: size)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 화면 중앙 좌표로 위치 지정
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                Color.pink,
                                style: StrokeStyle(
                                    lineWidth: size * 0.09, // 크기에 비례하여 선 두께 조정
                                    lineCap: .round
                                )
                            )
                            .animation(.easeOut, value: progress)
                            .rotationEffect(.degrees(-90))
                            .frame(width: size, height: size)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 화면 중앙 좌표로 위치 지정
                    }
            }
            
            VStack{
                // Language Swaper
                if !isUpdatingTime {
                    Group {
                        HStack {
                           
                            Spacer()
                            
                            Button(action: {
                                
                                withAnimation {
                                    speakMode.toggle()
                                    showToast = true
                                }
                                
                                hideToastTask?.cancel()
                                    let task = DispatchWorkItem {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            showToast = false
                                        }
                                    }
                                    hideToastTask = task
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: task)
                                
                            }, label: {
                                Image(systemName: speakMode ? "person.wave.2" : "iphone.radiowaves.left.and.right")
                                    .font(.system(size: imageSizeForDevice2(), weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                    .transition(.scale)
                                    .padding(.top, 20)
                                    .padding(.trailing, 20)
                                    .padding(.trailing, speakMode ? 11.0 : 0.0)
                            })
                        }
                        .overlay(
                            Menu {
                                Section(LocalizedStringKey(sectionText)) {
                                    Button(action: {
                                        // 한국어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("ko-KR")
                                        selectedLanguage = "ko-KR"
                                        sectionText = "국가별 언어 설정 "
                                        LangText = "언어 "
                                        ActText = "⚡️ 활성화 ⚡️ "
                                        InvText = "시간 간격: "
                                        MinText = "분 "
                                        StartText = "시작 "
                                        StopText = "중지 "
                                        Text_1m = "1분 "
                                        Text_3m = "3분 "
                                        Text_5m = "5분 "
                                        Text_10m = "10분 "
                                        Text_30m = "30분 "
                                        Text_60m = "60분 "
                                        voiceMode = "음성 모드 "
                                        vibMode = "진동 모드 "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("ko-") {
                                            Label("한국어", systemImage: "checkmark")
                                        } else {
                                            Label("한국어", systemImage: selectedLanguage == "ko-KR" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 영어(미국)
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("en-US")
                                        selectedLanguage = "en-US"
                                        sectionText = "Country Language Settings "
                                        LangText = "Language "
                                        ActText = "⚡️ Activating ⚡️ "
                                        InvText = "Interval: "
                                        MinText = "Min "
                                        StartText = "Start "
                                        StopText = "Stop "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Voice Mode "
                                        vibMode = "Vibration Mode "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("en_") {
                                            Label("English(US)", systemImage: "checkmark")
                                        } else {
                                            Label("English(US)", systemImage: selectedLanguage == "en-US" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 영어(영국)
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("en-UK")
                                        selectedLanguage = "en-UK"
                                        sectionText = "Country Language Settings "
                                        LangText = "Language "
                                        ActText = "⚡️ Activating ⚡️ "
                                        InvText = "Interval: "
                                        MinText = "Min "
                                        StartText = "Start "
                                        StopText = "Stop "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Voice Mode "
                                        vibMode = "Vibration Mode "
                                        
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("en_UK") {
                                            
                                            Label("English(UK)", systemImage: "checkmark")
                                        } else {
                                            Label("English(UK)", systemImage: selectedLanguage == "en-UK" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 스페인어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("es-ES")
                                        selectedLanguage = "es-ES"
                                        sectionText = "Configuraciones lingüísticas por país "
                                        LangText = "El lenguaje "
                                        ActText = "⚡️ activación ⚡️ "
                                        InvText = "Intervalo: "
                                        MinText = "Min "
                                        StartText = "Comienzo "
                                        StopText = "Detente. "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Modo de voz "
                                        vibMode = "Modo de vibración "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("es_") {
                                            Label("Espagnol", systemImage: "checkmark")
                                        } else {
                                            Label("Espagnol", systemImage: selectedLanguage == "es-ES" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 중국어(홍콩기준)
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("zh-CN")
                                        selectedLanguage = "zh-CN"
                                        sectionText = "国家语言设置 "
                                        LangText = "语文 "
                                        ActText = "⚡️ 启动 ⚡️ "
                                        InvText = "间隙: "
                                        MinText = "分 "
                                        StartText = "开始 "
                                        StopText = "中止 "
                                        Text_1m = "1分 "
                                        Text_3m = "3分 "
                                        Text_5m = "5分 "
                                        Text_10m = "10分 "
                                        Text_30m = "30分 "
                                        Text_60m = "60分 "
                                        voiceMode = "语音模式 "
                                        vibMode = "振动模式 "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("zh-") {
                                            Label("中文", systemImage: "checkmark")
                                        } else {
                                            Label("中文", systemImage: selectedLanguage == "zh-CN" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 일본어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("ja-JP")
                                        selectedLanguage = "ja-JP"
                                        sectionText = "国別言語設定 "
                                        LangText = "げんご "
                                        ActText = "⚡️ 活性化 ⚡️ "
                                        InvText = "間隔: "
                                        MinText = "分 "
                                        StartText = "スタート "
                                        StopText = "ストップ "
                                        Text_1m = "1分 "
                                        Text_3m = "3分 "
                                        Text_5m = "5分 "
                                        Text_10m = "10分 "
                                        Text_30m = "30分 "
                                        Text_60m = "60分 "
                                        voiceMode = "おんせいモード "
                                        vibMode = "しんどうモード "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("ja_") {
                                            Label("日本語", systemImage: "checkmark")
                                        } else {
                                            Label("日本語", systemImage: selectedLanguage == "ja-JP" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 독일어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("de-DE")
                                        selectedLanguage = "de-DE"
                                        sectionText = "Spracheinstellungen "
                                        LangText = "Sprache "
                                        ActText = "⚡️ Aktivieren ⚡️ "
                                        InvText = "Intervall: "
                                        MinText = "Min "
                                        StartText = "Beginn "
                                        StopText = "Halt "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Modus der Sprachmodus "
                                        vibMode = "Modus der Schwingung "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("de_") {
                                            Label("Deutsch", systemImage: "checkmark")
                                        } else {
                                            Label("Deutsch", systemImage: selectedLanguage == "de-DE" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 프랑스어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("fr-FR")
                                        selectedLanguage = "fr-FR"
                                        sectionText = "établissement des langues "
                                        LangText = "Language "
                                        ActText = "⚡️ Activation ⚡️ "
                                        InvText = "Intervalle: "
                                        MinText = "Min "
                                        StartText = "Départ "
                                        StopText = "Cessation "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Mode vocal "
                                        vibMode = "Mode vibratoire "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("fr_") {
                                            Label("Français", systemImage: "checkmark")
                                        } else {
                                            Label("Français", systemImage: selectedLanguage == "fr-FR" ? "checkmark" : "")
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 이탈리아어
                                        isFirstLaunch = true
                                        speechSynthesizer.updateSelectedLanguage("it-IT")
                                        selectedLanguage = "it-IT"
                                        sectionText = "Impostazione linguistica "
                                        LangText = "Lingua "
                                        ActText = "⚡️ Attivazione ⚡️ "
                                        InvText = "Intervallo: "
                                        MinText = "Min "
                                        StartText = "princìpio "
                                        StopText = "fermare "
                                        Text_1m = "1m "
                                        Text_3m = "3m "
                                        Text_5m = "5m "
                                        Text_10m = "10m "
                                        Text_30m = "30m "
                                        Text_60m = "60m "
                                        voiceMode = "Modalità vocale "
                                        vibMode = "Modalità vibratoria "
                                        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                                    }) {
                                        if selectedLanguage.hasPrefix("it_") {
                                            Label("Lingua italiana", systemImage: "checkmark")
                                        } else {
                                            Label("Lingua italiana", systemImage: selectedLanguage == "it-IT" ? "checkmark" : "")
                                        }
                                    }
                                }
                            } label: {
                                    Label(LocalizedStringKey(LangText), systemImage: "globe")
                            }
                                .font(.system(size: imageSizeForDevice3(), weight: .bold))
                            .onTapGesture {
                                print("\(selectedLanguage)")
                            }
                            .padding(7)
                            .padding(.leading, -3.0)
                            .padding(.vertical, -5.0)
                            .overlay(
                            RoundedRectangle(cornerRadius: 7)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                            )
                            .imageScale(.large)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.top, 20)
                    )
                        .overlay{
                            VStack{
                                if showToast {
                                    ToastView(message: speakMode ? voiceMode : vibMode, showToast: $showToast)
                                        .padding(.top, 160)
                                }
                                
                            }
                        }

                    }
                }
                               
                Spacer()
                
                // Activating
                if isUpdatingTime {
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        Text(LocalizedStringKey(ActText))
                            .font(.system(size: fontSizeForDevice5(), weight: .bold))
                            .italic()
                            .transition(.scale)
                            .padding(.top, paddingSizeForDevice())
                    }
                }
                
                // Time & Control
                Group {
                    
                    Spacer()
                
                    Text(currentTime)
                        .font(.system(size: fontSizeForDevice(), weight: isUpdatingTime ? .heavy : .light))
                        .padding()
                    
                    HStack {
                        Text(LocalizedStringKey(InvText))
                            .padding(.top, 3.0)
                            .font(.system(size: fontSizeForDevice3()))
                        
                        Text("\(selectedInterval)")
                            .font(.system(size: fontSizeForDevice3(), weight: .bold))
                            .padding(.top, 2)
                            
                        
                        Text(LocalizedStringKey(MinText))
                            .padding(.top, 3.0)
                            .font(.system(size: fontSizeForDevice3()))
                    }
                    
                    .padding()
                    
                    HStack {
                        if !isUpdatingTime {
                            Button(action: {
                                if (selectedInterval > 1) {
                                    selectedInterval -= 1
                                }
                                
                                withAnimation {
                                    if (selectedInterval >= 2) {
                                        btn1_selected = false
                                    }
                                    btn3_selected = false
                                    btn5_selected = false
                                    btn10_selected = false
                                    btn30_selected = false
                                    btn60_selected = false
                                }
                                
                            }, label: {
                                Image(systemName: "arrowtriangle.backward")
                                    .resizable()
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.title2)
                                    .frame(width: imageSizeForDevice(), height: imageSizeForDevice())
                                    .transition(.scale)
                                    .padding(.trailing, paddingSizeForDevice2())
                                    
                            })
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)){
                                if isUpdatingTime {
                                    stopUpdatingTime()
                                } else {
                                    startUpdatingTime()
                                }
                            }
                        }) {
                            Text(isUpdatingTime ? LocalizedStringKey(StopText) : LocalizedStringKey(StartText))
                                .font(.system(size: fontSizeForDevice2(), weight: .bold))
                                .scaleEffect(isUpdatingTime &&
                                             (!["ja-JP", "es-ES", "fr-FR", "it-IT"].contains(selectedLanguage)
                                              || selectedLanguage.hasPrefix("ja_")
                                              || selectedLanguage.hasPrefix("es_")
                                              || selectedLanguage.hasPrefix("fr_")
                                              || selectedLanguage.hasPrefix("it_")) ? 1.5 : 1.0)
                        }
                        .foregroundColor(isUpdatingTime ? .red : .green)
                        
                        if !isUpdatingTime {
                            Button(action: {
                                selectedInterval += 1
                                
                                withAnimation {
                                    btn1_selected = false
                                    btn3_selected = false
                                    btn5_selected = false
                                    btn10_selected = false
                                    btn30_selected = false
                                    btn60_selected = false
                                }
                                
                            }, label: {
                                Image(systemName: "arrowtriangle.forward")
                                    .resizable()
                                    .frame(width: imageSizeForDevice(), height: imageSizeForDevice())
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.title2)
                                    .transition(.scale)
                                    .padding(.leading, paddingSizeForDevice2())
                                
                            })
                        }
                        
                    }
                    
                    Spacer()
                        .frame(height : 50)
                                
                    // Quick Button
                    if !isUpdatingTime {
                        Group {
                            VStack {
                                HStack {
                                    Button(action: {
                                        selectedInterval = 1
                                        withAnimation {
                                            if btn1_selected == false {
                                                btn1_selected.toggle()
                                                btn3_selected = false
                                                btn5_selected = false
                                                btn10_selected = false
                                                btn30_selected = false
                                                btn60_selected = false
                                            }
                                        }
                                    }, label: {
                                        Text(LocalizedStringKey(Text_1m))
                                            .scaleEffect(btn1_selected ? 1.5 : 1.0)
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    .offset(x:-40,y:0)
                                    
                                    
                                    Button(action : {
                                        selectedInterval = 3
                                        
                                        withAnimation {
                                            if btn3_selected == false {
                                                btn3_selected.toggle()
                                                
                                                btn1_selected = false
                                                btn5_selected = false
                                                btn10_selected = false
                                                btn30_selected = false
                                                btn60_selected = false
                                            }
                                        }
                                    }, label : {
                                        Text(LocalizedStringKey(Text_3m))
                                            .scaleEffect(btn3_selected ? 1.5 : 1.0)
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    .offset(x:0,y:0)
                                    
                                    
                                    Button(action : {
                                        selectedInterval = 5
                                        
                                        withAnimation {
                                            if btn5_selected == false {
                                                btn5_selected.toggle()
                                                
                                                btn1_selected = false
                                                btn3_selected = false
                                                btn10_selected = false
                                                btn30_selected = false
                                                btn60_selected = false
                                            }
                                        }
                                    }, label : {
                                        Text(LocalizedStringKey(Text_5m))
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .scaleEffect(btn5_selected ? 1.5 : 1.0)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    .offset(x:40,y:0)
                                }
                                
                                Spacer()
                                    .frame(height:20)
                                
                                HStack {
                                    Button(action : {
                                        selectedInterval = 10
                                        
                                        withAnimation {
                                            if btn10_selected == false {
                                                btn10_selected.toggle()
                                                
                                                btn1_selected = false
                                                btn3_selected = false
                                                btn5_selected = false
                                                btn30_selected = false
                                                btn60_selected = false
                                            }
                                        }
                                    }, label : {
                                        Text(LocalizedStringKey(Text_10m))
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .scaleEffect(btn10_selected ? 1.5 : 1.0)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        
                                    })
                                    .offset(x:-23,y:0)
                                    
                                    Button(action : {
                                        selectedInterval = 30
                                        
                                        withAnimation {
                                            if btn30_selected == false {
                                                btn30_selected.toggle()
                                                
                                                btn1_selected = false
                                                btn3_selected = false
                                                btn5_selected = false
                                                btn10_selected = false
                                                btn60_selected = false
                                            }
                                        }
                                    }, label : {
                                        Text(LocalizedStringKey(Text_30m))
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .scaleEffect(btn30_selected ? 1.5 : 1.0)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    
                                    Button(action : {
                                        selectedInterval = 60
                                        
                                        withAnimation {
                                            if btn60_selected == false {
                                                btn60_selected.toggle()
                                                
                                                btn1_selected = false
                                                btn3_selected = false
                                                btn5_selected = false
                                                btn10_selected = false
                                                btn30_selected = false
                                            }
                                        }
                                    }, label : {
                                        Text(LocalizedStringKey(Text_60m))
                                            .font(.system(size: fontSizeForDevice4(), weight: .bold))
                                            .scaleEffect(btn60_selected ? 1.5 : 1.0)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                    .offset(x:25,y:0)
                                }
                            }
                            .transition(AnyTransition.scale.animation(.easeInOut))
                        }
                    }

                    Spacer()
                
                    Spacer()
                    
                    .onAppear {
                        
                        updateTime()
                        if isFirstLaunch == false {
                            selectedLanguage = Locale.current.identifier
                            print("first Launched")
                            print("\(selectedLanguage)")
                        } else {print("already have launched")}
                    }
                }
                
                
                
            }
            .onChange(of: selectedLanguage) { newValue in
                print("Selected Language: \(newValue)")
            }
            .onAppear {
                         
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                    print("Active")
                } catch {
                    print("Error setting audio session category: \(error)")
                }
            }
        }
        
    }
    
    // 활성화 패딩
    func paddingSizeForDevice() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 1
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 3
        } else if deviceWidth < 500 { // more than upS..
            return 3
        } else { // pad
            return 180
        }
    }
    
    // 인터벌 조정 패딩
    func paddingSizeForDevice2() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 1
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 3
        } else if deviceWidth < 500 { // more than upS..
            return 10
        } else { // pad
            return 20
        }
    }
    
    // 현재 시각
    func fontSizeForDevice() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 40
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 50
        } else if deviceWidth < 500 { // more than upS..
            return 65
        } else { // pad
            return 150
        }
    }
    
    // 스타트, 스탑
    func fontSizeForDevice2() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 40
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 45
        } else if deviceWidth < 500 { // more than upS..
            return 55
        } else { // pad
            return 100
        }
    }
    
    // 인터벌 표시
    func fontSizeForDevice3() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 20
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 20
        } else if deviceWidth < 500 { // more than upS..
            return 30
        } else { // pad
            return 50
        }
    }
    
    // 퀵버튼 표시
    func fontSizeForDevice4() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 20
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 30
        } else if deviceWidth < 500 { // more than upS..
            return 40
        } else { // pad
            return 50
        }
    }
    
    // 활성화 표시
    func fontSizeForDevice5() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        // 디바이스 크기에 따라 적절한 폰트 크기 반환
        if deviceWidth < 375 { // iPhone 6/7/8, SE (2nd generation)
            return 25
        } else if deviceWidth < 430 { // iPhone 6/7/8 Plus, XR, 11, iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            return 35
        } else if deviceWidth < 500 { // more than upS..
            return 40
        } else { // pad
            return 50
        }
    }
    
    // 인터벌 조정 이미지
    func imageSizeForDevice() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        if deviceWidth < 700 { // 아이폰
            return 20
        } else { // 패드
            return 60
        }
    }
    
    // 모드전환 이미지
    func imageSizeForDevice2() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        if deviceWidth < 700 { // 아이폰
            return 25
        } else { // 패드
            return 60
        }
    }
    
    // 언어변환 이미지
    func imageSizeForDevice3() -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        
        if deviceWidth < 700 { // 아이폰
            return 15
        } else { // 패드
            return 50
        }
    }

    // 현재시각 표시
    func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja-JP")
        currentTime = formatter.string(from: Date())

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            updateTime()
        }
    }

    // Start Btn -> 지정 인터벌에 따른 음성 생성 및 재생
    func startUpdatingTime() {
        stopUpdatingTime() // Stop previous updates if any
        isUpdatingTime = true
        updateTargetTime()
    }

    // Stop Btn -> 생성된 인터벌객체 중지 및 제거
    func stopUpdatingTime() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TargetTimeNotificationFirst"])
        
        var identifiersToRemove: [String] = []
        let FirstIdentifier = "TargetTimeNotificationFirst"
        identifiersToRemove.append(FirstIdentifier)

        
        for i in 1...60 { // 또는 1...100 등, 알림 요청을 생성한 범위에 맞게 수정
                let identifiers = "TargetTimeNotification\(i)"
                identifiersToRemove.append(identifiers)
            }
        
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        
        isUpdatingTime = false
        targetTimeWorkItem?.cancel()
        targetTimeWorkItem = nil
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                for request in requests {
                    print("Scheduled notification identifier: \(request.identifier)")
                }
            }
    }

    // nextTarget을 조정하여 생성
    func updateTargetTime() {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())

        guard let currentHour = currentComponents.hour,
                let currentMinute = currentComponents.minute else {
            return
        }
        
        var nextTargetMinute = (currentMinute + selectedInterval)
        var nextTargetHour = currentHour
    
        if nextTargetMinute >= 60 {
            nextTargetHour += 1
            nextTargetMinute %= 60
        }
        
        if nextTargetHour == 24 {
            nextTargetHour = 0
        }
        
        let targetTime = calendar.date(bySettingHour: nextTargetHour, minute: nextTargetMinute, second: 0, of: Date())!
        
        let timeDiff = targetTime.timeIntervalSinceNow
        
        // 계산된 진행도를 설정합니다.
        let totalTimeInterval = TimeInterval(selectedInterval * 60)
        let elapsedTime = totalTimeInterval - timeDiff
        let progressPercentage = elapsedTime / totalTimeInterval
        progress = max(0, min(1, progressPercentage))
            
        targetTimeWorkItem = DispatchWorkItem {
            if isUpdatingTime {
                speakCurrentTime()
                updateTargetTime()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeDiff, execute: targetTimeWorkItem!)
        print("nextTarget Hour: \(nextTargetHour)")
        print("nextTarget Min: \(nextTargetMinute)")
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let currentTimeDiff = targetTime.timeIntervalSinceNow
            let currentElapsedTime = totalTimeInterval - currentTimeDiff

            if currentElapsedTime <= 0 {
                // 타겟 시간에 도달하여 초기화
                self.progress = 1.0
                self.updateTargetTime()
            } else {
                let currentProgressPercentage = currentElapsedTime / totalTimeInterval
                self.progress = max(0, min(1, currentProgressPercentage))
            }
        }
        
        let firstIdentifier = "TargetTimeNotificationFirst"
        scheduleNotification(at: targetTime, identifier: firstIdentifier)
        
        
        for i in 1...60 {
            let identifier = "TargetTimeNotification\(i)"
            let minute = nextTargetMinute + (selectedInterval * i)
            var hour = nextTargetHour + (minute / 60) // minute가 60을 초과하면 hour를 증가
            let minuteRemainder = minute % 60
            if minuteRemainder >= 60 {
                hour += 1
            }
            
            if hour >= 24 {
                    hour = hour % 24 // 24로 나눈 나머지로 시간을 조정
                    let nextDay = calendar.date(bySettingHour: hour, minute: minuteRemainder, second: 0, of: Date().addingTimeInterval(86400))!
                    scheduleNotification(at: nextDay, identifier: identifier)
                } else {
                    let newtargetTime = calendar.date(bySettingHour: hour, minute: minuteRemainder, second: 0, of: Date())!
                    scheduleNotification(at: newtargetTime, identifier: identifier)
                }
        }
    }
    
    // 앱이 비활성화될 때 타이머를 중지합니다.
    func applicationWillResignActive() {
        timer?.invalidate()
        timer = nil
    }

    // 앱이 다시 활성화될 때 타이머를 시작합니다.
    func applicationDidBecomeActive() {
        if isUpdatingTime {
            updateTargetTime()
        }
    }

    // 알림객체 생성
    func scheduleNotification(at targetTime: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTimeString = dateFormatter.string(from: targetTime)
        
        content.title = "In Timer!"
        content.body = "📢 \(currentTimeString)"
        content.sound = UNNotificationSound.defaultCritical

        // 타겟 시간에 알림이 울리도록 UNCalendarNotificationTrigger를 생성합니다.
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        print("알람 예정 포인트 : \(components)")

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // 알림 요청 등록
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("알림 등록 에러: \(error)")
            }
        }
    }
    
    // 무음모드 여부를 판단하여 소리 or 진동 출력
    func speakCurrentTime() {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let timeString = formatter.string(from: Date())
        if speakMode {
            speechSynthesizer.speak(timeString)
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}

// 토스트 표시 뷰
struct ToastView: View {
    let message: String
    @Binding var showToast: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .white : .black)
                .opacity(0.7)
                .cornerRadius(10)
                .padding()
            Text(message)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: 300, alignment: .center)
        .opacity(showToast ? 1 : 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
