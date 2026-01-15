# Git History Simulation Guide

This guide will help you create a **new** Git repository and "replay" your development process to look like a professional, version-controlled project with branches, commits, and versions.

## 🏗️ Workflow Overview
For every "Feature" listed below, you will follow this exact cycle:
1.  **Checkout Main**: `git checkout main`
2.  **Create Branch**: `git checkout -b feature/name-of-feature`
3.  **Copy Files**: Copy the specific files for that feature from your *completed* project to this *new* folder.
4.  **Commit**: `git add .` and `git commit -m "Implement [Feature Name]"`
5.  **Merge**: Switch back to main and merge.
6.  **Tag (Optional)**: release versions (v1.0, v1.1) to show progress over "days".

---

## 🚀 Step 0: Initial Setup
**Goal**: Create the empty repository structure.

1.  Create a **NEW** empty folder (e.g., `resort-system-git`).
2.  Open terminal in this new folder.
3.  Initialize Git:
    ```bash
    git init
    git branch -m main
    ```
4.  Create a `README.md` file:
    ```markdown
    # Ocean View Resort Management System
    A Java EE web application for managing hotel reservations.
    ```
5.  Create a `.gitignore` file (important for Java projects):
    ```text
    /target/
    /.idea/
    /.vscode/
# 🚀 Ocean View Resort - Git Simulation Plan (Complete Details)

This plan helps you recreate a professional 6-day development history with **CI/CD active from Day 1**.

---

## 🏗️ The CI/CD Workflow (`.github/workflows/maven.yml`)
**Create this file on Day 1.** This is the "Automated Engine" that will build your project on GitHub every time you push code.

```yaml
name: Java CI/CD with Maven

