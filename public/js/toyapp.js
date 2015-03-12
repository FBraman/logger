$(".button").on("submit", function(event) {
  var newEvent = $("#new_event").val();
  if (newEvent.length === 0) {
    event.preventDefault();
    alert("New event must not be empty.");
    }
  });
