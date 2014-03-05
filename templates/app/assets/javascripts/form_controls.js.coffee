$(document).bind 'ready page:load', (e) ->
  
  # datepicker
  if !Modernizr.inputtypes.date
    $('.datetimepicker').each () ->
      $(this).datetimepicker({
        startDate: new Date($(this).attr('min')), 
        endDate: new Date($(this).attr('max'))
      }).data('DateTimePicker').setDate(Date.parse($(this).attr('value')))
      

  # file
  $('input[type="file"]').filepicker();