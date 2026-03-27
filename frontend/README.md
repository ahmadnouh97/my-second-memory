# Second Memory — Flutter Frontend

Modern Flutter app for the [Second Memory](../README.md) project. Targets **Android** (native) and **Web** (Chrome).

## Stack

| | |
|---|---|
| Language | Dart 3.11 / Flutter 3.41 |
| State | flutter_riverpod (`StateNotifierProvider`) |
| Navigation | go_router |
| Models | freezed + json_serializable (immutable) |
| HTTP / SSE | http package |
| Images | cached_network_image |
| Animations | flutter_animate + shimmer |
| Fonts | google_fonts (Inter) |
| Android share | receive_sharing_intent |
| URL launch | url_launcher |
| SVG | flutter_svg |

## Running

```bash
# Web (Chrome)
flutter run -d chrome

# Android emulator or connected device
flutter run

# Release APK
flutter build apk --release

# Override backend URL (real device on LAN)
flutter run --dart-define=BACKEND_URL=http://192.168.1.x:8001
```

## Code Generation

Run after editing any `lib/models/*.dart` file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Regenerate app icons after changing `assets/logo.svg`:

```bash
dart run flutter_launcher_icons
```

## Project Structure

```
lib/
├── main.dart                  # App entry, share intent listener
├── config/
│   ├── environment.dart       # Backend base URL (dev / prod)
│   └── router.dart            # go_router routes
├── models/
│   ├── item.dart              # Item, PaginatedResponse, ExtractPreview
│   └── chat_message.dart      # ChatMessage, ChatChunk (SSE union)
├── services/
│   ├── api_service.dart       # All HTTP calls + SSE chat stream
│   └── share_service.dart     # Android share intent
├── providers/
│   ├── items_provider.dart    # List, search, filter, pagination
│   └── chat_provider.dart     # Streaming chat state
├── theme/
│   └── app_theme.dart         # Material 3 dark, design tokens
├── widgets/
│   ├── item_card.dart         # Glassmorphism card with type-color glow
│   ├── filter_bar.dart        # Collapsible type + tag multi-select
│   ├── chat_item_card.dart    # Compact card for chat responses
│   ├── content_type_badge.dart
│   ├── tag_chip.dart
│   └── shimmer_card.dart
└── pages/
    ├── home_page.dart         # Search, filter, infinite scroll
    ├── add_item_page.dart     # URL → extract → preview → save
    ├── item_detail_page.dart  # Hero image, view / edit mode
    └── chat_page.dart         # SSE streaming, typing indicator

assets/
└── logo.svg                   # App logo (source for all launcher icons)
```

## Design System

| Token | Value |
|---|---|
| Background | `#080B1E` (deep navy) |
| Primary | `#6366F1` (electric indigo) |
| Accent | `#F59E0B` (amber — AI sparkle) |
| YouTube | `#EF4444` |
| Instagram | `#A855F7` |
| Article | `#3B82F6` |
| Link | `#6B7280` |
| Font | Inter (via google_fonts) |
