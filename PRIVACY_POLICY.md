# Privacy Policy for Expenzo

**Last updated: May 20, 2026**

## Introduction

This Privacy Policy describes how **Acesif Labs** ("we", "us", or "our") collects, uses, and protects your information when you use the **Expenzo** mobile application (the "App").

## Information We Collect

### Information You Provide

- **Account Information**: When you sign in using Google Sign-In, we collect your name and email address via Firebase Authentication.
- **Financial Records**: Expense and income records, categories, budgets, and recurring transactions you create within the App.
- **Message Templates & Parsing Rules**: Custom templates and rules you configure for SMS-based expense parsing.

### Information Collected Automatically

- **SMS Messages**: With your explicit permission, the App reads SMS messages on your device to automatically detect and parse transaction-related messages. SMS data is processed **locally on your device** and is not transmitted to our servers.
- **Device Storage**: Financial data is stored locally on your device using encrypted local storage (flutter_secure_storage) and a local SQLite database (Drift). This data does not leave your device unless you explicitly export it.

### Information We Do NOT Collect

- We do **not** collect location data.
- We do **not** collect analytics or tracking data.
- We do **not** use advertising SDKs.
- We do **not** collect contacts, photos, or media files.

## How We Use Your Information

We use the information solely to:

- Provide and operate the App's core features (expense tracking, budgeting, reporting)
- Authenticate your identity via Google Sign-In
- Parse SMS messages for transaction detection (processed locally)
- Sync your financial records with your account via our backend server

## Data Storage and Security

- **Local Storage**: Your financial data is stored locally on your device in an encrypted SQLite database.
- **Firebase Authentication**: Authentication tokens are managed securely through Firebase Auth.
- **Cloud Sync**: When connected to our backend, data is transmitted over HTTPS and stored on our secure servers.
- We implement industry-standard security measures to protect your data, but no method of electronic storage is 100% secure.

## Third-Party Services

The App uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---|---|---|
| Google Sign-In (Firebase Auth) | User authentication | [Google Privacy Policy](https://policies.google.com/privacy) |
| Firebase (Google) | Authentication infrastructure | [Firebase Privacy](https://firebase.google.com/policies/analytics) |
| Cloud Firestore (Google) | Cloud data sync (if enabled) | [Google Cloud Privacy](https://cloud.google.com/terms/cloud-privacy-notice) |

These services may collect information as described in their respective privacy policies. We do not share your personal data with any other third parties.

## SMS Permissions

The App requests permission to read SMS messages for the sole purpose of automatically detecting and parsing bank/transaction SMS messages to create expense records. This feature:

- Is **optional** and requires your explicit permission
- Processes SMS data **entirely on-device**
- Does **not** send SMS contents to any external server
- Can be disabled at any time by revoking SMS permission in your device settings

## Data Sharing

We do **not** sell, trade, or rent your personal information to third parties. We only share data as described in this policy (authentication via Firebase, cloud sync to our backend).

## Data Retention

- **Local Data**: Remains on your device until you delete it or uninstall the App.
- **Cloud Data**: Retained as long as your account is active. You can request deletion by contacting us.
- **Authentication Data**: Managed according to Google/Firebase's data retention policies.

## Your Rights

You have the right to:

- **Access** your personal data
- **Correct** inaccurate data
- **Delete** your data by contacting us or uninstalling the App
- **Revoke permissions** (SMS, etc.) at any time through your device settings
- **Export** your data through the App's export features (if available)

## Children's Privacy

The App is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.

## Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last updated" date at the top of this page.

## Contact Us

If you have any questions about this Privacy Policy, please contact us at:

**Acesif Labs**

- **App**: Expenzo
- **Package**: com.acesiflabs.expenzo
- **Email**: [your-email@example.com]

---

_This privacy policy is effective as of the date listed above and applies to all users of the Expenzo application._
