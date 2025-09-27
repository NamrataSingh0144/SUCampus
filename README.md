🎓 Campus Connect
<p align="center">
<img src="https://www.google.com/search?q=https://placehold.co/800x200/673AB7/FFFFFF%3Ftext%3DCampus%2520Connect%26font%3Draleway" alt="Campus Connect Banner">
</p>

<p align="center">
<strong>A multi-portal Flutter application designed to digitize the on-campus commercial experience.</strong>







<!-- Badges for professionalism -->
<img src="https://www.google.com/search?q=https://img.shields.io/badge/Flutter-3.x-blue%3Flogo%3Dflutter" alt="Flutter Version">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/Firebase-Integrated-orange%3Flogo%3Dfirebase" alt="Firebase">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

✨ About The Project
Campus Connect is a mobile-first platform aimed at creating a fully integrated digital ecosystem for college campuses. The primary goal is to bridge the gap between students/faculty and on-campus vendors (restaurants, shops, etc.) by providing a unified app for ordering, booking services, and handling payments.

The application is designed with three distinct user portals to cater to the unique needs of each group: a user-friendly interface for Students, a powerful dashboard for Shop Owners, and a comprehensive management panel for Admins.

📱 Screenshots
Here's a sneak peek of the user interface.

Login Screen

Sign-Up Screen

<img src="https://www.google.com/search?q=https://i.imgur.com/K1oYj7G.png" alt="Login Screen" width="250">

<img src="https://www.google.com/search?q=https://i.imgur.com/xT5jFqR.png" alt="Sign-Up Screen" width="250">

More screenshots for Student, Shop, and Admin portals coming soon!

🚀 Key Features
👥 Multi-Role Architecture: Separate, tailored experiences for Students, Shops, and Admins.

🛒 Vendor Integration: On-campus shops and restaurants can list their products and services.

🍔 Food & Item Ordering: Students and faculty can browse menus and place orders directly through the app.

💳 Secure Payments: Future integration with a payment gateway to handle all transactions.

🔔 Real-time Updates: Order tracking and status notifications.

🛠️ Technology Stack
This project is built using a modern, scalable tech stack:

Frontend: Flutter

Backend & Database: Firebase (Authentication, Firestore, Storage)

State Management: (To be decided - e.g., Provider, Bloc)

Iconography: Font Awesome Flutter

📂 Project Structure
The project follows a clean, feature-first architecture to ensure scalability and separation of concerns.
```
├── lib
│   ├── core
│   │   ├── models
│   │   │   └── user_role.dart
│   │   └── services
│   ├── features
│   │   ├── admin
│   │   │   └── screens
│   │   ├── auth
│   │   │   └── ...
│   │   ├── shop
│   │   │   └── screens
│   │   └── student
│   │       └── screens
│   └── main.dart
```
🏁 Getting Started
To get a local copy up and running, follow these simple steps.

Prerequisites
Flutter SDK (3.x or newer)

An editor like VS Code or Android Studio

### Installation
1. Clone the repo:

``` git clone [https://github.com/](https://github.com/)[YourGitHubUsername]/[YourRepoName].git ```

2. Navigate to the project directory:

```cd [YourRepoName] ```

3. Install dependencies:

``` flutter pub get ```

4. Set up Firebase:

This project requires a Firebase backend. Please create your own Firebase project and add the necessary google-services.json (for Android) and GoogleService-Info.plist (for iOS) files. (This step will be required for backend integration).

5. Run the app:

```flutter run```
