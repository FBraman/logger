require 'sinatra'
require 'pg'
require 'pry'
require 'session'
require 'time'

def db_connection
  begin
    connection = PG.connect(dbname: "toyapp")
    yield(connection)
  ensure
    connection.close
  end
end

# def get_time
#   Time.new
# end

get "/tracked_events" do
  events = db_connection do |conn|
    conn.exec("SELECT name, id FROM tracked_event")
  end
  erb :index, locals: {events: events}
end


get "/tracked_events/:id" do
  id = params[:id].to_i
  name = db_connection do |conn|
    conn.exec("SELECT name FROM tracked_event WHERE tracked_event.id = $1", [id])
  end
  stamps = db_connection do |conn|
    conn.exec("SELECT occurence FROM time_stamps
              JOIN tracked_event ON time_stamps.event_id = tracked_event.id
              WHERE  time_stamps.event_id = $1", [id])
  end
  erb :individual_event, locals: { event_name: name[0]["name"], stamps: stamps, id: id}
end


post "/new_time" do
  tm = Time.new.to_time
  binding.pry
  # local_id = params["id"].to_i
  local_event_name = params["name"]
  id = []
  binding.pry
  db_connection do |conn|
    local = conn.exec("SELECT id FROM tracked_event WHERE tracked_event.name = $1", [local_event_name])
    local_id = local[0]["id"].to_i
    id << local_id
    conn.exec("INSERT INTO time_stamps (occurence, event_id) VALUES ($1, $2)", [tm, local_id])
    redirect "/tracked_events/#{id[0]}"
  end
  # erb :individual_event, locals: { event_name: local_event_name, event_id: local_id }

end

post "/new_event" do
  local_new_event = params["new_event"]
  db_connection do |conn|
    conn.exec("INSERT INTO tracked_event (name) VALUES ($1) ", [local_new_event])
  end
  redirect "/tracked_events"
end
