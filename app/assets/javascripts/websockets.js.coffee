$(->
  dispatcher = window.initializeWebsocketsDispatcher()

  channel = dispatcher.subscribe("general_chat");
  
  channel.bind('update_chat', (data) ->
    $("#general-chat .chat-content").updateChatContent(data)
  );

  channel.bind('user_online', (data) ->
    $box = $(".online-box")
    unless $box.find("#chat_user_#{data.id}").length
      $box.append("<div id='chat_user_#{data.id}' class='#{data.role}-message message'><span class='from'>#{data.user}</span></div>")
  );

  ticketsChannel = dispatcher.resubscribe('tickets');

  ticketAudio = new Audio("/beep.wav")

  ticketsChannel.bind("update_count", (data) -> 
    $countElem = $('.tickets-count')
    console.log $countElem
    if $countElem.length
      $countElem.fadeOut(1000, -> $(this).text(data.count).fadeIn(1000))
      ticketAudio.play()

  )

  dispatcher.bind("new_notification", (data) -> 
    $("#user_notifications").fadeIn(1000)
    ticketAudio.play()
  )
)