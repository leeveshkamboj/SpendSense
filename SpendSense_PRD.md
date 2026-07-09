# SpendSense — Product Requirements Document (PRD)

**Version:** 1.2
**Platform:** Flutter (Android-first, iOS-ready)
**Design:** Material Design 3 (Material You)
**Architecture:** Offline-first

---

# Vision

SpendSense is a modern personal finance application built around **credit card billing cycles**, helping users understand and manage spending across multiple credit cards, bank accounts, and cash wallets.

Unlike traditional budgeting apps that organize expenses by calendar month, SpendSense automatically assigns transactions to the correct billing cycle, making it much easier to track card usage, upcoming bills, payments, and monthly liabilities.

The application should feel **beautiful, modern, extremely easy to use, and incredibly fast**, while providing advanced financial insights for power users.

The goal is to become the best offline-first expense tracker for Android.

---

# Design Philosophy

The UI should feel premium and polished while remaining simple enough for anyone to use.

The app should prioritize:

* Modern Material Design 3
* Material You support
* Light & Dark themes
* Smooth animations
* Fast navigation
* Minimal taps
* Clean layouts
* Beautiful graphs
* Rich dashboards
* Easy discoverability
* Powerful customization
* Accessibility
* Responsive layouts

Every important piece of information should be available within one or two taps.

---

# Core Principles

* Offline-first
* Privacy-first
* Billing-cycle focused
* Fast
* Beautiful
* Highly customizable
* Intelligent notification parsing
* Powerful analytics
* Unlimited data storage

---

# Accounts

SpendSense supports unlimited accounts.

## Account Types

### Credit Cards

Each credit card stores:

* Card nickname
* Bank
* Last 4 digits
* Card network
* Credit limit
* Available limit (optional)
* Bill generation date
* Due date
* Interest-free period
* Card color
* Card icon
* Notes
* Active/Archived

---

### Bank Accounts

Each account stores:

* Account nickname
* Bank
* Last 4 digits
* Account type
* Opening balance
* Current balance (optional)
* Color
* Icon
* Notes

---

### Cash Wallets

* Wallet name
* Opening balance
* Current balance
* Color
* Icon

---

# Billing Cycles

Billing cycles are the heart of SpendSense.

Example

Bill Generated

5 July

Current Cycle

6 July → 5 August

Every credit card has independent billing cycles.

Transactions are automatically assigned to the correct cycle.

Users may manually move transactions if required.

Each billing cycle displays:

* Total Spend
* Payments Received
* Refunds
* Cashback
* EMIs
* Adjustments
* Credit Utilization
* Remaining Credit
* Bill Amount
* Due Date
* Remaining Days
* Budget Progress

---

# Transactions

Every transaction contains:

* Amount
* Merchant
* Date
* Time
* Account
* Category
* Multiple Tags
* Notes
* Receipt
* Transaction Type
* Billing Cycle
* Location (optional)
* Notification Source
* Reference Number (optional)

---

## Transaction Types

Credit Cards

* Expense
* Refund
* Cashback
* EMI
* Adjustment
* Card Payment Received

Bank Accounts

* Debit
* Credit
* Transfer
* Salary
* Interest
* Cash Deposit

Cash

* Expense
* Income

---

## Transaction Features

Users can

* Add
* Edit
* Delete
* Duplicate
* Merge
* Split
* Copy
* Move between billing cycles
* Attach receipt
* Add notes
* Add tags
* Mark as reviewed
* Mark recurring

---

# Categories

Editable categories include

* Food
* Groceries
* Shopping
* Fuel
* Travel
* Bills
* Utilities
* Entertainment
* Medical
* Education
* Investment
* Salary
* Rent
* EMI
* Insurance
* Tax
* Subscription
* Gifts
* Personal Care
* Miscellaneous

Unlimited custom categories are supported.

---

# Tags

Support unlimited tags.

Examples

* Office
* Personal
* Family
* Vacation
* Business
* Trip
* Friends
* Reimbursable
* Emergency

Multiple tags per transaction.

---

# Budgets

SpendSense supports multiple budgeting methods.

## Daily Budget

Example

₹500/day

Shows

* Today's spending
* Remaining budget
* Daily average

---

## Billing Cycle Budget

Example

₹20,000 per billing cycle

Shows

