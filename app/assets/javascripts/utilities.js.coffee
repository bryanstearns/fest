
root = exports ? this

root.logged_in = -> jQuery("#sign_out").length == 1

root.model_id_from = (element) ->
  # Given an element ID like "film_123_something",
  # return the "123"
  jQuery(element).attr('id').split('_')[1]
