# Todo Reminder Flutter App

A comprehensive Flutter application for managing todos with advanced features and backend integration.

## Getting Started

This project serves as a robust Flutter todo app including:

- User authentication via Google Sign-In and Supabase
- Creating, editing, deleting todos with deadlines
- Task completion toggle with UI indication
- Categories/tags and priority levels for todos, with filtering
- Recurring todos (daily, weekly, monthly)
- Push notifications to remind about upcoming tasks
- Data syncing in real-time with Supabase backend
- Export todo list as CSV (copy to clipboard)

Helpful resources if new to Flutter:

- [Flutter official codelabs](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook - useful samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev)

## Features

- **Authentication:** Google OAuth using Supabase
- **Todo Management:** Add, edit or remove tasks on a schedule
- **Task Completion:** Mark tasks done with checkboxes and strikethrough effect
- **Categorization:** Assign tags and priority, filter by those
- **Recurring Tasks:** Set tasks to repeat automatically
- **Notifications:** Receive local notifications an hour before deadline
- **Sync:** Real-time updates via Supabase subscriptions
- **Export:** Export and copy your todo list as CSV file to clipboard

## Screenshots

_(Add screenshots here to illustrate your app UI)_

## Project Setup

### Prerequisites

- Flutter SDK (v3.0 or greater)
- Dart SDK (comes with Flutter)
- Supabase account and backend service
- Android Studio or VS Code setup for Flutter development

### Installation

git clone git commit -m "Initial commit - Flutter todo app with features"

cd your-repo
flutter pub get

Configure your Supabase credentials and Firebase if applicable in the project.

Run the app:

flutter run

## Project Structure

lib/
├── main.dart # Entry point with providers and initialization
├── auth_service.dart # Authentication logic with Supabase
├── todo_service.dart # Business logic for todos and syncing
├── todo_model.dart # Todo data model definition
├── notification_service.dart # Handles local notifications scheduling
├── home_screen.dart # Main screen showing todo list and filters
├── add_todo_screen.dart # Screen to add new todos with details
├── login_screen.dart # Login screen for Google sign-in


## Usage

- Launch app and sign in with Google
- Add todos with title, deadline, category, priority, recurrence
- Mark todos as complete; filter and search your tasks
- View notifications reminding you about upcoming deadlines
- Export your todo list anytime as CSV

## Contributing

Pull requests and issues welcome! To contribute:

1. Fork repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request for review

Ensure your code follows project style and includes tests if needed.

## License

Licensed under the MIT License.

## Contact

For questions or support, contact: your-email@example.com

---

Thank you for checking out the Todo Reminder Flutter App!
