CREATE TABLE users (
  id                serial          PRIMARY KEY,
  user_name         varchar(50),
  password          varchar(10)
);


CREATE TABLE tracked_event (
  id               serial           PRIMARY KEY,
  name             varchar(80),
  user_id          integer          REFERENCES users (id)
);


CREATE TABLE time_stamps (
  id               serial           PRIMARY KEY,
  notes            varchar(400),
  event_id         integer          REFERENCES tracked_event (id),
  timestamp        timestamp default current_timestamp
);
