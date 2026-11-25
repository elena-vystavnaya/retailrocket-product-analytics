from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parents[1]
EVENTS_PATH = PROJECT_DIR / "dataset" / "events.csv"

REQUIRED_COLUMNS = [
    "timestamp",
    "visitorid",
    "event",
    "itemid",
    "transactionid"
]
VALID_EVENTS = ["view", "addtocart", "transaction"]

def main():
    if not EVENTS_PATH.exists():
        raise FileNotFoundError(f"File not found: {EVENTS_PATH}")

    print(f"Reading data from {EVENTS_PATH}...")

    events = pd.read_csv(EVENTS_PATH)

    missing_columns = [
        col for col in REQUIRED_COLUMNS if col not in events.columns
    ]

    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    row_count = len(events)
    unique_visitors = events["visitorid"].nunique()

    timestamp_ms = pd.to_numeric(events["timestamp"], errors="coerce")
    timestamp_utc = pd.to_datetime(
        timestamp_ms,
        unit="ms",
        utc=True,
        errors="coerce"
    )

    event_counts = events["event"].value_counts(dropna=False)
    unknown_events_count = (
        events["event"].notna()
        & ~events["event"].isin(VALID_EVENTS)
    ).sum()

    missing_values = events[REQUIRED_COLUMNS].isna().sum()

    transaction_rows = events["event"].eq("transaction")
    missing_transaction_ids = (
        transaction_rows & events["transactionid"].isna()
    ).sum()

    transaction_ids = events.loc[
        transaction_rows, "transactionid"
    ].dropna()
    repeated_transaction_id_rows = transaction_ids.duplicated().sum()

    exact_duplicate_rows = events.duplicated(
        subset=REQUIRED_COLUMNS
    ).sum()

    duplicate_mask = events.duplicated(
    subset=REQUIRED_COLUMNS,
    keep="first",
)

    duplicate_counts_by_event = (
        events.loc[duplicate_mask, "event"]
        .value_counts(dropna=False)
    )

    duplicate_groups = (
        events.loc[
            events.duplicated(subset=REQUIRED_COLUMNS, keep=False),
            REQUIRED_COLUMNS,
        ]
        .drop_duplicates()
        .shape[0]
    )

    print("\n--- Dataset summary ---")
    print(f"Rows: {row_count:,}")
    print(f"Unique visitors: {unique_visitors:,}")
    print(f"Date range (UTC): {timestamp_utc.min()} — {timestamp_utc.max()}")

    print("\n--- Event counts ---")
    print(event_counts.to_string())

    print("\n--- Missing values ---")
    print(missing_values.to_string())

    print("\n--- Data quality checks ---")
    print(f"Exact duplicate groups: {duplicate_groups:,}")
    print("Extra exact duplicate rows by event:")
    print(duplicate_counts_by_event.to_string())

    print(f"Invalid timestamps: {timestamp_utc.isna().sum():,}")
    print(f"Unknown event types: {unknown_events_count:,}")
    print(f"Transactions missing transaction ID: {missing_transaction_ids:,}")
    print(f"Exact duplicate rows: {exact_duplicate_rows:,}")
    print(
        "Rows with a repeated transaction ID "
        f"(informational): {repeated_transaction_id_rows:,}"
    )

    errors = []

    if timestamp_utc.isna().any():
        errors.append("Some timestamps are missing or invalid.")

    if events[["visitorid", "event", "itemid"]].isna().any().any():
        errors.append("Some required visitor, event, or item values are missing.")

    if unknown_events_count:
        errors.append("The file contains event types outside the expected set.")

    if missing_transaction_ids:
        errors.append("Some transaction events have no transaction ID.")

    if errors:
        print("\nValidation result: CHECK REQUIRED")
        for error in errors:
            print(f"- {error}")
    else:
        print("\nValidation result: PASSED")
        if exact_duplicate_rows:
            print(
                "Review exact duplicate rows before deciding how to handle them."
            )


if __name__ == "__main__":
    main()