on:
  push:
    branches: [ "main", "feature/**" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    - name: Build with Maven
      run: mvn -B package --file pom.xml

    - name: Upload Build Artifact
      uses: actions/upload-artifact@v4
      with:
        name: ocean-view-resort-war
        path: target/*.war
```

---

## 📅 Day 1: Core Infrastructure & CI/CD Setup
**Goal**: Initialize the repository and setup the build pipeline.

1.  **Init Git**: `git init`
2.  **Create `README.md`**:
    ```markdown
    # Ocean View Resort Management System
    A Java EE web application for managing hotel reservations.
    ```
3.  **Create `.gitignore`**:
    ```text
    /target/
    /.idea/
    /.vscode/
    *.class
    *.log
    ```
4.  **Copy Files**:
    *   `pom.xml`
    *   `src/main/resources/db.properties`
    *   `src/main/java/com/dinod/ocean_view_resort/utill/DBConnection.java`
    *   `src/main/java/com/dinod/ocean_view_resort/utill/ConnectionProvider.java`
    *   `src/main/java/com/dinod/ocean_view_resort/model/User.java`
    *   `src/main/java/com/dinod/ocean_view_resort/model/Guest.java`
    *   `src/main/java/com/dinod/ocean_view_resort/model/Room.java`
    *   `src/main/java/com/dinod/ocean_view_resort/model/Reservation.java`
    *   `.github/workflows/maven.yml` (The code provided above)
5.  **Commit**: 
    ```bash
    git add .
    git commit -m "Initial commit: Setup core architecture and GitHub Actions CI/CD"
    ```
6.  **Push**:
    ```bash
    git remote add origin YOUR_GITHUB_REPO_URL
    git branch -M main
    git push -u origin main
    ```
    *   *Check GitHub: You should see the CI/CD build starting immediately!*

---

## 📅 Day 2: User Authentication & Registration
**Goal**: Allow staff members to register and log in to the system.

1.  **Branch**: `git checkout -b feature/auth-system`
2.  **Copy Files**:
    *   `src/main/java/com/dinod/ocean_view_resort/dao/UserDao.java` & `UserDaoImpl.java` (Login & Save/Register logic)
    *   `src/main/java/com/dinod/ocean_view_resort/service/UserService.java` & `UserServiceImpl.java`
    *   `src/main/java/com/dinod/ocean_view_resort/controller/AuthController.java` (Handles both login and registration requests)
    *   `src/main/webapp/register.jsp` (The enrollment page)
    *   `src/main/webapp/login.jsp` (The login page)
    *   `src/main/webapp/staff-dashboard/index.jsp` (Basic nav cards)
3.  **Commit**: 
    ```bash
    git add .
    git commit -m "Implement user registration, authentication, and login flow"
    ```
4.  **Merge & Push**:
    ```bash
    git push -u origin feature/auth-system
    git checkout main
    git merge feature/auth-system
    git tag v0.1-alpha
    git push origin main
    git push --tags
    ```

---

## 📅 Day 3: Guest Management
**Goal**: Add, Edit, and Delete Guests.

1.  **Branch**: `git checkout -b feature/guest-management`
2.  **Copy Files**:
    *   `src/main/java/com/dinod/ocean_view_resort/dao/GuestDao.java` & `GuestDaoImpl.java`
    *   `src/main/java/com/dinod/ocean_view_resort/service/GuestService.java` & `GuestServiceImpl.java`
    *   `src/main/java/com/dinod/ocean_view_resort/controller/GuestController.java`
    *   `src/main/webapp/staff-dashboard/guest.jsp`
3.  **Commit**:
    ```bash
    git add .
    git commit -m "Implement full Guest management module"
    ```
4.  **Merge & Push**:
    ```bash
    git push -u origin feature/guest-management
    git checkout main
    git merge feature/guest-management
    git push origin main
    ```

---

## 📅 Day 4: Room & Reservation System
**Goal**: Core booking logic with availability checks.

1.  **Branch**: `git checkout -b feature/reservations`
2.  **Copy Files**:
    *   **Room**: `RoomDao`, `RoomDaoImpl`, `RoomService`, `RoomServiceImpl`, `RoomController`
    *   **Reservation**: `ReservationDao`, `ReservationDaoImpl`, `ReservationService`, `ReservationServiceImpl`, `ReservationController`
    *   **UI**: `src/main/webapp/staff-dashboard/reservations.jsp`
3.  **Commit**:
    ```bash
    git add .
    git commit -m "Implement Room management and Reservation booking engine"
    ```
4.  **Merge & Push**:
    ```bash
    git push -u origin feature/reservations
    git checkout main
    git merge feature/reservations
    git tag v0.8-beta
    git push origin main
    git push --tags
    ```

---

## 📅 Day 5: Billing, Help & Distributed Web Services
**Goal**: Finalize staff dashboard tools and transition to a RESTful architecture.

1.  **Branch**: `git checkout -b feature/billing-help-and-distributed`
2.  **Steps**:
    *   **New**: `help.jsp`
    *   **Update**: `bill.jsp` (Final calculation logic)
    *   **Architecture**: Update **ALL Controllers** (`Guest`, `Room`, `Reservation`) to support RESTful endpoints returning JSON.
    *   **Distributed UI**: Implement **AJAX (JavaScript)** in dashboards to fetch data from these new APIs, moving away from server-side rendering.
3.  **Commit & Push**:
    ```bash
    git add .
    git commit -m "Implement billing, help, and System-wide RESTful Web Services for distributed architecture"
    git push -u origin feature/billing-help-and-distributed
    git checkout main
    git merge feature/billing-help-and-distributed
    git tag v0.9-rc
    git push origin main
    git push --tags
    ```

---

## 📅 Day 6 (Part 1): Email Integration & Validation
**Goal**: Professional communication and data integrity.

1.  **Branch**: `git checkout -b feature/email-and-validation`
2.  **Steps**:
    *   **SQL**: Add `email` column to `guests` table.
    *   **Validation**: Add 10-digit check to `ReservationServiceImpl`.
    *   **Feature**: Setup `EmailService` (JavaMail API / SMTP).
3.  **Commit & Push**:
    ```bash
    git add .
    git commit -m "Add guest email support, 10-digit validation, and JavaMail notifications"
    git push origin main
    ```

---

## 📅 Day 6 (Part 2): Staff Management & Reservation Status
**Goal**: Implement administrative controls and automated payment tracking.

1.  **Branch**: `git checkout -b feature/staff-and-payment-status`
2.  **Steps**:
    *   **Module Implementation**: Create `StaffDao`, `StaffService`, and `StaffController` for official member administration.
    *   **Status Logic**: Add `status` column to `reservations` and create a SQL Trigger `AFTER INSERT ON billings` to set it to 'PAID'.
    *   **UI Update**: Display PAID/PENDING status labels in the reservation directory.
    *   **Stability**: Fix `ERR_INCOMPLETE_CHUNKED_ENCODING` by refactoring `StaffController` to use `OutputStream`.
3.  **Commit & Push**:
    ```bash
    git add .
    git commit -m "Implement Staff Management and automated reservation status triggers"
    git push -u origin feature/staff-and-payment-status
    git checkout main
    git merge feature/staff-and-payment-status
    ```

---

## 📅 Day 6 (Part 3): Advanced Room Filtering, Security & Search Refinements
**Goal**: Enhance room search capability and secure the authentication system.

1.  **Branch**: `git checkout -b feature/advanced-search-and-security`
2.  **Steps**:
    - **Back-end**: Update `RoomDao` and `RoomController` to support `minPrice` and `maxPrice` range filtering.
    - **Logic**: Refine `RoomController` to ensure strict search matching (return 0 results instead of fallback if no match).
    - **Security**: Implement `jbcrypt` hashing for administrative passwords and add `Cache-Control` headers to prevent back-button access after logout.
    - **UI (Admin)**: Update `rooms.jsp` with price range inputs and reset logic.
    - **UI (Staff)**: Update `reservations.jsp` Room Picker Modal with price inputs and a "Reset" button.
3.  **Commit & Push**:
    ```bash
    git add .
    git commit -m "Implement advanced room price range filtering, BCrypt security, and logout cache prevention"
    git push -u origin feature/advanced-search-and-security
    git checkout main
    git merge feature/advanced-search-and-security
    ```

---

## 📅 Day 7: UI Overhaul & System Finalization (First Release)
**Goal**: Finalize production aesthetics and optimize the user experience across all modules.

1.  **Branch**: `git checkout -b feature/ui-overhaul-and-optimization`
2.  **Steps**:
    - **UI/UX**: Implement a **Common Design System** (unified color palette, professional typography, glassmorphism) across the entire application.
    - **Optimization**: Refine login icon visibility, branding consistency (Ocean View Blue), and interactive feedback (hover effects).
    - **Modals**: Apply premium styling to all selection components (Availability Picker) with color-coded status badges.
3.  **Commit & Push**:
    ```bash
    git add .
    git commit -m "Apply global UI design system and optimize user experience for v1.0 release"
    git push -u origin feature/ui-overhaul-and-optimization
    git checkout main
    git merge feature/ui-overhaul-and-optimization
    git tag v1.0-release
    git push origin main
    git push --tags
    ```

---

## ✅ Final Result
Your GitHub will now show a professional 7-day history with **automatic build verification active from Day 1 to Day 7**.
