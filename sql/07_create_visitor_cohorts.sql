drop table if exists visitor_cohorts;

create table visitor_cohorts as
with first_seen as (
    select
        visitor_id,
        min(event_ts at time zone 'UTC') as first_seen_utc
    from events_with_sessions
    group by visitor_id
),
first_session_behavior as (
    select
        visitor_id,
        bool_or(event_type = 'view') as has_view,
        bool_or(event_type = 'addtocart') as has_cart,
        bool_or(event_type = 'transaction') as has_transaction
    from events_with_sessions
    where session_number = 1
    group by visitor_id
)
select
    f.visitor_id,
    f.first_seen_utc::date as first_seen_date_utc,
    date_trunc('week', f.first_seen_utc)::date as cohort_week,
    case
        when not s.has_view then 'no_view_first_session'
        when s.has_transaction then 'transaction'
        when s.has_cart then 'cart_no_transaction'
        else 'view_only'
    end as first_session_segment
from first_seen f
join first_session_behavior s
    on f.visitor_id = s.visitor_id;

select count(*) as visitors
from visitor_cohorts;

select
    first_session_segment,
    count(*) as visitors
from visitor_cohorts
group by first_session_segment
order by first_session_segment;