# SpendSense

A personal finance app built around credit card billing cycles, helping users track spending, bills, and budgets across credit cards and bank accounts. V1 ships on Android only.

## Language

**Account**:
A bank account used to track debit, credit, transfer, salary, interest, and cash deposit transactions. Accounts are separate from credit cards — they have no billing cycles, credit limits, or bills. Current balance is computed from an opening balance plus credits minus debits. Each account has a user-chosen color and icon, optional notes, and a default nickname of bank plus last-4 digits. Accounts can be archived or permanently deleted from Settings. Cash deposits are manual only.
_Avoid_: Wallet, card, ledger

**Salary**:
A bank account credit identified from SMS containing salary keywords (e.g. SALARY, NEFT CR) or matching a recurring credit pattern. Auto-assigned type and category Salary.
_Avoid_: Income, wages, pay

**Interest**:
A bank account credit identified from SMS containing interest keywords (e.g. INTEREST, INT CR). Auto-assigned type and category Investment. Unmatched credits remain generic Credit for user recategorization.
_Avoid_: Interest earned, bank interest

**Transaction Source**:
How a transaction entered the app — `SMS` (auto-captured, including historical import) or `Manual` (user-created). Source does not change when a transaction is edited.
_Avoid_: Origin, entry method, import type

**Copy**:
Creating a new manual transaction pre-filled from an existing one — merchant, category, tags, and card or account. User edits amount and date before saving.
_Avoid_: Duplicate, template, clone

**Cycle Move**:
Manually reassigning a credit card transaction to a different billing cycle. Bill amounts and budget assignment recalculate on both the source and target cycles.
_Avoid_: Reassign, transfer, relink

**Delete**:
Removing a transaction permanently. A brief undo window is shown before the deletion is final. Bill amounts and budgets recalculate immediately.
_Avoid_: Remove, trash, archive

**Quick Add**:
Manually creating a transaction via the floating action button. Pre-selects the card or account currently being viewed; otherwise defaults to the most recently used card or account.
_Avoid_: FAB, new transaction, manual entry

**Reference Number**:
A UPI or bank reference extracted from SMS and stored on the transaction. Visible in the detail view and searchable.
_Avoid_: UPI ref, transaction ID, ref no

**Credit Card**:
A credit card tracked independently from bank accounts. Owns billing cycles, bills, credit limits, and card-specific transaction types (expense, refund, cashback, adjustment, card payment). Each card has a user-chosen color and icon, an optional network (Visa, Mastercard, RuPay, Amex), an optional nickname defaulting to bank plus last-4 digits, and optional notes.
_Avoid_: Account, card account

**Billing Cycle**:
A persisted period for a specific credit card, spanning from the day after one bill generation date to the next bill generation date. Each cycle has its own totals, status, and due date.
_Avoid_: Statement period, billing month, billing window

**Cycle Assignment**:
The rule that places a credit card transaction into a billing cycle. Expenses are assigned by transaction date. Refunds attach to the same billing cycle as the original transaction they reverse, regardless of when they arrive.
_Avoid_: Auto-categorization, statement matching

**Refund**:
A credit card transaction that reverses a prior expense. Auto-captured from SMS when possible, auto-linked to the original expense by card, merchant, and amount. Always shares the billing cycle of the linked original.
_Avoid_: Reversal, chargeback (unless explicitly a bank chargeback)

**Card Payment**:
A payment made toward a credit card's outstanding balance. Attaches to the oldest unpaid billing cycle for that card, with exact amount match as tiebreaker. When paid from a bank account, the bank debit and card payment are linked as one payment event — auto-detected when matching SMS arrive on both accounts.
_Avoid_: Bill payment, credit card transfer

**Transfer**:
A movement of money between the user's own bank accounts. Always creates two linked transactions — a debit on the source account and a credit on the destination account. Auto-detected when matching debit and credit SMS arrive on owned accounts, or created manually.
_Avoid_: Payment, wire, UPI

**Budget**:
A spending limit not tied to any specific card. V1 supports a monthly spending budget and category budgets — both count credit card expenses only, excluding recoverable transactions. Bank account transactions are excluded. Category budgets reset on the same budget-month boundary as the monthly budget. Alerts fire independently for each budget, based on personal spend only. Shows a linear projection of end-of-month spend based on current pace.
_Avoid_: Allowance, spending cap, per-card limit

**Budget Assignment**:
Which monthly budget a transaction counts toward follows the transacting card's billing cycle. Only credit card expenses count toward the monthly budget — bank account transactions are excluded. Spend before a card's bill date counts toward the current budget month; spend on or after that card's bill date counts toward the next budget month. Once every credit card has generated its bill for the period, all subsequent card spend counts toward the next budget month, even if the calendar month has not changed.
_Avoid_: Calendar month, global period

