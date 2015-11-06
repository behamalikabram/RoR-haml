$("#<%= @chat.channel_name %>").remove()
$("body").append("<%= j render('chat', host: @host, messages: @messages, chat: @chat) %>")