* Budget used
* Remaining budget
* Predicted end-of-cycle spend
* Percentage completed

---

## Category Budgets

Example

Food

₹5000

Shopping

₹3000

Fuel

₹2500

---

## Account Budgets

Separate budgets for

* Credit Card
* Bank Account
* Cash Wallet

---

## Tag Budgets

Example

Vacation

₹15,000

Office

₹8,000

---

# Notification Capture

SpendSense automatically captures supported Android payment notifications.

Supported providers include:

* HDFC Bank
* SBI Card
* ICICI Bank
* Axis Bank
* Kotak
* IndusInd
* IDFC
* Yes Bank
* UPI apps
* Future supported banks

The parser extracts:

* Amount
* Merchant
* Card
* Account
* Reference Number
* Date
* Time
* UPI Reference
* Available Limit (if present)
* Payment Received
* Credit Amount

If confidence is low

Show a review screen before saving.

Duplicate detection prevents duplicate transactions.

---

# Transaction Notifications

Whenever SpendSense successfully captures a transaction, the app should immediately send a local notification.

Example

✅ Transaction Captured

₹411.67

Zomato

HDFC Card ••••5534

Added to July Billing Cycle

Tap to review

The notification opens the transaction editor.

---

# Spending Alerts

Users can configure unlimited spending alerts.

Examples

Notify when

* 25%
* 50%
* 60%
* 75%
* 80%
* 90%
* 95%
* 100%

of

* Credit Limit
* Budget
* Billing Cycle Budget

Example notification

⚠ Credit Usage Alert

You've used 75% of your HDFC Card limit.

Remaining Credit

₹12,530

---

# Bill Management

SpendSense should include a dedicated Bills section.

Track

* Credit Card Bills
* Utility Bills
* EMI Payments
* Subscriptions
* Internet
* Mobile
* Electricity
* Water
* Gas
* Insurance
* Rent
* Loan Payments

For each bill

* Bill Name
* Amount
* Due Date
* Paid Status
* Reminder
* Auto Repeat
* Notes

Upcoming bills should appear on Dashboard.

---

# Dashboard

The dashboard should be information-rich while remaining clean.

Users can customize:

* Widget order
* Widget visibility
* Widget size (future)
* Dashboard layout

Widgets include

## Spending

* Today's Spending
* Yesterday
* Weekly
* Monthly
* Billing Cycle Spend
* Remaining Budget
* Remaining Credit
* Credit Utilization

---

## Cards

* Current Card Spend
* Card Limit Used
* Remaining Credit
* Due Bills

---

## Budgets

* Daily Budget
* Cycle Budget
* Category Budgets

---

## Bills

* Upcoming Bills
* Overdue Bills
* Paid Bills

---

## Transactions

* Recent Transactions
* Largest Expenses
* Latest Captured Notifications

---

## Analytics

* Spending Trend
* Category Breakdown
* Merchant Breakdown
* Tag Breakdown
* Income vs Expense
* Monthly Comparison
* Billing Cycle Comparison
* Cash Flow

---

## Other

* Cashback Earned
* Refunds
* EMI Summary
* Savings Summary

---

# Analytics

Beautiful interactive charts

* Pie Charts
* Donut Charts
* Line Charts
* Bar Charts
* Stacked Charts
* Area Charts

Users can compare

* Billing Cycles
* Months
* Categories
* Merchants
* Cards
* Accounts
* Tags

---

# Search & Filters

Search should be extremely powerful.

Users can search by

* Merchant
* Amount
* Card
* Account
* Category
* Tag
* Notes
* Date
* Billing Cycle
* Transaction Type
* Reference Number

Advanced filters

* Multiple accounts
* Multiple categories
* Amount range
* Date range
* Billing cycle range
* Payment method
* Merchant contains
* Tags
* Transaction source
* Reviewed/Unreviewed
* Receipt attached
* Has notes

Sorting

* Latest
* Oldest
* Highest Amount
* Lowest Amount
* Merchant
* Category

Multiple filters can be combined.

---

# Home Screen Widgets (Android)

SpendSense should provide Android home screen widgets.

## Quick Summary Widget

Shows

* Current Billing Cycle
* Amount Spent
* Budget Remaining
* Credit Used

Example

HDFC Card

₹18,420 / ₹30,000

61%

---

