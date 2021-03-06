//
//  PreferencesWindow.swift
//  WorldClock
//
//  Created by Jacob Gold on 2/3/19.
//  Copyright © 2019 Jacob Gold. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController {
    
    @IBOutlet var citiesTokenField: NSTokenField!
    @IBOutlet var timeFormatSegmentedControl: NSSegmentedControl!
    @IBOutlet var accentComboColorWell: ComboColorWell!
    @IBOutlet var menuTextPopUpButton: NSPopUpButton!
    @IBOutlet var systemTimeDisplaySettings: NSSegmentedControl!
    
    override var windowNibName: NSNib.Name? {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        citiesTokenField.convertToACBTokenField()
        populateTokensWithCitiesListForACBTokenField()
        
        loadCities()
        loadTimeFormat()
        loadAccentColor()
        loadMenuTitleStyle()
        loadSystemTimeMenuItemConfiguration()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.orderedIndex = 0
        NSApp.activate(ignoringOtherApps: true)
    }
    
    
    
    func populateTokensWithCitiesListForACBTokenField() {
        let cities: [String] = allTimezones.map { $0.city }
        citiesTokenField.defaultTokenKeywords = cities
    }
    
    @IBAction func savePreferences(_ sender: Any) {
        saveCities()
        saveTimeFormat()
        saveAccentColor()
        saveMenuTitleStyle()
        saveSystemTimeMenuItemConfiguration()
        self.close()
    }
    
    
    // MARK: Cities Preferences
    // Save city list to
    func saveCities() {
        // Cast the tags to NSArray, as otherwise __NSArrayI is returned
        let rawTags = citiesTokenField.objectValue as! NSArray
        
        // Pull the names from the custom ACBTokens
        let cleanTags: [String] = rawTags.map{ ($0 as! ACBToken).name }
        
        // Consider checking tags to see if they're valid before saving them?
        Settings.saveCitiesToPreferences(cities: cleanTags)
        NotificationCenter.default.post(name: Notification.Name("WorldClockCitiesListUpdated"), object: nil)
    }
    
    func loadCities() {
        let cities: [String] = Settings.loadCitiesFromPreferences()
        _ = cities.map{ citiesTokenField.addToken(name: $0) }
    }
    
    // MARK: Time format Preferences
    func saveTimeFormat() {
        let segmentValue = timeFormatSegmentedControl.selectedSegment
        let formatPref = segmentValue == 0 ? Settings.TimeHourFormat.twelveHour : Settings.TimeHourFormat.twentyFourHour
        Settings.saveTimeFormatToPreferences(hourformat: formatPref.rawValue)
    }
    
    func loadTimeFormat() {
        timeFormatSegmentedControl.selectedSegment = Settings.loadTimeFormatFromPreferences() == Settings.TimeHourFormat.twelveHour ? 0 : 1
    }
    
    // MARK: Accent Preferences
    func saveAccentColor() {
        Settings.saveAccentColorToPreferences(color: accentComboColorWell.color)
        NotificationCenter.default.post(name: Notification.Name("WorldClockAccentColorUpdated"), object: nil)
    }
    
    func loadAccentColor() {
        accentComboColorWell.color = Settings.loadAccentColorFromPreferences()
    }
    
    // MARK: Menu Title Preferences
    func saveMenuTitleStyle() {
        Settings.saveMenuTitleDisplayType(menuTitle: menuTextPopUpButton.indexOfSelectedItem)
        NotificationCenter.default.post(name: Notification.Name("WorldClockMenuTitleStyleUpdated"), object: nil)
    }
    
    func loadMenuTitleStyle() {
        menuTextPopUpButton.selectItem(at: Settings.loadMenuTitleDisplayType().rawValue)
        menuTextPopMenuChanged(self)
    }
    
    func saveSystemTimeMenuItemConfiguration() {
        if (menuTextPopUpButton.indexOfSelectedItem == 0) {
            let c = systemTimeDisplaySettings
            let setting = Settings.SystemMenuDisplayTypeConfig(date: c?.isSelected(forSegment: 0) ?? false,
                                                               day:  c?.isSelected(forSegment: 1) ?? false,
                                                               time: c?.isSelected(forSegment: 2) ?? true)
            
            Settings.saveSystemMenuDisplayTypeConfig(config: setting)
        }
    }
    
    func loadSystemTimeMenuItemConfiguration() {
        let s = Settings.loadSystemMenuDisplayTypeConfig()
        let c = systemTimeDisplaySettings
        c?.setSelected(s.date, forSegment: 0)
        c?.setSelected(s.day, forSegment: 1)
        c?.setSelected(s.time, forSegment: 2)
    }
    
    
    @IBAction func menuTextPopMenuChanged(_ sender: Any) {
        let systemTime: Bool = menuTextPopUpButton.indexOfSelectedItem == 0
        let display: Bool = systemTime ? false : true
        
        systemTimeDisplaySettings.isHidden = display
    }
}
