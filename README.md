# PantryPulse

A smart fridge inventory and macro-optimized meal planning app for iOS (SwiftUI, iOS 17+).

Track what's in your fridge, see which items are about to expire, log what you eat against daily macro targets, and get recipe suggestions built from what you already have.

## Screens

| Tab | What it does |
| --- | --- |
| **Fridge** | Daily macro progress, then the fridge as shelves grouped by category. Items closest to expiring come first, with an amber pill for anything expiring within 3 days. The **+** button opens *Add to Fridge*. |
| **Log** | Today's eaten and planned meals, with an empty state for a fresh day. |
| **Meal Planner** | Remaining calories and protein, filter chips, and recipe cards showing how each one affects the rest of your day. |
| **Profile** | Placeholder for targets and preferences. |

## Getting started

Requirements: macOS with Xcode 15 or later.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen), so there is no `.xcodeproj` in the repo.

```sh
brew install xcodegen
xcodegen generate
open PantryPulse.xcodeproj
```

Then pick an iPhone simulator and run. On first launch the app seeds a sample fridge and today's log so it matches the design mockups (see `Services/SampleData.swift`).

## Project layout

```
PantryPulse/
  App/        App entry point and the tab bar
  Design/     Colors, shared components (cards, pills, rings, buttons)
  Models/     SwiftData models (FridgeItem, LogEntry), Nutrition, Expiry, Recipe
  Services/   RecipeEngine, FoodDatabase (auto-fill), SampleData
  Features/   Fridge, AddItem, Log, Planner, Profile
  Resources/  Asset catalog
```

## How the pieces work

- **Expiry**: `Expiry.soonThreshold` (3 days) decides what counts as "expiring soon". Pills turn amber at or below it, red once expired.
- **Recipes**: `RecipeEngine` only suggests recipes whose ingredients are all in the fridge (matched by keyword against item names). The *Use Expiring Soon* and *High Protein* chips re-weight the ranking; *< 20 Min* and *Low Carb* filter the list.
- **Day budget**: remaining = daily target − eaten − planned. Tapping *Add to Day Plan* adds a planned entry, which shows up in the Log tab and updates the remaining budget.
- **Auto-fill**: `FoodDatabase` is a small built-in lookup. It can be swapped for a real nutrition API.

## Not built yet

- Barcode and receipt scanning (the Scan tab is a placeholder)
- Editing daily targets in Profile
- Dark mode (the app is pinned to light to match the design)