**SMS Capture**:
An SMS from a bank or payment provider parsed into a transaction. On first launch, the user chooses how far back to scan (3, 6, 12, or 24 months; default 12) and historical SMS from the inbox are imported. New SMS are monitored continuously. SMS containing OTP keywords are ignored. Captured transactions are auto-saved immediately and the user is sent an in-app notification with the amount, merchant, and card or account. If no matching card or account exists, one is auto-created from the SMS details. All parsed fields are editable; the original SMS text is viewable on the transaction. If SMS permission is denied, the app runs in limited mode with manual entry only and a persistent banner linking to system settings. SMS that fail to parse are silently ignored unless they contain transaction keywords (e.g. debited, spent, credited), in which case the user is notified to add manually.
_Avoid_: Auto-import, notification parsing, push notification

**Auto-created Card**:
A credit card created automatically when an SMS references an unknown card. Created with bank, last-4 digits, and a default nickname (e.g. HDFC ••5534) — no bill date, credit limit, or billing cycle until the user configures it.
_Avoid_: Discovered card, parsed card

**Auto-created Account**:
A bank account created automatically when an SMS references an unknown account. Created with bank, last-4 digits, and a default nickname (e.g. SBI ••0428).
_Avoid_: Discovered account, parsed account

**Duplicate**:
An SMS that matches an already-captured transaction on the same card or account, with the same amount and merchant. Matched by reference number when available; otherwise by same amount and merchant within a five-minute window. Duplicates are silently discarded.
_Avoid_: Repeat transaction, double entry

**Credit Limit**:
The maximum credit on a card, set manually by the user. Available limit from bank SMS is not used — the user manages limits themselves.
_Avoid_: Available credit, spending limit

**Category**:
A label classifying what a transaction was for. Default categories ship with the app but can be renamed or deleted; deleting a category reassigns its transactions to Miscellaneous. Auto-captured transactions are assigned via a built-in merchant dictionary tuned for Indian merchants (e.g. Zomato → Food, Indian Oil → Fuel). Unknown merchants default to Miscellaneous.
_Avoid_: Tag, label, bucket

**Merchant**:
A payee identified from a transaction or SMS (e.g. ZOMATO LTD, paytm.s26pdgh@pty). The raw name from the SMS is stored as-is. Every new merchant is automatically added to the merchant list, where the user can set a display name, default category, and tags. The built-in Indian merchant dictionary provides an initial category guess; once the user sets category, tags, or display name on the merchant list, those user choices take permanent precedence.
_Avoid_: Vendor, payee, store

**Tag**:
An optional user-applied label on a transaction (e.g. Personal, Office). Multiple tags per transaction. No tag budgets in v1.
_Avoid_: Label, marker

**Recoverable**:
A flag on a credit card expense marking it as someone else's spend on the user's card. Recoverable expenses are included in Bill Amount but excluded from monthly and category budgets. An optional person field records who owes the money. Can be set from the capture notification or edited anytime on the transaction. For shared expenses, use split to create separate personal and recoverable lines. When the person repays via a credit on the card, the user links that credit to the recoverable expense to mark it settled.
_Avoid_: Reimbursable, friend expense, split bill

**Split**:
Dividing one transaction into multiple expense lines on the same billing cycle, each with its own category, amount, and optional recoverable flag. The original transaction is removed and replaced by the split lines. Bill Amount uses the sum of all lines; budgets count only non-recoverable lines.
_Avoid_: Divide, break down

**Recovery**:
Linking a credit on the credit card (payment received) to one or more recoverable expenses, with partial amounts per link. Reduces the outstanding recoverable amount for each linked expense. Recovery linking is tracking only — the full card payment always reduces the billing cycle's outstanding balance regardless of how much is linked to recoverables.
_Avoid_: Settlement, repayment, paid back

**Recoverable Summary**:
A breakdown of outstanding amounts owed per person. Shown on the dashboard widget, on each billing cycle detail, and on a dedicated recoverable management screen.
_Avoid_: Owed to me, friend ledger, split tracker

**Person**:
Who owes money for a recoverable expense. Chosen from previously used names with type-ahead suggestions. New names are saved automatically for future use.
_Avoid_: Friend, contact, debtor

**Spending Alert**:
A local notification when monthly budget spend crosses a configurable threshold (default 75%, 90%, 100%). Credit limit alerts are not in v1. Requires notification permission; if denied, alerts are disabled and a banner links to system settings. Capture confirmations fall back to in-app snackbars when the app is open.
_Avoid_: Budget warning, overspend notification

