select count(*) as rows
from events_raw;

select event, count(*) as rows
from events_raw
group by event
order by event;
