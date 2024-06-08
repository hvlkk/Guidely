# Guidely

- [Guidely](#guidely)
  - [Description](#description)
  - [Features](#features)
  - [Installation](#installation)
  - [Directory Structure](#directory-structure)
  - [Contributors](#contributors)

## Description

Guidely is an application designed to allow users to host free walking tours, aiming at a more interactive user experience before, throughout, and after the tour. The front-end was developed using Flutter, and the back-end was developed using Firebase. A web server was also created using Flask, HTML, CSS and Javascript, in order to allow the administrators of the app to approve and reject tour guide applications.

## Features

Notable features include:

- Live location tracking for the guide of a tour, allowing users to follow along a tour at their own pace
- Voice chat during tours, enabling users to listen to tour guides uninterrupted by crowdy places and outside noises
- Text chatting during tours, in order to allow for a more interactive experience
- Quizzes curated by the tour guide can be taken following the successful conclusion of a tour session
- Tour recommendation algorithm based on multiple factors
- A custom web server, which allows administrators of the application to approve/reject tour guide applications

## Installation

1. Install Flutter. You can follow the steps provided [here](https://docs.flutter.dev/get-started/install).
2. Clone the repository.
3. Navigate to the directory you installed the repository in.
4. Run `flutter pub get`, to ensure you have access to the flutter libraries used across the project.
5. Open up an Android emulator, or an Android phone in developer mode that's connected to your computer.
6. Run `main.dart`. This can be achieved either by running `flutter run ./lib/main.dart` through CLI (provided you are still on the directory the project was installed in), or if you are using Visual Studio Code, by clicking on 'Run Without Debugging' under the Run tab.

## Directory Structure

The code is hosted inside the [lib folder](https://github.com/hvlkk/Guidely/tree/main/lib). Brief directory descriptions follow:

- _bloc_: Contains the business logic components used throughout the project.
- _configs & misc_: Contain a single file each, for the app config and the "global" variables used throughout the project respesctfully.
- _models_: Contains files for the data models used throughout the project.
- _providers_: Contains the files that set up the [riverpod](https://pub.dev/packages/flutter_riverpod) providers used across the project.
- _repositories_: Contains the files that adhere to the repository design pattern, and are used for database access.
- _screens_: Contains the files which represent screen widgets.
- _services_: Contains the files which are used as services throughout the project.
- _utils_: Contains the utility files used throughout the project.
- _web_server_: Contains the projects that set up the web server used for tour guide application approvals & rejections.
- _widgets:_ Contains all the (non-screen) widgets used across the project.

## Contributors

- [kwstaseL](https://github.com/kwstaseL)
- [Ippo03](https://github.com/Ippo03)
- [hvlkk](https://github.com/hvlkk)
