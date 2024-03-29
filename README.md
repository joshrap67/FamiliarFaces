# Familiar Faces

Mobile application that assists in recognizing actors that you have seen in previous movies or tv shows.
The application interacts with a free REST API, [TMDB](https://developers.themoviedb.org/3/getting-started/introduction)

All data is currently only stored on the phone's hard drive. Since this is not published, it is doubtful I will go through the trouble of setting up user accounts/remote storage.

[Demo of Familiar Faces version 1.2.0](https://www.youtube.com/watch?v=mzX-GcXjbMg)

## Prerequisites

This application is currently only published for Android devices. The minimum SDK version that this application can run on is: 21. The targeted SDK for this application is: 31.

An internet connection is required to run this application.

If pulling from this repository, Flutter is required in order to run the application.

## Installation

Due to potential copyright issues and potential un-moderated data, this app is not currently published on Google Play. A signed app bundle is available in this repository for downloading.

If pulling from this repository, open the project and run it using Flutter (can be done via CLI). If doing it this way, you may need to ensure that you have developer options enabled on your device.

If already installed you _must_ update the app with the command `adb install -r` as otherwise the local SQLite database will be wiped.
## Built With

- [Flutter](https://flutter.dev/) - Framework that the frontend was built with.

- [TMDB](https://developers.themoviedb.org/3/getting-started/introduction) - Source of data

- [Android Studio](https://developer.android.com/studio) - IDE that was used to build the frontend.

## Authors

- Joshua Rapoport - _Creator and Lead Software Developer_

## Acknowledgments

[App Logo Derived From Existing SVG](https://www.svgrepo.com/svg/190443/video-player-movie)
