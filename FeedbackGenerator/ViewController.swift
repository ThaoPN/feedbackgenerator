//
//  ViewController.swift
//  FeedbackGenerator
//
//  Created by ThaoPN on 03/12/2021.
//

import UIKit

class Haptic {
    public static let selection = Haptic(.selection)
    
    public static let impactLight = Haptic(.impact(.light))
    public static let impactMedium = Haptic(.impact(.medium))
    public static let impactHeavy = Haptic(.impact(.heavy))
    
    public static let error = Haptic(.notification(.error))
    public static let warning = Haptic(.notification(.warning))
    public static let success = Haptic(.notification(.success))
    
    enum HapticType {
        
        case selection
        
        enum ImpactType: Int {
            case light
            case medium
            case heavy
            case soft
            case rigid
        }
        
        case impact(ImpactType)
        
        enum NotificationType: Int {
            
            case error
            case success
            case warning
            
        }
        
        case notification(NotificationType)
    }
    
    var text: String {
        switch type {
        case .selection:
            return "Selection"
            
        case .impact(let impactType):
            switch impactType {
            case .light:
                return "Impact light"
            case .medium:
                return "Impact medium"
            case .heavy:
                return "Impact heavy"
            case .soft:
                return "Impact soft"
            case .rigid:
                return "Impact rigid"
            }
        case .notification(let type):
            switch type {
            case .error:
                return "Notification error"
            case .success:
                return "Notification success"
            case .warning:
                return "Notification warning"
            }
        }
        
    }
    
    private(set) var generator: UIFeedbackGenerator?
    private let type: HapticType
    
    init(_ type: HapticType) {
        self.type = type
        guard #available(iOS 10.0, *) else { return }
        switch self.type {
        case .selection:
            generator = UISelectionFeedbackGenerator()
        case .impact(let type):
            guard let impactFeedbackStyle = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: type.rawValue) else {
                assertionFailure("Unable to create Apple's feedback style from raw value")
                return
            }
            generator = UIImpactFeedbackGenerator(style: impactFeedbackStyle)
        case .notification:
            generator = UINotificationFeedbackGenerator()
        }
    }
    
    func generate(prepareForReuse: Bool = false) {
        guard Thread.isMainThread else {
            assertionFailure("Haptics should be generated on the main thread")
            return
        }
        guard #available(iOS 10.0, *) else { return }
        switch type {
        case .selection: (generator as? UISelectionFeedbackGenerator)?.selectionChanged()
        case .impact: (generator as? UIImpactFeedbackGenerator)?.impactOccurred()
        case .notification(let type):
            guard let notificationFeedbackType = UINotificationFeedbackGenerator.FeedbackType(rawValue: type.rawValue) else {
                assertionFailure("Unable to create Apple's feedback type from raw value")
                return
            }
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(notificationFeedbackType)
        }
        if prepareForReuse {
            prepareForUse()
        }
    }
    
    /// informs self that it will likely receive events soon, so that it can ensure minimal latency for any feedback generated
    /// safe to call more than once before the generator receives an event, if events are still imminently possible
    func prepareForUse() {
        guard Thread.isMainThread else {
            assertionFailure("Haptics should be prepared for reuse on the main thread")
            return
        }
        guard #available(iOS 10.0, *) else { return }
        generator?.prepare()
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var tableview = UITableView()
    var items = [Haptic]()
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generate()
        
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.contentInset = UIEdgeInsets.init(top: 44, left: 0, bottom: 44, right: 0)
        view.addSubview(tableview)
        tableview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func generate() {
        items = []
        items.append(Haptic.selection)
        items.append(Haptic.impactLight)
        items.append(Haptic.impactMedium)
        items.append(Haptic.impactHeavy)
        items.append(Haptic(.impact(.soft)))
        items.append(Haptic(.impact(.rigid)))
        items.append(Haptic.error)
        items.append(Haptic.warning)
        items.append(Haptic.success)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = items[indexPath.row].text
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        item.generate()
    }
}

