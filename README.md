
# Event Tracker

Event Tracker is a cross-platform mobile app built with Flutter for creating, sharing and RSVP-ing to events. This repository also contains an ASP.NET Core Web API (in the `EventTrackerAPI/` folder) which provides backend services such as authentication, event storage, invites, and comments.

This README explains the app, how to run the Flutter client and the API locally (PowerShell on Windows), architecture overview, useful scripts, and contribution notes so you can add the project to GitHub and other collaborators can get started quickly.

---

## Table of contents

- Project overview
- Features
- Repo layout
- Quick start (Windows / PowerShell)
- Architecture & data model
- Testing & debugging
- Assets & DB migrations
- Contributing
- License & credits

---

## Project overview

Event Tracker lets users create events, invite others, accept/decline invites, and comment on events. The Flutter frontend communicates with the ASP.NET Core backend API which persists data using Entity Framework Core. The API contains controllers, models, and EF migrations; the Flutter app contains UI, services and controllers for interacting with the API.

High-level goals:

- Provide a simple event management UX on mobile and web
- Keep business logic on the API for shared consistency
- Use EF Core migrations for database versioning and optional SQL scripts for manual adjustments (see `Extra/`)

## Features

- Create, edit and delete events
- Invite users to events and track invite status (accepted, declined, pending)
- Add comments to events
- Support for recurring events (database schema includes recurring fields)
- Authentication handled by the API (see controllers in `EventTrackerAPI/Controllers`)

## Repo layout

- `event_tracker/` — Flutter app (root of this workspace)
	- `lib/` — application source (controllers, models, services, views, widgets)
	- `assets/` — images and other static resources
	- `pubspec.yaml` — dependencies and assets defined here
- `EventTrackerAPI/` — ASP.NET Core Web API
	- `Controllers/` — REST endpoints (AuthController, EventsController, etc.)
	- `Models/` — EF Core models and DbContext
	- `Migrations/` — EF Core migrations
	- `appsettings.json` / `appsettings.Development.json` — configuration
- `Extra/` — SQL scripts and notes (e.g., `add_participant_count.sql`)

Files of interest:

- `EventTrackerAPI/EventTrackerAPI.http` — example HTTP requests
- `Extra/` — helper SQL scripts and exported images

## Quick start (Windows / PowerShell)

These steps show how to run both the Flutter app and the API locally. Use separate terminals for each process.

### Prerequisites

- Flutter SDK (stable) installed and on PATH: https://docs.flutter.dev/get-started
- .NET SDK 7.0+ installed (see `EventTrackerAPI/global.json` for target)
- Android SDK / emulator or a physical device for mobile testing
- A local database (SQL Server, SQLite or PostgreSQL) and credentials updated in the API config

### Run the Flutter app

Open PowerShell and run the following from the Flutter project folder:

```powershell
cd 'd:\College\Semsters\Semster 5\Advance Flutter\Project\Event Tracker\event_tracker'
flutter pub get
# List devices
flutter devices
# Run on a selected device (replace <device-id> with the id from flutter devices)
flutter run -d <device-id>
```

To run the app in a browser:

```powershell
flutter run -d chrome
```

If you use VS Code or Android Studio, open the `event_tracker` folder and use their run/debug features.

### Run the ASP.NET Core API locally

1. Open a new PowerShell and change directory to the API project:

```powershell
cd 'd:\College\Semsters\Semster 5\Advance Flutter\Project\Event Tracker\EventTrackerAPI\EventTrackerAPI'
```

2. Configure the database connection in `appsettings.Development.json` or `appsettings.json`.

3. Restore packages, apply migrations and run the API:

```powershell
dotnet restore
dotnet tool install --global dotnet-ef # if dotnet-ef is not installed
dotnet ef database update
dotnet run
```

The API will print the listening URL(s) such as `https://localhost:5001`. Update the Flutter app's API base URL (search in `lib/service` for the client base URL) to point to the running API.

Notes:
- Avoid committing secrets — use `appsettings.Development.json` for local values and environment variables in CI/production.
- If you prefer raw SQL, use the scripts in `Extra/` to update the DB.

## Architecture & data model

- Frontend: Flutter app with a modular structure (`lib/controller`, `lib/service`, `lib/model`, `lib/view`, `lib/widgets`). Network calls and business logic are handled in services/controllers.
- Backend: ASP.NET Core Web API using Entity Framework Core. Core models include `Event`, `EventInvite`, `User`, `EventComment`. Check `EventTrackerAPI/Models` for model definitions.
- Realtime: If the project uses SignalR, the `Hubs/` folder contains hub implementations.

Data flow:

1. Flutter client authenticates and obtains a token (if auth is enabled).
2. Client calls API endpoints to create/update events, manage invites, and post comments.
3. API persists data with EF Core and can return event lists, invite status, and comments.

## Testing & debugging

- Flutter tests: run `flutter test` from the Flutter project root. There is an example `test/widget_test.dart`.
- API tests: none included by default. Use `dotnet test` if you add test projects. You can exercise the API endpoints using the provided `EventTrackerAPI.http` file or with Postman/Insomnia.

## Assets & database migrations

- Images used by the app are in `event_tracker/assets/images/` and `Extra/Images/`.
- EF Core migrations are in `EventTrackerAPI/Migrations/`. Use `dotnet ef database update` to apply migrations.
- SQL helper scripts are in `Extra/` for manual patching or exploratory work.

## Contributing

If you'd like to contribute:

1. Fork the repository and create a feature branch.
2. Run the Flutter client and API locally and add tests for new functionality.
3. Open a pull request describing the change and include screenshots or recordings for UI changes.

Maintainer notes:
- Add CI to run `flutter analyze`, `flutter test` and `dotnet build` on PRs.
- Keep secrets out of source control; use environment variables for production settings.

## License & credits

This repository does not include a LICENSE file. To make reuse explicit, add a license such as MIT by creating a `LICENSE` file.
