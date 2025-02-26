# SeekCam

SeekCam is a Flutter project that leverages CameraX for camera functionalities and Pigeon for platform communication. The project is structured using a feature-based architecture, adhering to clean architecture principles and design patterns.

## Project Structure

The project is divided into the following main directories:

- `lib`: Contains the main source code of the application.
- `core`: Contains core functionalities and utilities used across the application.
- `injection`: Manages dependency injection configurations.
- `features`: Contains feature-specific code, each feature having its own directory.
- `main.dart`: The entry point of the application.

## Features

The project is organized into multiple features, each encapsulated within its own directory under `lib/features`. This modular approach ensures better maintainability and scalability.

### Camera

The Camera feature uses CameraX for camera functionalities. It includes:

- `camera_screen.dart`: The main screen for camera preview and QR code scanning.
- `camera_controller.dart`: Manages the camera operations and QR code detection.

### Authentication

The Authentication feature handles biometric authentication using Pigeon for platform communication. It includes:

- `biometric_auth_pigeon.dart`: Auto-generated code for platform communication.
- `auth_screen.dart`: The main screen for authentication.

### Storage

The Storage feature manages secure storage of data. It includes:

- `secure_storage.dart`: Handles secure storage operations.

### Permissions

The Permissions feature manages runtime permissions. It includes:

- `permission_handler.dart`: Abstract class for permission handling.
- `permission_handler_impl.dart`: Implementation of the permission handler.
- `permission_handler_screen.dart`: Screen for requesting permissions.

## Dependency Injection

The project uses `injectable` and `get_it` for dependency injection. The `injection` directory contains the configuration for dependency injection, ensuring that dependencies are managed efficiently and injected where needed.

## Communication with Platform

Pigeon is used for communication between Flutter and the host platform (Android/iOS). This ensures a seamless integration of platform-specific functionalities like biometric authentication.

## Design Patterns and Clean Architecture

The project follows clean architecture principles, ensuring a clear separation of concerns. Key design patterns used include:

- **Repository Pattern**: For data management and abstraction.
- **State Management**: Using `ValueNotifier` for managing state within widgets.
- **Dependency Injection**: For managing dependencies and promoting testability.

## Getting Started

To get started with the project, follow these steps:

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to start the application.

For more information on Flutter development, refer to the [Flutter documentation](https://docs.flutter.dev/).

## License

This project is licensed under the MIT License.