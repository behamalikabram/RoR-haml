$(document).on "ready page:load", -> 

  dispatcher = window.initializeWebsocketsDispatcher()

  # Scroll to bottom of chatbox
  $box = $(".chat-box")
  $box.scrollTop($box.prop("scrollHeight"))

  # Allow users to send send messages on enter key press
  $("body").on("keydown", ".chat-form textarea", (event) -> 
    $form = $(this).closest("form") 
    if event.keyCode == 13 && !event.shiftKey
      $form.submit()
      false 
  )

  isSubmitViaWebsockets = ->
    !$("#ajax-submit-chat-form").is(':checked')

  submitSuccess = ($form) ->
    $form.find("textarea").val('')
    $form.find(".errors").html('')
    $form.enableForm()

  submitFailure = (data, $form) ->
    errorMessage = ""
    if data.errors
      $.each(data.errors, -> errorMessage += "<li>#{this}</li>")
    else 
      errorMessage = "<li>Can't submit your message. Please reload the page or try again</li>"
    $form.find(".errors").html("<ul class='error-messages'>#{errorMessage}</ul>")
    $form.enableForm()

  submitMessage = ->
    $form = $(this)
    $area = $form.find("textarea")
    if $area.val()
      $form.disableForm() 
      if isSubmitViaWebsockets()
        $("#browser_info").val('')
        object = {content: $form.find(".message_content").val(), chat_id: $form.find(".message_chat_id").val()}
        dispatcher.trigger("chat.new_message", object, (-> submitSuccess($form)), ((data) -> submitFailure(data, $form)))
      else 
        $("#browser_info").val("I can't send any messages! Browser - #{navigator.userAgent}")   
    return !isSubmitViaWebsockets()


  # $(".chat-form").on("submit", false)
  $("body").on("submit", ".chat-form", submitMessage)

  $.fn.disableForm = -> 
    if isSubmitViaWebsockets()
      $(this).off("submit", submitMessage)
    else
      $(this).on("submit", false)

  $.fn.enableForm = -> 
    if isSubmitViaWebsockets()
      $(this).off("submit", submitMessage)
      $(this).on("submit", submitMessage)
    else 
      $(this).off("submit", false)

  $.fn.scrollToBottom = -> 
    $this = $(this)
    $this.scrollTop($this.prop("scrollHeight"))

  $.fn.updateChatContent = (data) ->
    $content = $(this)
    $message= $("<div class='message #{data.role}-message'><span class='timestamp' data-time='#{data.created_at}'></span><span class='from'>#{data.from}:</span> <span class='message-content #{data.type}'></span></div>")
    $message.find(".timestamp").addTimeStamp()
    if data.type
      $message.find(".message-content").html(data.message)
    else 
      $message.find(".message-content").text(data.message)

    $content.append($message)
    scrollHeight = $content.prop("scrollHeight")
    scrollTop = $content.prop("scrollTop")
    if (scrollHeight - scrollTop - $content.height()) < 60
      $content.scrollTop(scrollHeight)

  addTimeStamp = -> 
    $elem = $(this)
    date = new Date($elem.data('time'))
    h = date.getHours()
    h = "0#{h}" if h < 10
    m = date.getMinutes()
    m = "0#{m}" if m < 10 
    text = "[#{h}:#{m}] "
    $elem.html(text)

  $.fn.addTimeStamp = addTimeStamp

  $(".timestamp").each(addTimeStamp)
  $(".chat-content, .chat-body").scrollToBottom()