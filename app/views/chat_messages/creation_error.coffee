$(".chat-form .errors").html($("<%= j render('shared/error_messages', object: @message) %>"))
$(".chat-form").enableForm()