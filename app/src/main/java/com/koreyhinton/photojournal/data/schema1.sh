#!/bin/bash

cat << EOF

-- dc => digital camera
create table if not exists dc (
    id integer primary key,
    dc_alias text not null, /*
        ^ short text that is not unique to 1 dc row,
            ie: KIPH => korey's iphone
        */
    make text,
    model text
) strict;

-- dcim => digital camera image
--         Can be file on disk and/or s3 compatible cloud storage
create table if not exists dcim (
    id integer primary key,
    dc_alias text not null, /*
        ^ short text that is not unique to 1 dc row,
            ie: KIPH => korey's iphone
        */
    capture_date text -- '2026-08-29'
        check (
            capture_date is null
            or (
                length(capture_date) = 10
                and substr(capture_date, 5, 1) = '-'
                and substr(capture_date, 8, 1) = '-'
                and date(capture_date) = capture_date
            )
        ), -- the image file likely has the full datetime in its metadata,
           -- however storing just the date w/out time will be very fast
           -- for these 2 scenarios:
           --  1) user adds a pic to a previously selected journal day
           --  2) cloud image backed up by the app has the date part in the name
    orig_name text,
    android_key text, -- includes device info to retrieve the file from disk

    unique(dc_alias, capture_date, orig_name)
) strict;

create table if not exists bucket_dcim (
    bucket_id integer,
    dcim_id integer,
    primary key (bucket_id, dcim_id)
) strict;

create table if not exists bucket (
    id integer primary key,
    s3_id integer
) strict;

create table if not exists s3 (
    id integer primary key
) strict;

create table if not exists journal_entry (
    id integer primary key,
    date text not null unique -- '2026-08-29'
        check (
            length(date) = 10
            and substr(date, 5, 1) = '-'
            and substr(date, 8, 1) = '-'
            and date(date) = date
        ),
    entry text -- nullable because an empty journal entry gets created for all
               -- detected image dates that don't have an entry yet
) strict;


EOF