## Credit Utilization Widget

Shows

Current usage

Limit remaining

Progress bar

---

## Recent Transactions Widget

Displays last 3–10 transactions

Shows

Merchant

Amount

Time

---

## Bills Widget

Upcoming bills

Due dates

Amount

---

## Budget Widget

Today's budget

Cycle budget

Remaining amount

---

## Quick Add Widget

Buttons

* Expense

* Income

Scan Receipt (future)

---

# Reports

Export

* PDF
* CSV
* Excel

Include

* Transactions
* Billing Cycles
* Categories
* Accounts
* Budgets
* Bills
* Analytics

---

# Backup & Restore

Completely offline.

Export

SpendSense_Backup_YYYY-MM-DD.ssb

Includes

* Accounts
* Cards
* Transactions
* Bills
* Budgets
* Dashboard Layout
* Widgets
* Categories
* Tags
* Settings
* Receipts (optional)

Optional AES-256 encryption.

Automatic local backups should also be maintained.

---

# Navigation

Bottom Navigation

1. Dashboard

2. Transactions

3. Accounts

4. Analytics

5. Bills

6. Settings

Floating Action Button

Quick Add Transaction

---

# Technical Stack

Frontend

* Flutter
* Material Design 3
* Riverpod
* GoRouter

Database

* Drift (SQLite)

Charts

* fl_chart

Storage

* SQLite
* ZIP
* AES-256 Encryption

Architecture

* Offline-first
* Clean Architecture
* Repository Pattern
* Feature-first structure

---

# Notification Parsing Test Cases

The parser should successfully recognize and extract data from real-world bank notifications.

## HDFC Credit Card Purchase

```
Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.
```

Expected

* Type: Credit Card Expense
* Amount: ₹411.67
* Merchant: ZOMATO LTD
* Card: ****5534
* Date & Time
* Billing Cycle Assigned

---

## HDFC Credit Card UPI Purchase

```
Txn Rs.88.00
On HDFC Bank Card 9245
At paytm.s26pdgh@pty
by UPI
```

Expected

* Credit Card Expense
* Merchant
* UPI
* Card
* Amount

---

## BharatPe UPI

```
Txn Rs.70.00
On HDFC Bank Card 9245
At BHARATPE...
```

Expected

* Expense
* Merchant
* Amount
* Card
* UPI Reference

---

## SBI Card e-Mandate

```
Trxn. of Rs.499.00 at JIOHOTSTAR...
```

Expected

* Subscription
* Expense
* Merchant
* Amount
* Card

---

## SBI Card UPI

```
Rs.199.15 spent on your SBI Credit Card ending with 8401 at ZOMATO...
```

Expected

* Expense
* Merchant
* Card
* Amount
* Reference Number

---

## SBI Bank Debit

```
Dear UPI user A/C X0428 debited by 25000.00
```

Expected

* Bank Account Debit
* Amount
* Account ****0428
* Transfer
* Beneficiary
* Reference Number

---

## SBI Bank Credit

```
Dear SBI User, your A/c X0428 credited by Rs.6500
```

Expected

* Bank Account Credit
* Amount
* Account
* Sender
* Reference Number

---

## Credit Card Bill Payment

```
PAYMENT OF Rs.29559.00 RECEIVED TOWARDS YOUR CREDIT CARD ENDING WITH 5534
```

Expected

* Credit Card Payment Received
* Amount Paid
* Card ****5534
* Update Current Bill
* Reduce Outstanding Amount
* Update Available Credit
* Mark Bill as Paid (fully or partially based on outstanding)

---

# Future Roadmap

* OCR Receipt Scanning
* AI Categorization
* AI Spending Insights
* Statement Import (CSV/PDF)
* SMS Import
* Home Screen Widgets for iOS (when supported)
* Wear OS
* Optional Cloud Sync
* Shared Family Accounts
* Investment Tracking
* Loan Tracking
* Subscription Detection

---

# Success Metrics

* Accurate billing-cycle calculations.
* Reliable notification parsing across supported banks.
* Excellent offline performance.
* Powerful search and filtering.
* Modern, premium UI/UX.
* Comprehensive dashboards and analytics.
* Highly customizable home screen widgets.
* Easy bill and budget management.
* Secure encrypted backup and restore.
* Minimal user effort for day-to-day expense tracking.