**Overpayment**:
A card payment that exceeds a billing cycle's outstanding bill amount. The surplus is applied as credit toward the card's balance.
_Avoid_: Excess payment, advance payment

### Billing Cycle Status

**Open**:
The current billing cycle before its bill has been generated. A new cycle opens automatically when the previous cycle is billed on the card's bill date.
_Avoid_: Active, current

**Billed**:
A billing cycle whose bill has been generated but no payment has been received. Cycles become billed automatically on the card's bill date.
_Avoid_: Unpaid, due

**Due Date**:
The date by which a billed cycle's bill must be paid. Calculated per card as a fixed number of days after the bill date, set once during card setup. Each card may have a different offset.
_Avoid_: Payment date, deadline

**Archived Card**:
A credit card the user no longer uses. Hidden from active views, dashboard widgets, and budget counting. Transaction history remains accessible via an archived section or filter. Cards can also be permanently deleted with all associated transactions from a danger zone in Settings.
_Avoid_: Closed card, inactive card

**Backup**:
An encrypted export of all app data (`.ssb` file). Every backup requires a password — there is no unencrypted export option. Automatic local backups run weekly, keeping the last four. A single user-chosen password is stored in Android Keystore for silent auto-backups and manual exports. No cloud sync — restore is via file only. Restore is available during onboarding and in Settings. Wrong password shows a clear error with the backup filename; unlimited retries. Manual export failures show a detailed error dialog. Auto-backup failures show a warning in Settings. Corrupted or invalid backup files show a specific error with an option to try another file.
_Avoid_: Export, sync

**Data Recovery**:
A screen shown when the database is corrupted on launch. Offers restore from backup (latest local backup pre-selected), export salvageable data, or reset the app.
_Avoid_: Disaster recovery, emergency restore, crash recovery

**Merge**:
Combining two duplicate transactions into one. The surviving transaction retains the combined history.
_Avoid_: Deduplicate, combine

**Recurring**:
A flag on a transaction indicating it repeats on a regular schedule. Label and filter only in v1 — no predictions, reminders, or auto-creation.
_Avoid_: Subscription, repeat, scheduled

**Receipt**:
A photo attached to a transaction for the user's records. Multiple photos per transaction. Stored locally and included in encrypted backup. No OCR in v1.
_Avoid_: Invoice, proof, screenshot

**Location**:
Where a transaction occurred. Captured automatically from device GPS when an SMS is parsed, if location permission is granted. On first denial, the app explains why and then silently skips location capture thereafter.
_Avoid_: Place, address, geo

**App Lock**:
An optional PIN or biometric lock that must be passed to open the app. Configured in Settings, disabled by default. Forgotten PIN can be reset using the device's system credential (PIN, pattern, or password).
_Avoid_: Passcode, authentication, privacy lock

**Onboarding**:
First launch offers start fresh or restore from backup. Fresh start requests SMS permission, then imports the last twelve months of bank SMS on a blocking progress screen. If import is interrupted, partial data is kept and the user can resume or start over on relaunch. Restore loads backup data, imports SMS received since the backup date, then shows a verification summary of restored cards and settings. After import completes, a setup wizard walks the user through configuration. Credit card setup (bill date, due date offset, credit limit) is required before reaching the dashboard on fresh start. Bank account setup (opening balance), monthly budget, and suggested category budgets (Food, Fuel, Shopping) are optional steps that can be skipped. Historical transactions are retroactively assigned to billing cycles once each card is configured.
_Avoid_: Setup wizard, first-run

**Adjustment**:
A manually added credit card transaction for bank-imposed charges or credits that don't arrive via SMS — late fees, annual fees, interest, foreign markup, or dispute credits. User picks charge or credit and enters a positive amount. Charges add to Bill Amount; credits subtract.
_Avoid_: Fee, correction, manual entry

**Cashback**:
A manually added credit card transaction representing rewards or cashback credited to the card. Attaches to the current billing cycle when added. Reduces Bill Amount. Does not arrive via SMS.
_Avoid_: Reward, rebate

**Reviewed**:
Whether the user has acknowledged a captured transaction. Transactions start unreviewed. Tapping the in-app capture notification marks them reviewed.
_Avoid_: Verified, confirmed

**Home Screen Widget**:
An Android widget displaying SpendSense data on the device home screen. All six types ship in v1 — quick summary, credit utilization, recent transactions, bills, budget, and quick add — with rich visuals including colors, progress bars, and mini charts. Credit utilization shows spend with a prompt to set the limit when none is configured.
_Avoid_: App widget, launcher widget

