# Metric Definitions

## Project question

At which step of the user journey do visitors drop off, and which user groups are more likely to return?

## Scope and data limitations

The RetailRocket dataset contains behavioral events, but it does not include registration events, acquisition channels, or device information. Therefore, this analysis does not measure registration conversion. A visitor's first observed event is used as the start of observation; it must not be described as the visitor's registration date or necessarily their first-ever visit.

Event timestamps are stored as Unix milliseconds and will be interpreted in UTC. The available event types are `view`, `addtocart`, and `transaction`.

## Entity definitions

- **Visitor:** a unique `visitorid`.
- **Event:** one row in `events.csv`, identified by its visitor, timestamp, event type, item, and (where present) transaction ID. The source has no dedicated event ID, so duplicate handling will be validated before any records are removed.
- **Session:** a sequence of events for one visitor. A new session starts when the gap from the previous event is greater than 30 minutes. This is an analytical assumption because the source does not provide session IDs.
- **First observed event:** the earliest event for a visitor in the dataset's observation period. Visitors may have been active before the dataset begins, so this does not establish when they became new users.

## Funnel

The funnel is measured using unique visitors and requires the ordered steps to occur within the same inferred session:

1. `view` — the visitor views an item.
2. `addtocart` — the visitor adds an item to the cart after a view.
3. `transaction` — the visitor completes a transaction after adding an item to the cart.

A visitor is counted at most once at each step. To count at a later step, the visitor must have completed the preceding steps in order within a single session. A visitor who adds an item to the cart or completes a transaction without an observed preceding step in that session is not counted as having completed the full ordered funnel.

- **Step conversion:** unique visitors reaching the next step divided by unique visitors reaching the current step.
- **Step drop-off:** 1 minus the step conversion rate.
- **Overall conversion:** unique visitors completing the transaction step divided by unique visitors reaching the view step.

Transaction IDs can appear on multiple event rows, potentially because an order contains multiple items. Repeated transaction IDs will not be treated as duplicate events without further validation. The funnel counts visitors, not orders or revenue.

## Cohorts and weekly retention

- **Cohort:** visitors grouped by the calendar week of their first observed event. Weeks start on Monday and use UTC.
- **Cohort week (week 0):** the calendar week in which the visitor's first observed event occurs.
- **Retention week 1, 2, etc.:** each subsequent calendar week after the cohort week.
- **Returned / retained visitor:** a cohort visitor with at least one `view`, `addtocart`, or `transaction` event during the retention week.
- **Weekly retention rate:** distinct retained visitors in a cohort and retention week divided by the number of visitors in that cohort.

A secondary, higher-intent retention measure will count a visitor as returned only if they have at least one `addtocart` or `transaction` event in the retention week.

Cohort cells without a complete observation period will be marked incomplete and excluded from comparisons that require that period. The final cohort week is incomplete because the dataset ends partway through that calendar week.

## User segments

Visitors will be grouped by the furthest funnel step completed in their first observed session:

- **View only:** viewed an item, with no subsequent cart or transaction event in that session.
- **Cart, no transaction:** added an item to the cart, but did not complete a transaction in that session.
- **Transaction:** completed a transaction in that session, whether or not all preceding funnel events were observed.

Visitors whose first observed session contains no `view` event will be kept outside these three funnel-based segments and reported separately if present. Retention will be compared across segments using the same weekly retention definition above.

These segments describe observed behavior. Differences in retention are associations and do not show that a behavior caused a visitor to return.

## Interpretation notes

- The 30-minute session boundary is a convention, not a source-provided fact. Its impact can be checked later with an alternative gap if needed.
- The first observed event is limited by the dataset's start date. Cohorts should be called **first-observed cohorts**, not registration cohorts.
- The data do not support comparisons by acquisition channel, device, or registered-user status.
- Results describe association, not causal impact.
