# RetailRocket Product Analytics

## Project Overview

An e-commerce product analytics project focused on user behavior, funnel metrics, weekly cohort retention, and user segmentation.

The project uses Python for data acquisition and validation, PostgreSQL for data processing and analysis, and Tableau for interactive data visualization.

The main objective is to identify patterns in user behavior, evaluate purchasing activity, and understand how first-session behavior is associated with subsequent user retention.

## Business Questions

### Main business question:

At which stage of the user journey does the largest visitor drop-off occur, and which user segments are more likely to return?

### Supporting questions:

- What are the key visitor metrics and conversion rates?
- At which funnel stage is the highest drop-off observed?
- How does weekly user retention change over time?
- How does first-session behavior relate to subsequent user retention?

## Dataset

The project is based on the [RetailRocket Recommender System Dataset](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset), which contains historical e-commerce user interactions from 2015.

The analysis focuses on three types of events:

- `view` — product views.
- `addtocart` — products added to the shopping cart.
- `transaction` — completed purchase events.

Raw data is excluded from the repository.

## Documentation

Detailed metric definitions, sessionization rules, funnel logic,
retention calculations, and methodological assumptions are available
in [Metric Definitions](docs/metric_definitions.md).

## Tools & Technologies

- Python — data acquisition and validation.
- SQL (PostgreSQL) — data transformation, funnel analysis, cohort analysis, and user segmentation.
- Tableau Public — interactive dashboard and data visualization.

## Methodology

### 1. Funnel Analysis

A visitor-level sequential funnel was constructed to analyze progression through three stages: product view, add to cart, and transaction.

Funnel stages must occur in chronological order within the same session. Sessions are defined using a 30-minute inactivity threshold.

Each visitor is counted once per funnel stage across the observation period.

The following conversion rates were calculated:

- View-to-Cart Conversion Rate
- Cart-to-Purchase Conversion Rate
- View-to-Purchase Conversion Rate

### 2. User Segmentation

Users were divided into four segments based on their first-session behavior:

- Viewed only
- Added to cart, no purchase
- Purchased in first session
- No view in first session

### 3. Weekly Cohort Analysis

Users were grouped into weekly cohorts to analyze retention over time and compare behavioral patterns across segments.

Weighted retention was calculated as:

**Retention Rate = SUM(Retained Visitors) / SUM(Cohort Size)**

This approach accounts for differences in cohort and segment sizes instead of averaging individual retention percentages.

### 4. Data Visualization

An interactive Tableau dashboard was developed to present:

- KPI cards with key visitor metrics.
- Weekly cohort retention heatmap.
- Retention trends by first-session segment.
- Interactive segment filtering.
- Customized tooltips with cohort sizes, retained visitors, and retention rates.
- Key analytical insights.

## Key Metrics

| Metric | Value |
|---|---:|
| View Visitors | 1,404,179 |
| Cart Visitors | 31,487 |
| Transaction Visitors | 8,596 |
| View-to-Cart Conversion Rate | 2.24% |
| Cart-to-Purchase Conversion Rate | 27.30% |
| View-to-Purchase Conversion Rate | 0.61% |

## Key Insights

- The largest visitor drop-off occurs between product views and cart additions, with a drop-off rate of 97.76%.
- Only 0.61% of product view visitors complete the sequential purchase funnel.
- Weekly retention declines substantially after the first week across all first-session segments.
- Users who purchase during their first session demonstrate the highest early-week retention.
- Users who add products to their cart without completing a purchase also show higher early-week retention than users who only view products.

## Business Recommendations

- Investigate potential barriers between product views and cart additions.
- Analyze product page usability and add-to-cart behavior.
- Explore re-engagement strategies during the first weeks after a user's initial session.
- Evaluate personalized retention strategies for different behavioral segments.

These recommendations represent opportunities for further investigation rather than confirmed causal relationships.

## Dashboard

The interactive Tableau dashboard provides an overview of key product metrics, weekly cohort retention, and behavioral segmentation.

[View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/olena.vystavna/viz/retailrocket_product_analytics/RetailRocketUserFunnelRetention)

![Dashboard Preview](dashboard/dashboard_preview.png)


## Repository Structure

- `data/processed/` — processed datasets used for visualization.
- `sql/` — SQL queries for data processing and analysis.
- `scripts/` — supporting scripts.
- `dashboard/` — Tableau workbook and dashboard preview.
- `docs/` — project documentation.
- `README.md` — project overview and analytical findings.

## Analysis Limitations

- Funnel stages must occur sequentially within the same session, but matching product IDs across stages is not required.
- Cross-session conversion paths are not captured by the funnel.
- Sessions are inferred using a 30-minute inactivity threshold rather than explicit session identifiers.
- The first observed session does not necessarily represent a user's first-ever interaction with the platform.
- Retention comparisons are observational and do not establish causality.
- Later retention periods include fewer eligible cohorts due to the limited observation window.
- The first calendar week of the dataset may represent an incomplete observation period.
