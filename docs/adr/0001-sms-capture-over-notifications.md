# SMS capture over notification listening

SpendSense captures transactions by parsing bank SMS, not by listening to Android notifications. On first launch the app imports the last twelve months of SMS from whitelisted bank senders, then monitors new messages from those senders. OTP messages are ignored.

This trades notification-access UX for broader bank coverage, reliable capture when the app is not running, and alignment with how Indian banks already deliver transaction confirmations via SMS. The PRD v1.2 described notification parsing; SMS import was listed on the roadmap — we reversed that priority for v1.

**Considered options**

- **Notification listener** — real-time capture from bank app notifications; requires Notification Access permission; misses transactions when the listener is disabled or the bank app does not post a notification.
- **SMS parsing (chosen)** — reads bank sender SMS; supports historical backfill on first launch; uses READ_SMS permission; matches the PRD's existing parser test cases, which are SMS-shaped.
