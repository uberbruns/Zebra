# Zebra
An experimental Swift library trying to make it easy to write simple cleanly structured iOS apps. Because the goal is a simple pattern the lib is called Zebra 🦓.


## Usage

### The Setup

This is how you setup your application using Zebra. You start by registering instances of your core services with your subclass of `AppManager`. In this case the `MainAppManager`. Later services can be resolved by using their type or a passing a protocol.
In the second step you register your view controllers classes an assign them an identifier. This means that later on your view controller do not need to know each other.

```swift
var window: UIWindow?
var manager = MainAppManager()

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Setup dependencies
    do {
        // Register services
        let database = try MainDatabase()
        let locationDataStore = try LocationDataStore(database: database)
        let locationService = LocationService(locationDataStore: locationDataStore)
        manager.register(service: locationService)
        
        // Register view controllers
        manager.register(viewControllerClass: DayLocationRecordsViewController.self, forIdentifier: "dayLocationRecords")
        manager.register(viewControllerClass: DayMapViewController.self, forIdentifier: "dayMap")
        manager.register(viewControllerClass: LocationRecordViewController.self, forIdentifier: "locationRecord")
        manager.register(viewControllerClass: MainLocationRecordsViewController.self, forIdentifier: "mainLocationRecords")
        manager.register(viewControllerClass: TrackingProfilesViewController.self, forIdentifier: "trackingProfiles")
        manager.register(viewControllerClass: TrackingProfileEditorViewController.self, forIdentifier: "trackingProfileEditor")
        
        // Setup window
        let window = UIWindow()
        try manager.setup(in: window)
        window.makeKeyAndVisible()
        
        self.window = window
        self.manager = manager
        
        return true
    } catch {
        fatalError("Could not initialise essential services.")
    }
}
```

### The App Manager

Your App Manager will look something like this in the most simplest case. First you build your root view controller. Note, how the view controller are not instantiated directly, but you request the using the `viewController(forIdentifier:)` method.

The functions `show` and `dismiss` are super simplified in this example. In a real app they are responsible for coordinating the flow between view controllers in your app.

```swift
class MainAppManager: AppManager {
    
    override func setup(in window: UIWindow) throws {
        let mainLocationRecordsVC = try viewController(forIdentifier: "mainLocationRecords")
        let trackingProfileEditorVC = try viewController(forIdentifier: "trackingProfileEditor")
        let tabBarVC = UITabBarController()
        
        tabBarVC.viewControllers = [
            UINavigationController(rootViewController: mainLocationRecordsVC),
            UINavigationController(rootViewController: trackingProfileEditorVC)
        ]
        
        window.rootViewController = tabBarVC
    }
    
    
    override func show(viewController: UIViewController, from sourceViewController: UIViewController, identifier: String) {
        // Show
        sourceViewController.navigationController?.pushViewController(viewController, animated: true)
    }

    
    override func dismiss(viewController: UIViewController, identifier: String) {
        // Dismiss
        viewController.navigationController?.popViewController(animated: true)
    }
}
```


### The View Controller and The Agent

To make your view controllers compatible with Zebra they just have to comform to the ManagedViewController protocol. The only requirement here is to implement the static `assemble(...)` function.

The `assemble` function can solely return a view controller, but in this case we use the managers `managedViewController((Agent) -> UIViewController)` function to init our view controller and to get an `agent` that will be linked to the view controller.

The `Agent` is similar to the manager, but more limited in a good way. You can use is to:

- A: Request instances of your service classes 
- B: Request transitions to other view controllers

It is limited because:

- You can only request service instances from it, but you can **not** register them
- You can **not** request view controllers from it

These limitations make the `Agent` a perfect fit for components of your interface that should be free from UIKit relations like **View Models**, **Presenters** and so on.

#### Using the Agent

- To resolve a service: `agent.resolve(serviceOfType: LocationService.self)`
- To navigate: agent.performSegue(to: "trackingProfileEditor")

#### View Controller Example

```swift
class DayMapViewController: BaseViewController, ManagedViewController {
    
    private let agent: Agent
    private let locationService: LocationService
    private let yearMonth: Int
    private let day: Int


    static func assemble(with data: AssemblationData, manager: AppManager) throws -> UIViewController {
        let yearMonth = data["yearMonth"] as! Int
        let day = data["day"] as! Int
        return try manager.managedViewController { agent in
            try DayMapViewController(yearMonth: yearMonth, day: day, agent: agent)
        }
    }

    
    init(yearMonth: Int, day: Int, agent: Agent) throws {
        self.agent = agent
        self.locationService = try agent.resolve(serviceOfType: LocationService.self)
        self.yearMonth = yearMonth
        self.day = day
        super.init()
    }

    ...
```


