require 'sinatra'
require 'pg'
require 'pry'
require 'session'
require 'time'
require 'openssl'

use Rack::Session::Cookie, {
  secret: "wicked_secret_secret"
}

# def generate_hmac(data, secret)
#   OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
# end

# valid_hmac =


def db_connection
  begin
    connection = PG.connect(dbname: "toyapp")
    yield(connection)
  ensure
    connection.close
  end
end



post "/login"  do
  username = params["user_name"]
  password = params["password"]
  sql = "SELECT users.id FROM users WHERE users.user_name = $1 AND users.password = $2"
  user_confirm = db_connection do |conn|
    conn.exec(sql, [username, password])
  end
  if user_confirm.to_a[0] == nil
    redirect "/logger"
  else
    session[:confirmed] = "confirmed"
    session[:id] = user_confirm[0]["id"]
    redirect "/tracked_events"
  #if login pg select returns nill=create new user, add row to users table with
  #table id, user name and password
      #need to make error for invalid entry
  end
end


post "/choose_view" do
  view_choice = params["choice"]
  if view_choice == "all"
    redirect "/tracked_events"
  elsif view_choice == "mine"
    redirect "/my_events"
  end
end

get "/new" do
  erb :new
end


get "/logger" do
  session[:confirmed] ||= 0
  if session[:confirmed] == "confirmed"
    redirect "/tracked_events"
  end
  erb :login
end

get "/my_events" do
  id = session[:id]
  sql = "SELECT tracked_event.name, tracked_event.id FROM tracked_event
        JOIN users ON tracked_event.user_id = users.id
        WHERE tracked_event.user_id = $1"
  events = db_connection do |conn|
    conn.exec(sql, [id])
  end
  erb :index, locals: { events: events }
end

get "/tracked_events" do
  if session[:confirmed] == 0
    redirect "/logger"
  end
  #construct logic of submission buttons so that if one button clicked, all events returned
  #if other button clicked only user created events are shown
  events = db_connection do |conn|
    conn.exec("SELECT name, id FROM tracked_event")
  end
  erb :index, locals: { events: events }
end




get "/tracked_events/:id" do
  id = params[:id].to_i
  events_by_user_sql = "SELECT name FROM tracked_event WHERE tracked_event.id = $1"
  name = db_connection do |conn|
    conn.exec(events_by_user_sql, [id])
  end
  time_stamps = "SELECT time_stamps.timestamp FROM time_stamps
            JOIN tracked_event ON time_stamps.event_id = tracked_event.id
            WHERE time_stamps.event_id = $1 ORDER BY timestamp DESC"
  stamps = db_connection do |conn|
    conn.exec(time_stamps, [id])
  end

  erb :individual_event, locals: { event_name: name[0]["name"], stamps: stamps, id: id}
end


post "/new_time" do
  # tm = Time.new.to_time
  local_event_name = params["name"]
  id = []
  db_connection do |conn|
    local = conn.exec("SELECT id FROM tracked_event WHERE tracked_event.name = $1", [local_event_name])
    local_id = local[0]["id"].to_i
    id << local_id
    conn.exec("INSERT INTO time_stamps (event_id) VALUES ($1)", [local_id])
    redirect "/tracked_events/#{id[0]}"
  end
end

post "/new_event" do
  local_new_event = params["new_event"]
  id = session["id"]
  db_connection do |conn|
    conn.exec("INSERT INTO tracked_event (name, user_id) VALUES ($1, $2) ", [local_new_event, id])
  end
  redirect "/tracked_events"
end

post "/new_user" do
  name = params[:user_name]
  pass = params[:new_password]
  # test_user_sql = "SELECT users.name_name  FROM users WHERE users.user_name = $1"
  # test_user = db_connection do |conn|
  #   conn.exec()
  #
  # unless
  #
  # test_user
  make_user_sql = "INSERT INTO users (user_name, password) VALUES ($1, $2)"
  db_connection do |conn|
    conn.exec(make_user_sql, [name, pass])
  end
  redirect "/logger"
end

post "/logout" do
  session[:confirmed] = 0
  session[:id] = 0
  redirect "/logger"
end
