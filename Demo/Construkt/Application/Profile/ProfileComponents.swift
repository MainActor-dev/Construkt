import UIKit
import ConstruktKit

// MARK: - Hero Section
struct ProfileHeroSection: ViewBuilder {
    var body: View {
        VStackView {
            // Avatar with ring
            ZStackView {
                CircleView()
                    .size(width: 96, height: 96)
                    .backgroundColor(.clear)
                
                ImageView(UIImage(systemName: "person.crop.circle.fill"))
                    .contentMode(.scaleAspectFill)
                    .tintColor(.gray)
                    .size(width: 88, height: 88)
                    .cornerRadius(44)
                    .clipsToBounds(true)
                    .position(.center)
            }
            .position(.center)
            
            // Name and handle
            VStackView {
                LabelView("Alex Morgan")
                    .color(.white)
                    .font(.systemFont(ofSize: 18, weight: .medium))
                    .alignment(.center)
                
                LabelView("@alexmorgan • Member since 2023")
                    .color(UIColor("#737373")) // neutral-500
                    .font(.systemFont(ofSize: 12, weight: .regular))
                    .alignment(.center)
            }
            .spacing(4)
            
            // Stats
            HStackView {
                ProfileStatBox(value: "124", label: "Watched")
                ProfileStatBox(value: "48", label: "Reviews")
                ProfileStatBox(value: "12", label: "Lists")
            }
            .spacing(12)
            .position(.center)
            .distribution(.fillEqually)
        }
        .spacing(16)
    }
}

// MARK: - Stat Box
struct ProfileStatBox: ViewBuilder {
    let value: String
    let label: String
    
    var body: View {
        ZStackView {
            VStackView {
                LabelView(value)
                    .color(.white)
                    .font(.systemFont(ofSize: 12, weight: .semibold))
                    .alignment(.center)
                LabelView(label)
                    .color(UIColor("#737373"))
                    .font(.systemFont(ofSize: 10, weight: .regular))
                    .alignment(.center)
            }
            .spacing(4)
        }
        .padding(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        .backgroundColor(UIColor(white: 0.1, alpha: 0.5)) // fallback for bg-neutral-900/50
        .cornerRadius(12)
        .border(color: UIColor(white: 1, alpha: 0.05), lineWidth: 1)
    }
}

// MARK: - Premium Banner
struct ProfilePremiumBanner: ViewBuilder {
    var body: View {
        HStackView {
            // Icon
            ZStackView {
                CircleView()
                    .size(width: 40, height: 40)
                    .backgroundColor(UIColor("#6366f1")) // indigo-500
                
                ImageView(UIImage(systemName: "star.fill"))
                    .tintColor(.white)
                    .contentMode(.center)
            }
            
            // Text
            VStackView {
                LabelView("Premium Plan")
                    .color(.white)
                    .font(.systemFont(ofSize: 14, weight: .medium))
                
                LabelView("Next billing on Nov 24")
                    .color(UIColor(red: 199/255, green: 210/255, blue: 254/255, alpha: 0.7)) // indigo-200/70
                    .font(.systemFont(ofSize: 10, weight: .regular))
            }
            .spacing(2)
            
            SpacerView()
            
            // Arrow
            ImageView(UIImage(systemName: "chevron.right"))
                .tintColor(UIColor("#818cf8")) // indigo-400
                .size(width: 20, height: 20)
        }
        .spacing(12)
        .padding(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        .backgroundColor(UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 0.05)) // indigo-500/5
        .cornerRadius(12)
        .border(color: UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 0.2), lineWidth: 1)
        .onTapGesture { _ in
            print("Premium banner tapped")
        }
    }
}

// MARK: - Settings Row
struct ProfileSettingsRow: ViewBuilder {
    let icon: String
    let title: String
    var titleColor: UIColor = UIColor("#E5E5E5")
    var iconColor: UIColor = UIColor("#A3A3A3")
    var rightView: View? = nil
    var isLast: Bool
    let action: () -> Void
    
    var body: View {
        let row = HStackView {
            ImageView(UIImage(systemName: icon))
                .tintColor(iconColor)
                .contentMode(.center)
                .size(width: 20, height: 20)
            
            LabelView(title)
                .color(titleColor)
                .font(.systemFont(ofSize: 14, weight: .medium))
            
            SpacerView()
            
            if let customUIView = rightView {
                customUIView
            }
        }
        .spacing(12)
        .padding(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        .onTapGesture { _ in action() }
        .alignment(.center)
        
        if !isLast {
            return ContainerView {
                VStackView {
                    row
                    FixedSpacerView(1)
                        .backgroundColor(UIColor(white: 1, alpha: 0.05))
                }
                .spacing(0)
            }
        }
        
        return ContainerView { row }
    }
}

// MARK: - Settings Toggle
struct ProfileSettingsToggle: ViewBuilder {
    let icon: String
    let title: String
    let isOn: Bool
    let isLast: Bool
    
