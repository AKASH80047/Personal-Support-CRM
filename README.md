# SupportCRM — Personal Support & CRM Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Deploy Flutter Web](https://github.com/AKASH80047/Personal-Support-CRM/actions/workflows/deploy.yml/badge.svg)](https://github.com/AKASH80047/Personal-Support-CRM/actions/workflows/deploy.yml)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-success?style=for-the-badge&logo=github)](https://akash80047.github.io/Personal-Support-CRM/)

> **Live Application URL:** [https://akash80047.github.io/Personal-Support-CRM/](https://akash80047.github.io/Personal-Support-CRM/)

SupportCRM is a modern, responsive, multi-platform customer support and CRM application built with Flutter. It streamlines ticket management, team collaboration, conversation tracking, and customer relationship workflows with a modern UI and built-in AI copilot tooling.

---

## 🚀 Live Demo

Try the application directly in your browser:
👉 **[Open SupportCRM Web Demo](https://akash80047.github.io/Personal-Support-CRM/)**

---

## ✨ Features

- 📊 **Executive Dashboard**: Real-time KPI metrics, active tickets, resolution rates, and performance trends.
- 🎫 **Ticket Management**: Create, assign, filter, and track tickets across states (Open, In Progress, Resolved, Closed).
- 💬 **Unified Inbox**: Omnichannel support chat and conversation threading with customers.
- 👥 **Customer Directory**: Complete customer profiles, interaction history, contact metadata, and tags.
- 🏢 **Teams & Agents**: Manage support agents, specialties, availability, and workloads.
- 🤖 **AI Support Copilot**: AI-assisted response suggestions and automated summarization.
- 📚 **Knowledge Base**: Help center articles, search indexing, and self-serve documentation.
- 📈 **Analytics & Reports**: Visual charts and breakdown by channel, category, and SLA resolution times.
- 🎨 **Responsive UI & Themes**: Clean desktop/tablet/mobile friendly layouts with customized typography and animations.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Web, Windows, macOS, Linux, iOS, Android)
- **Language**: [Dart](https://dart.dev)
- **State Management**: `flutter_bloc`
- **Routing**: `go_router`
- **Charts & Visualizations**: `syncfusion_flutter_charts`
- **Backend / Storage**: `supabase_flutter`, `hive_flutter`, `flutter_secure_storage`
- **Typography & Icons**: `google_fonts`, `cupertino_icons`
- **CI / CD**: GitHub Actions deploying automatically to GitHub Pages

---

## 💻 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>=3.13.2`)
- Google Chrome (for web testing) or target desktop/mobile emulator

### Setup Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/AKASH80047/Personal-Support-CRM.git
   cd Personal-Support-CRM
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app locally:**
   ```bash
   # Run in Chrome
   flutter run -d chrome

   # Or run on Windows Desktop
   flutter run -d windows
   ```

5. **Build for production web:**
   ```bash
   flutter build web --release --base-href "/Personal-Support-CRM/"
   ```

---

## 📄 License

This project is licensed under the MIT License.
