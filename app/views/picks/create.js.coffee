window.screening_ids_by_status = <%= raw({}.to_json) %>
jQuery(document).triggerHandler('picks:updated', 'body')