    var body: View {
        let toggleUI = Toggle(isOn: isOn)
            .onTintColor(.systemPurple)
        
        return ProfileSettingsRow(
            icon: icon,
            title: title,
            rightView: toggleUI,
            isLast: isLast,
            action: { print("Toggle tapped: \(title)") }
        )
    }
}

// MARK: - General Settings Section
struct ProfileGeneralSettingsSection: ViewBuilder {
    var body: View {
        VStackView {
            LabelView("GENERAL")
                .color(UIColor("#737373")) // neutral-500
                .font(.systemFont(ofSize: 12, weight: .medium))
                .padding(top: 0, left: 4, bottom: 0, right: 0)
            
            VStackView {
                ProfileSettingsRow(
                    icon: "arrow.down.circle",
                    title: "Downloads",
                    rightView: HStackView {
                        VStackView {
                            LabelView("4.2 GB")
                                .color(UIColor("#737373"))
                                .font(.systemFont(ofSize: 10, weight: .regular))
                                .alignment(.right)
                            LabelView("used")
                                .color(UIColor("#525252"))
                                .font(.systemFont(ofSize: 10, weight: .regular))
                                .alignment(.right)
                        }
                        .spacing(0)
                        
                        ImageView(UIImage(systemName: "chevron.right"))
                            .tintColor(UIColor("#525252"))
                    }
                    .spacing(8),
                    isLast: false,
                    action: { print("Downloads tapped") }
                )
                
                ProfileSettingsToggle(icon: "bell", title: "Notifications", isOn: true, isLast: false)
                ProfileSettingsToggle(icon: "moon", title: "Dark Mode", isOn: false, isLast: true)
            }
            .spacing(0)
            .backgroundColor(UIColor(white: 0.1, alpha: 0.3)) // neutral-900/30
            .cornerRadius(16)
            .border(color: UIColor(white: 1, alpha: 0.05), lineWidth: 1)
        }
        .spacing(8)
    }
}

// MARK: - Account Settings Section
struct ProfileAccountSettingsSection: ViewBuilder {
    var body: View {
        let row1 = ProfileSettingsRow(
            icon: "creditcard",
            title: "Payment Methods",
            rightView: ImageView(UIImage(systemName: "chevron.right"))
                .tintColor(UIColor("#525252")),
            isLast: false,
            action: { print("Payment Methods tapped") }
        )
        
        let row2 = ProfileSettingsRow(
            icon: "exclamationmark.shield",
            title: "Security",
            rightView: ImageView(UIImage(systemName: "chevron.right"))
                .tintColor(UIColor("#525252")),
            isLast: false,
            action: { print("Security tapped") }
        )
        
        let row3 = ProfileSettingsRow(
            icon: "rectangle.portrait.and.arrow.right",
            title: "Log Out",
            titleColor: UIColor("#f43f5e"), // rose-500
            iconColor: UIColor("#f43f5e").withAlphaComponent(0.8), // rose-500/80
            rightView: nil,
            isLast: true,
            action: { print("Log Out tapped") }
        )
        
        let stack = VStackView {
            row1
            row2
            row3
        }
        .spacing(0)
        .backgroundColor(UIColor(white: 0.1, alpha: 0.3)) // neutral-900/30
        .cornerRadius(16)
        .border(color: UIColor(white: 1, alpha: 0.05), lineWidth: 1)
        
        return VStackView {
            LabelView("ACCOUNT")
                .color(UIColor("#737373")) // neutral-500
                .font(.systemFont(ofSize: 12, weight: .medium))
                .padding(top: 0, left: 4, bottom: 0, right: 0)
            
            stack
        }
        .spacing(8)
    }
}

// MARK: - Version Info
struct ProfileVersionInfo: ViewBuilder {
    var body: View {
        LabelView("Version 2.4.0 (Build 892)")
            .color(UIColor("#404040")) // neutral-700
            .font(.systemFont(ofSize: 10, weight: .regular))
            .alignment(.center)
            .padding(top: 0, left: 0, bottom: 16, right: 0)
    }
}

struct ProfileNavbar: ViewBuilder {
    var body: View {
        ZStackView {
            BlurView(style: .dark)
        }
        .border(color: UIColor(white: 1.0, alpha: 0.05), lineWidth: 1)
        .height(60)
        .position(.top)
        .safeArea(false)
    }
}
