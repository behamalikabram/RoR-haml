$(document).on "ready page:load", ->
  $modal = $("#page-modal")
  $modalBody = $modal.find('.modal-body')
  $modalTitle = $modal.find(".modal-header .modal-title")

  window.resetPageModal = ->
    $modalTitle.html('Loading...')
    $modalBody.addClass("loading").html('')

  window.updatePageModal = (title, body) ->
    $modalTitle.html(title)
    $modalBody.removeClass("loading").html(body)
    $modal.modal("adjustBackdrop")

  $modal.on 'show.bs.modal', resetPageModal  

  $(document).on('click', "a.page-modal-show", (e) ->
    return true unless e.which == 1
    $modal.modal("show")
  )

  $(document).on('submit', "form.page-modal-show", ->
    $modal.modal("show")
  )