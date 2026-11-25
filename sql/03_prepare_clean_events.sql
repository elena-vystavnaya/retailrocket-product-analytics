-- use utc when displaying and converting timestamps
set time zone 'UTC';

-- rebuild the derived table if it already exists
drop table if exists events_clean;

-- remove exact duplicate source rows and convert columns to useful data types
create table events_clean as
with deduplicated_raw as (
    select distinct
        "timestamp",
        visitorid,
        event,
        itemid,
        transactionid
    from events_raw
)
select
    to_timestamp(
        nullif(btrim("timestamp"), '')::double precision / 1000.0
    ) as event_ts,
    nullif(btrim(visitorid), '')::bigint as visitor_id,
    event as event_type,
    nullif(btrim(itemid), '')::bigint as item_id,
    nullif(btrim(transactionid), '')::bigint as transaction_id
from deduplicated_raw;

-- check the cleaned row count and event counts
select count(*) as rows
from events_clean;

select event_type, count(*) as rows
from events_clean
group by event_type
order by event_type;

-- check visitors and the timestamp range
select
    count(distinct visitor_id) as unique_visitors,
    min(event_ts) as first_event_utc,
    max(event_ts) as last_event_utc
from events_clean;

select
    event_ts,
    event_ts at time zone 'UTC' as event_time_utc
from events_clean
order by event_ts
limit 1;
