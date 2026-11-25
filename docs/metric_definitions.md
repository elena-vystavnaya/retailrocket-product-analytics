# Metric Definitions

## Project Question

At which stage of the user journey does the largest visitor drop-off occur, and which user segments are more likely to return?

## Scope and Data Limitations

The RetailRocket dataset contains observed e-commerce events from 2015: `view`, `addtocart`, and `transaction`. It does not include registration events, acquisition channels, or device information. The first observed event is not necessarily a visitor's first-ever visit or registration date.

Timestamps are converted from Unix milliseconds and interpreted in UTC. Exact duplicate source rows are removed before sessionization. Repeated transaction IDs alone are not treated as duplicates.

## Entity Definitions

- **Visitor:** a distinct `visitorid`.
- **Event:** a recorded interaction identified by visitor, timestamp, event type, item, and transaction ID (where present). The source does not provide a dedicated event ID.
- **Session:** a sequence of events for one visitor. A new session starts at the first observed event or when the gap from the previous event exceeds 30 minutes.
- **First observed event:** the earliest recorded event for a visitor within the dataset's observation window.

## Visitor Conversion Funnel

The funnel measures unique visitors reaching ordered stages within the same inferred session:

1. **View:** at least one product view.
2. **Add to Cart:** an `addtocart` event strictly after a view in the same session.
3. **Transaction:** a `transaction` event strictly after a qualifying cart event in the same session.

Each visitor is counted at most once per stage across the observation window. A visitor reaches a stage if the required sequence occurs in at least one session. The funnel does not require the same item ID across stages. Events with equal timestamps do not establish a strictly ordered transition. The funnel measures visitors, not sessions, orders, or revenue.

| Metric | Definition |
|---|---|
| View-to-Cart Conversion Rate | Visitors reaching cart / Visitors reaching view |
| Cart-to-Purchase Conversion Rate | Visitors reaching transaction / Visitors reaching cart |
| View-to-Purchase Conversion Rate | Visitors reaching transaction / Visitors reaching view |
| Step Drop-off Rate | 1 - corresponding step conversion rate |

Multiply ratios by 100 to express them as percentages.

## User Segmentation

Visitors are classified into four mutually exclusive segments based on event presence in their first observed session. The conditions are evaluated in the following order:

| Priority | Dashboard Segment | Source Value | Definition |
|---:|---|---|---|
| 1 | No view in first session | `no_view_first_session` | No view event, regardless of cart or transaction events |
| 2 | Purchased in first session | `transaction` | At least one view and one transaction |
| 3 | Added to cart, no purchase | `cart_no_transaction` | At least one view and one cart event, but no transaction |
| 4 | Viewed only | `view_only` | At least one view, with no cart or transaction events |

Unlike the conversion funnel, segmentation does not require events to occur in a particular order. A segment describes observed first-session behavior, not a causal effect on retention.

## Weekly Cohort Retention

- **Cohort:** visitors grouped by the calendar week of their first observed event. Weeks start on Monday in UTC.
- **Week 0:** the cohort formation week.
- **Retention week N:** the Nth calendar week after cohort formation, rather than an individual rolling seven-day window.
- **Cohort size:** the number of distinct visitors in a cohort and first-session segment.
- **Retained visitors:** distinct cohort visitors with at least one recorded event in the corresponding retention week.

**Retention Rate = Retained Visitors / Cohort Size**

Periods without recorded returning visitors have zero retained visitors. The SQL marks a period as complete when its Sunday is on or before the last observed event date. Both retention visualizations exclude week 0 and periods marked incomplete.

### Weighted Retention

When combining eligible cohorts or segments at a given relative week, the dashboard calculates:

**Weighted Retention = SUM(Retained Visitors) / SUM(Cohort Size)**

This weights individual retention rates by cohort-segment size instead of averaging percentages. The denominator includes the eligible cohorts represented in the selected relative week. The Tableau result is displayed as a percentage.

The cohort heatmap can be filtered by first-session segment. Its color scale adjusts to the selected data. The retention trend chart compares all segments and is not affected by the heatmap segment filter.

## Interpretation Notes

- The 30-minute inactivity threshold is an analytical convention, not a source-provided session definition.
- Funnel conversion and drop-off describe observed same-session event sequences aggregated at visitor level, not all possible cross-session purchase journeys.
- The dataset may omit activity before the observation window. The first calendar week may be partially observed, and a final observed Sunday does not establish full-day coverage.
- Later retention weeks may include fewer eligible cohorts. Changes in cohort composition and sample size can affect comparisons over time.
- Retention measures activity in each individual calendar week, not cumulative or continuous retention.
- Differences between segments are observational and do not establish causality.