**Report**:
An exported summary of app data in PDF, CSV, or Excel format. Covers transactions, billing cycles, categories, accounts, budgets, analytics, and recoverable breakdown by person with full person names.
_Avoid_: Export, download

**Currency**:
Indian Rupees (₹ / INR) only. All amounts are stored and displayed in INR.
_Avoid_: Money, rupees

**Dashboard**:
The main app screen showing spending summaries, card status, budgets, bills, recent transactions, and analytics. Shows aggregate spend across all cards with a per-card breakdown. Fixed curated layout in v1 — no widget customization.
_Avoid_: Home screen, overview

**Analytics**:
Charts and breakdowns of spending by category, merchant, card, and tag. Defaults to the current budget month, compared against the previous budget month. Recoverable transactions are excluded from category and merchant analytics. Billing cycle comparison available per card. Supports pie, donut, line, bar, stacked, and area charts.
_Avoid_: Reports, charts, insights

**Transaction**:
A single financial event on a credit card or bank account. Stores amount, merchant, date, time, category, tags, and optional fields (notes, receipt, reference number, recoverable flag, beneficiary). Date and time are both stored and displayed. The Transactions screen has a Cards | Accounts toggle. Credit card transactions are grouped by billing cycle. Bank account transactions are shown separately, grouped by month (This Month, Last Month, then month-year for older).
_Avoid_: Entry, record, payment

**Search**:
Transaction search defaults to the current segment (Cards or Accounts) with a quick "Search all" option to broaden across both.
_Avoid_: Find, lookup, filter

**Transaction List**:
Credit card and bank account transaction lists use infinite scroll with sticky group headers (billing cycle or month). Swipe left to delete, swipe right to edit. Long-press opens a menu for recoverable, split, and copy actions.
_Avoid_: Transaction feed, history list, activity log

**Beneficiary**:
The recipient of a bank account debit or transfer, extracted from SMS when available. Stored separately from merchant.
_Avoid_: Payee, recipient, sent to

**Notes**:
Optional free text on a transaction for user context. Searchable.
_Avoid_: Memo, description, comment

**Partially Paid**:
A billed cycle that has received some payment but still has a remaining balance.
_Avoid_: Part-paid, incomplete

**Paid**:
A billed cycle whose outstanding balance is zero (remaining ≤ ₹1).
_Avoid_: Settled, cleared

**Overdue**:
A billed cycle past its due date with an unpaid or partially paid balance.
_Avoid_: Late, delinquent

**Bill**:
The amount owed on a credit card billing cycle, together with its due date. A bill exists only in the context of a billing cycle — it is not a separate entity for utilities, subscriptions, or rent.
_Avoid_: Scheduled bill, utility bill, invoice

**Bill Amount**:
The net spend on a billing cycle: expenses plus adjustment charges minus refunds, cashbacks, and adjustment credits. Card payments are excluded — they attach to the cycle they pay off, not the cycle they occur in.
_Avoid_: Statement total, gross spend, outstanding balance

**EMI**:
A category label for installment purchases. EMI charges are recorded as regular expenses — not a separate transaction type.
_Avoid_: Installment, e-mandate

**Subscription**:
A recurring charge that appears as a credit card expense transaction. Subscriptions are not tracked as separate obligations — they flow through the card's billing cycle like any other purchase.
_Avoid_: Scheduled payment, recurring bill

**Bills View**:
The dedicated nav screen showing all credit card bills across cards — due dates, remaining amounts, and overdue status. Each bill shows total outstanding and net outstanding after recoverables. Sorted by overdue first, then nearest due date.
_Avoid_: Bill management, scheduled payments

**Bill Reminder**:
A local notification sent 3 days before, 1 day before, and on the due date for unpaid or partially paid bills. Requires notification permission; if denied, reminders are disabled and a banner links to system settings.
_Avoid_: Due date alert, payment reminder, bill notification

**Net Outstanding**:
The personal amount still owed on a bill after subtracting payments and unsettled recoverable expenses. Settled recoverables do not reduce net outstanding.
_Avoid_: Personal due, your share, net bill

**Cash**:
Physical cash spending tracked as bank account transactions (e.g. ATM withdrawal as a debit). No separate cash wallet in v1.
_Avoid_: Cash wallet, petty cash

**Accounts View**:
The nav screen with two sections — Credit Cards and Bank Accounts. Credit cards open cycle and limit management; bank accounts open their transaction list.
_Avoid_: Wallets, financial accounts

**Settings**:
App configuration organized into grouped screens (Security, Data, Capture, Budgets, Appearance, About) with search on the main Settings page. Delete all data is available in a danger zone, prompting the user to create a backup before wiping.
_Avoid_: Preferences, options, configuration
