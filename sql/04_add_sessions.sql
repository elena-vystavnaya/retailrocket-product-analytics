drop table if exists events_with_sessions;

create table events_with_sessions as
with ordered_events as (
    select
        *,
        lag(event_ts) over (
            partition by visitor_id
            order by
                event_ts,
                event_type,
                item_id,
                transaction_id nulls first
        ) as previous_event_ts
    from events_clean
),
session_flags as (
    select
        *,
        case
            when previous_event_ts is null
              or event_ts - previous_event_ts > interval '30 minutes'
            then 1
            else 0
        end as starts_new_session
    from ordered_events
),
numbered_events as (
    select
        *,
        sum(starts_new_session) over (
            partition by visitor_id
            order by
                event_ts,
                event_type,
                item_id,
                transaction_id nulls first
            rows between unbounded preceding and current row
        ) as session_number
    from session_flags
)
select
    event_ts,
    visitor_id,
    event_type,
    item_id,
    transaction_id,
    session_number,
    visitor_id::text || '_' || session_number::text as session_id,
    (event_ts at time zone 'UTC')::date as event_date_utc
from numbered_events;

select
    count(*) as event_rows,
    count(distinct visitor_id) as visitors,
    count(distinct session_id) as sessions
from events_with_sessions;