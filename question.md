```

get "/tracked_events/:event_name" do
  erb :individual_event, locals: { event_name: params[:event_name]}
end





post "/new_time" do
  tm = Time.new
  event_name = params["event_name"]
  binding.pry
  # db_connection do |conn|
  #   conn.exec_params("INSERT INTO #{event_name} VALUES #{tm}")
  # end
  redirect "/tracked_events/:event_name"
end


and the post button that contains nothing


<form action="/new_time" method="post" class="button">
  <label for="<% event_name %>">STAMP IT</label>
  <input type="submit" id="<% event_name %>" name="<% event_name %>">





```
