# Habitualz - Habit Tracking App

<img src="screenshots/app_icon.png" alt="Habitualz App Icon" width="100"/>

## Overview
Habitualz is a comprehensive habit tracking application designed to help users build and maintain positive habits through visual tracking, analytics, and customizable reminders. The app provides an intuitive interface for daily habit monitoring with powerful visualization tools to keep users motivated.

## Features

### Authentication & User Management
- **Firebase Authentication**: Secure email/password login and registration
- **Account Recovery**: Password reset functionality via email
- **Profile Management**: Update profile information and account settings
- **Account Deletion**: Complete user data removal option

### Habit Tracking
- **Daily Check-ins**: Mark habits as complete with a simple tap
- **Habit Categories**: Organize habits by category (health, productivity, learning, etc.)
- **Custom Habits**: Create personalized habits with descriptions and frequency
- **Streak Tracking**: Monitor consecutive days of habit completion
- **Reminder System**: Customizable notifications for habit completion

### Analytics & Visualization
- **Interactive Heatmap**: Visual representation of habit consistency over time
- **Streak Analytics**: View current and best streaks for motivation
- **Completion Rate**: Percentage-based success metrics
- **Progress Trends**: Charts showing improvement over days, weeks, and months

### UI/UX Features
- **Theme Customization**: Toggle between light and dark themes
- **Responsive Design**: Optimized for various screen sizes
- **Intuitive Navigation**: Easy-to-use interface with gesture support
- **Offline Support**: Continue tracking habits without internet connection

## Technologies Used
- **Flutter & Dart**: Cross-platform framework for the frontend
- **Firebase Authentication**: User authentication and management
- **Cloud Firestore**: Real-time database for habit and user data
- **Firebase Analytics**: App usage and performance monitoring
- **Provider Pattern**: State management

## Screenshots

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
    <img src="screenshots/login_screen.png" alt="Login Screen" width="200"/>
    <img src="screenshots/home_screen.png" alt="Home Screen" width="200"/>
    <img src="screenshots/heatmap_view.png" alt="Heatmap View" width="200"/>
    <img src="screenshots/analytics_screen.png" alt="Analytics Screen" width="200"/>
    <img src="screenshots/settings_screen.png" alt="Settings Screen" width="200"/>
</div>

## Installation

1. Clone this repository
```bash
git clone https://github.com/jiteshh-10/habitualz.git
```

2. Navigate to the project directory
```bash
cd habitualz
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Future Enhancements
- Social habit sharing and challenges
- Integration with health apps
- Extended analytics with machine learning insights
- Gamification elements for increased motivation

## Contribution
Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/jiteshh-10/habitualz/issues) if you want to contribute.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
