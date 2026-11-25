create schema if not exists retailrocket;

create table events_raw (
    "timestamp" text,
    visitorid text,
    event text,
    itemid text,
    transactionid text
);
