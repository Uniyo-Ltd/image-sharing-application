# Image Sharing Application

A Flutter application for sharing and exploring images using the Imgur API.

## Features

- Browse popular images from Imgur
- Search for images with a search bar
- View images in a responsive tiled layout
- View detailed information about images
- Save favorite images locally
- Track recent searches
- Infinite scrolling for continuous content loading

## Technologies Used

- Flutter for cross-platform mobile development
- BLoC pattern for state management
- Imgur API for image data
- HTTP package for API communication
- SharedPreferences for local storage
- Unit tests for code reliability

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Project Structure

- `lib/` - Contains all Dart code for the application
  - `api/` - API clients and services
  - `bloc/` - BLoC state management components
  - `models/` - Data models
  - `screens/` - UI screens
  - `widgets/` - Reusable UI components
  - `utils/` - Utility functions and constants

## Testing

Run tests with:
```
flutter test
``` 