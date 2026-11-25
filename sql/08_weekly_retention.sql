drop table if exists weekly_retention;

create table weekly_retention as
with weekly_activity as (
    select distinct
        visitor_id,
        date_trunc('week', event_date_utc::timestamp)::date as activity_week
    from events_with_sessions
),
cohort_sizes as (
    select
        cohort_week,
        first_session_segment,
        count(*) as cohort_size
    from visitor_cohorts
    group by cohort_week, first_session_segment
),
retained_by_week as (
    select
        c.cohort_week,
        c.first_session_segment,
        ((a.activity_week - c.cohort_week) / 7) as week_number,
        count(distinct c.visitor_id) as retained_visitors
    from visitor_cohorts c
    join weekly_activity a
        on a.visitor_id = c.visitor_id
        and a.activity_week >= c.cohort_week
    group by
        c.cohort_week,
        c.first_session_segment,
        ((a.activity_week - c.cohort_week) / 7)
),
last_observation as (
    select max(event_date_utc) as last_event_date
    from events_with_sessions
),
cohort_periods as (
    select
        c.cohort_week,
        c.first_session_segment,
        c.cohort_size,
        p.week_number,
        c.cohort_week + p.week_number * 7 + 6 <= l.last_event_date
            as period_complete
    from cohort_sizes c
    cross join last_observation l
    cross join lateral generate_series(
        0,
        (l.last_event_date - c.cohort_week) / 7
    ) as p(week_number)
)
select
    p.cohort_week,
    p.first_session_segment,
    p.week_number,
    p.cohort_size,
    coalesce(r.retained_visitors, 0) as retained_visitors,
    round(
        100.0 * coalesce(r.retained_visitors, 0) / nullif(p.cohort_size, 0),
        2
    ) as retention_pct,
    p.period_complete
from cohort_periods p
left join retained_by_week r
    on r.cohort_week = p.cohort_week
    and r.first_session_segment = p.first_session_segment
    and r.week_number = p.week_number;

-- View the cohort retention table
select
    cohort_week,
    first_session_segment,
    week_number,
    cohort_size,
    retained_visitors,
    retention_pct,
    period_complete
from weekly_retention
where week_number between 0 and 4
order by cohort_week, first_session_segment, week_number;

-- Compare segments using only complete retention weeks
select
    first_session_segment,
    week_number,
    sum(retained_visitors) as retained_visitors,
    sum(cohort_size) as cohort_size,
    round(
        100.0 * sum(retained_visitors) / nullif(sum(cohort_size), 0),
        2
    ) as weighted_retention_pct
from weekly_retention
where week_number between 1 and 4
    and period_complete
group by first_session_segment, week_number
order by first_session_segment, week_number;