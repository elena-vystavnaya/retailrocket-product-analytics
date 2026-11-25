drop table if exists visitor_funnel;

create table visitor_funnel as
with first_views as (
    select
        visitor_id,
        session_id,
        min(event_ts) as view_ts
    from events_with_sessions
    where event_type = 'view'
    group by visitor_id, session_id
),
carts_after_view as (
    select
        v.visitor_id,
        v.session_id,
        v.view_ts,
        min(e.event_ts) as cart_ts
    from first_views v
    left join events_with_sessions e
        on e.visitor_id = v.visitor_id
        and e.session_id = v.session_id
        and e.event_type = 'addtocart'
        and e.event_ts > v.view_ts
    group by v.visitor_id, v.session_id, v.view_ts
),
transactions_after_cart as (
    select
        c.visitor_id,
        c.session_id,
        c.view_ts,
        c.cart_ts,
        min(e.event_ts) as transaction_ts
    from carts_after_view c
    left join events_with_sessions e
        on e.visitor_id = c.visitor_id
        and e.session_id = c.session_id
        and e.event_type = 'transaction'
        and e.event_ts > c.cart_ts
    group by c.visitor_id, c.session_id, c.view_ts, c.cart_ts
)
select
    visitor_id,
    bool_or(view_ts is not null) as reached_view,
    bool_or(cart_ts is not null) as reached_cart,
    bool_or(transaction_ts is not null) as reached_transaction
from transactions_after_cart
group by visitor_id;

with funnel_counts as (
    select
        count(*) filter (where reached_view) as visitors_view,
        count(*) filter (where reached_cart) as visitors_cart,
        count(*) filter (where reached_transaction) as visitors_transaction
    from visitor_funnel
)
select
    visitors_view,
    visitors_cart,
    visitors_transaction,
    round(100.0 * visitors_cart / nullif(visitors_view, 0), 2)
        as view_to_cart_conversion_pct,
    round(100.0 * visitors_transaction / nullif(visitors_cart, 0), 2)
        as cart_to_transaction_conversion_pct,
    round(100.0 * visitors_transaction / nullif(visitors_view, 0), 2)
        as overall_conversion_pct
from funnel_counts;