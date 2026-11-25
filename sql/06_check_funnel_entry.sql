with visitor_events as (
    select
        visitor_id,
        bool_or(event_type = 'view') as has_view,
        bool_or(event_type = 'addtocart') as has_cart,
        bool_or(event_type = 'transaction') as has_transaction
    from events_with_sessions
    group by visitor_id
)
select
    has_view,
    has_cart,
    has_transaction,
    count(*) as visitors
from visitor_events
group by has_view, has_cart, has_transaction
order by has_view, has_cart, has_transaction;