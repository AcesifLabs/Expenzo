# Privacy Policy for Expenzo

**Last updated: October 24, 2026**

## Introduction

This Privacy Policy describes how **Acesif Labs** ("we", "us", or "our") collects, uses, and protects your information when you use the **Expenzo** mobile application (the "App").

## Information We Collect

### Information You Provide

- **Account Information**: When you sign in using Google Sign-In, we collect your name and email address via Firebase Authentication.
- **Financial Records**: Expense and income records, categories, budgets, and recurring transactions you create within the App.
- **Message Templates & Parsing Rules**: Custom templates and rules you configure for SMS-based expense parsing.
- **Receipt Photos**: If you use Receipt Scan, the photo of the receipt you take or choose is sent to our AI provider (Groq) to read the amount and details.
- **AI Assistant Questions**: If you use the AI assistant, your question and a summary of the current month's data are sent to our AI provider (Groq) to produce an answer (see "AI Features" below).

### Information Collected Automatically

- **SMS Messages**: With your explicit permission, the App reads SMS messages on your device to automatically detect and parse transaction-related messages. SMS data is processed **locally on your device** and is not transmitted to our servers.
- **Device Storage**: Financial data is stored locally on your device using encrypted local storage (flutter_secure_storage) and a local SQLite database (Drift). It stays on your device unless you sign in with Google and Sync is on (Sync is on by default after you sign in). Then your transactions, categories, budgets, recurring transactions and pending recurring items, SMS senders, matching rules and expense templates are stored on our server so you can restore them on your other devices. App settings and preferences stay on each device.

### Information We Do NOT Collect

- We do **not** collect location data.
- We do **not** collect analytics or tracking data.
- We do **not** use advertising SDKs.
- We do **not** collect contacts or media files. Photos are only sent when you use Receipt Scan (see above).

## How We Use Your Information

We use the information solely to:

- Provide and operate the App's core features (expense tracking, budgeting, reporting)
- Authenticate your identity via Google Sign-In
- Parse SMS messages for transaction detection (processed locally)
- Sync your financial records with your account via our backend server (only when you are signed in and Sync is on)
- Answer AI assistant questions and read scanned receipts (only when you use those features)

## Data Storage and Security

- **Local Storage**: Your financial data is stored locally on your device in an encrypted SQLite database.
- **Firebase Authentication**: Authentication tokens are managed securely through Firebase Auth.
- **Cloud Sync**: When you are signed in and Sync is on, data is transmitted over HTTPS and stored on our servers. You can turn Sync off in Settings → Sync.
- We implement industry-standard security measures to protect your data, but no method of electronic storage is 100% secure.

## Third-Party Services

The App uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---|---|---|
| Google Sign-In (Firebase Auth) | User authentication | [Google Privacy Policy](https://policies.google.com/privacy) |
| Firebase (Google) | Authentication infrastructure | [Firebase Privacy](https://firebase.google.com/policies/analytics) |
| Expenzo server (Acesif Labs) | Sync, if you sign in and Sync is on | This policy |
| Groq | AI assistant answers and Receipt Scan | [Groq Privacy Policy](https://groq.com/privacy-policy) |

These services may collect information as described in their respective privacy policies. We do not share your personal data with any other third parties.

## AI Features

The AI assistant and Receipt Scan are optional and only run when you use them.

- **AI assistant**: sends your question and a summary of the current month only: total income, total expense and net, your top 5 spending categories, and your 5 most recent transactions (amount, description and date), with the currency. Email addresses, phone numbers and long digit strings are removed before anything is sent. Your full transaction history is never sent.
- **Receipt Scan**: sends the receipt photo you take or choose so the amount and details can be read.

## SMS Permissions

The App requests permission to read SMS messages for the sole purpose of automatically detecting and parsing bank/transaction SMS messages to create expense records. This feature:

- Is **optional** and requires your explicit permission
- Processes SMS data **entirely on-device**
- Does **not** send SMS contents to any external server
- Creates transactions that, like any other transaction, sync to your account if you are signed in and Sync is on
- Can be disabled at any time by revoking SMS permission in your device settings

## Data Sharing

We do **not** sell, trade, or rent your personal information to third parties. We only share data as described in this policy (authentication via Firebase, cloud sync to our backend, and the AI features via Groq).

## Data Retention

- **Local Data**: Remains on your device until you delete it or uninstall the App.
- **Cloud Data**: Retained as long as your account is active. Settings → Delete all data removes your synced data, and Delete account (in Settings → My profile) removes your account and all its data. You can also request deletion by contacting us.
- **Authentication Data**: Managed according to Google/Firebase's data retention policies.

## Your Rights

You have the right to:

- **Access** your personal data
- **Correct** inaccurate data
- **Delete** your data in the App (Delete all data, Delete account), by contacting us, or by uninstalling the App (local data only)
- **Revoke permissions** (SMS, etc.) at any time through your device settings
- **Export** your data as CSV files (Settings → Export data)

## Children's Privacy

The App is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.

## Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last updated" date at the top of this page.

## Contact Us

If you have any questions about this Privacy Policy, please contact us at:

**Acesif Labs**

- **App**: Expenzo
- **Package**: com.acesiflabs.expenzo
- **Email**: asifzubayerpalak@gmail.com

---

_This privacy policy is effective as of the date listed above and applies to all users of the Expenzo application._
