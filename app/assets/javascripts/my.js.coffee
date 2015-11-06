$(document).on "ready page:load", (e) ->
  $('.full-width').horizontalNav({})

  $( ".lang" ).click(-> $( ".drop" ).slideToggle( "slow" ))

  $('.form').TMForm(ownerEmail:'#')

  # Some chrome bag with turbolinks when remote form is submitted twice and second time is using http
  foobar = (e) -> 
    $(this).closest("form").submit()
    return false

  $(document).on("click", ".form a.submit", foobar)
  
  # Noty 
  $('#flash .alert').each(-> 
    $alertElem = $(this);
    noty({text: $(this).html(), type: $alertElem.data('alert-type')}).show();
  )

  $('.js-lazyYT').lazyYT()

  $("body").on("click", "tr.clickable", -> 
    window.location = $(this).data("url")
    return false
  )

  $("body").on("submit", "form.disable-after-submit", ->
    $(this).on("submit", false)
    true
  )
  $("body").on("click", ".disable-after-click", ->
    $(this).on("click", false)
    true
  )

  $(".btn-disabled").click(false)