function input_subdomain_live_update(e) {
  input = $(this);
  var form_group_livepreview = $('div.form-group.subdomain_livepreview');
  var value = input.val();
  console.log(typeof value);
  if (value === '') {
    form_group_livepreview.hide();
  } else {
    form_group_livepreview.show();
  }
  var prefix = input.data('prefix');
  if (prefix != null)
    value = prefix + value;
  $('#'+input.data('target')).val(value);
}

$(document).ready(function() {

  $('input#service_subdomain').on('keyup change', input_subdomain_live_update).each(input_subdomain_live_update);

});