$(document).on("ready page:load", ->
  typeElem = $("#dice_game_type")
  checkGameType = ->
    $this = $(this)
    $capacityElem = $("label.capacity")
    if $this.val() == '55x2'
      $capacityElem.hide();
    else 
      $capacityElem.show();

  typeElem.on("change", checkGameType)
  checkGameType.apply(typeElem)
)