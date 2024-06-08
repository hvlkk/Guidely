# Guidely

## Table of Contents

- [Guidely](#guidely)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Features](#features)
  - [Installation](#installation)
  - [Directory Structure](#directory-structure)
  - [Contributors](#contributors)

## Description

Guidely is an application designed to allow users to host free walking tours, aiming at a more interactive user experience before, throughout, and after the tour. The front-end was developed using Flutter, and the back-end was developed using Firebase. A web server was also created using Flask, HTML, CSS and Javascript, in order to allow the administrators of the app to approve and reject tour guide applications.

## Features

Notable features include:

- Live location tracking for guides, allowing users to follow tours at their own pace.
- Voice chat during tours, enabling users to listen to guides without interruption from noisy environments.
- Text chat during tours for a more interactive user experience.
- Quizzes created by the tour guide, available after a tour session.
- Tour recommendation algorithm based on various factors.
- Custom web server for administrators to manage tour guide applications.

## Installation

1. Install Flutter. You can follow the steps provided [here](https://docs.flutter.dev/get-started/install).
2. Clone the repository.
3. Navigate to the directory you installed the repository in.
4. Run `flutter pub get`, to ensure you have access to the flutter libraries used across the project.
5. Open up an Android emulator, or an Android phone in developer mode that's connected to your computer. See the related [Android Studio](https://developer.android.com/studio/run/managing-avds) page for a guide on how to set up an Android Virtual Device.
6. Run `main.dart` using either `flutter run ./lib/main.dart` from the CLI or 'Run Without Debugging' in Visual Studio Code under the Run tab.

## Directory Structure

The code is hosted inside the [lib folder](https://github.com/hvlkk/Guidely/tree/main/lib). Brief directory descriptions follow:

- _bloc_: Business logic components used throughout the project.
- _configs & misc_: Contain a single file each for the app config and global variables respectively.
- _models_: Data models used throughout the project.
- _providers_: Setup for the [riverpod](https://pub.dev/packages/flutter_riverpod) providers used across the project.
- _repositories_: Adheres to the repository design pattern, used for database access.
- _screens_: Screen widgets.
- _services_: Services used throughout the project.
- _utils_: Utility files used throughout the project.
- _web_server_: Projects setting up the web server for tour guide application approvals and rejections.
- _widgets_: Non-screen widgets used across the project.

## Contributors

- [kwstaseL](https://github.com/kwstaseL)
- [Ippo03](https://github.com/Ippo03)
- [hvlkk](https://github.com/hvlkk)
