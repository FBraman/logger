CREATE TABLE tracked_event (
  id               serial           PRIMARY KEY,
  name             varchar(80)

);


CREATE TABLE time_stamps (
  event_id         integer          REFERENCES tracked_event (id),
  occurence        varchar(50),
  notes            varchar(400)
);
