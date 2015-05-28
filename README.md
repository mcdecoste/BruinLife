# Bruin Life
![Big Logo](https://raw.githubusercontent.com/mcdecoste/BruinLife/master/BruinLife/Images.xcassets/AppIcon.appiconset/logo@180.png)

Source code for the Bruin Life app for iOS

This is a solo side project, so expect the code to be a bit messy. It's not necessarily written for public consumption, but it shouldn't be too dense.

[View in App Store](https://itunes.apple.com/us/app/bruin-life/id575404770 "iOS only")

## Overview
Bruin Life relies on a CloudKit database (populated by a separate app it shares a container with) to provide up-to-date menus and hours for UCLA dining options.

---
## Model
### Food (FoodModel.swift)
Holy hierarchy Batman. Lots of trickerations here and there to try and make this perform well, but it's hard. Lots of data and lots of different levels at which its displayed. Will get into the weeds of this at a later date, but feel free to try and read it. The full hierarchy is listed out below, in order.

* DayBrief
* MealBrief
* RestaurantBrief / PlaceBrief
* SectionBrief
* FoodBrief / FoodInfo
* Nutrient / NutritionListing

### Swipes (SwipeModel.swift)
Provides all logic necessary to sort out the number of swipes a user SHOULD have left given the week and day. Also has logic to determine the week and day based on the date.
### Core Data (Food.swift)
NSManagedObjects subclasses for local storage.
### Overall (CloudManager.swift)
Overall handler for Core Data and CloudKit. Trying to offload a lot of work into here to centralize the model.

---
## View Controllers

### Dining Halls (DormTableViewController.swift)
Shows menus and hours for all dining halls on the hill. Scrolling left and right (or tapping on the title bar at the top) allows the user to change the day. Scrolling up and down reveals the day's different meals. Tapping on a hall's row reveals its menu, which is navigible by scrolling left and right through the various sections. Tapping on a food brings up the Food View Controller (discussed below).

### Quick Service (QuickTableViewController.swift)
Shows memnus and hours for all quick service establishments on the hill. Navigation is similar to the Dining Hall Controller, but there is no option to look ahead at future days.

### Foods (FoodViewController.swift)
Shows the food's name, type (Vegan / Vegetarian / Regular), description (if available), ingredients, and nutritional information. Allows the user to favorite a food, set up a reminder, or add servings.

This is a mess at the moment; need to redo it as a table view controller. It works for now, but I'm dreading the day something breaks. Also need to make all constituent parts Autolayout-compatible so as to better work with larger devices.

### Swipes (SwipesTableViewController.swift)
Uses the aforementioned Swipes Model to show the user how many swipes they should have.

### Settings (SettingsTableViewController.swift)
Allows the user to check on reminders, favorites, and nutritional information. Also lets the user give feedback through email or App Store reviews (without pestering them, yay).

---
## Views

### Table View Cells
Far too many of these to cover one-by-one. Some are Autolayout-compatible, others suck. Moving on.

### Circle Display (CircleDisplay.swift)
Used for nutrional information displays. If the nutrient has a daily value, it shows a colored circle that is filled in by the percent the current measure is of the daily value and tapping the circle toggles between the exact measurement and the percent value. Otherwise, it's a faded out grey circle that isn't tappable.

### Day Display (DayDisplay.swift)
Used both as the tappable button atop the Dining Hall View Controller (for day changing), but also as the source for the strings of the cells in the popover whose appearance that button toggles. English? English.