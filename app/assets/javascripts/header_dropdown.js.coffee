$(document).on("ready page:load", ->
  $dropdown = $("#header-dropdown")
  $noDropdownButtons = $(".no-dropdown-buttons")
  $dropdownSections = $dropdown.find(".user-info, .admin-info")
  $container = $("#main-container")
  dropdownActiveClass = "dropdown-active"

  closeDropdown = ->
    $dropdown.hide()
    $noDropdownButtons.show()
    $container.removeClass(dropdownActiveClass)
    return false

  openDropdown = ->
    $dropdown.show()
    $noDropdownButtons.hide()
    $container.addClass(dropdownActiveClass)
    return false    

  toggleDropdownSection = ->
    $el = $(this)
    openDropdown() unless $dropdown.is(":visible")

    selector = $el.data("dropdown-section")
    $section = $dropdown.find(selector)
    console.log $section.length and !$section.is(":visible")
    console.log $section
    if $section.length and !$section.is(":visible")
      $dropdownSections.hide()
      $section.show()
    return false

  $(document).on("click", ".dropdown-close", closeDropdown)
  $(document).on("click", ".dropdown-toggle-section", toggleDropdownSection)
)