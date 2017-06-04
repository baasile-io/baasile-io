var input_service_name = $('input#service_name');
var input_service_subdomain = $('input#service_subdomain');

function parse_subdomain_from_name(value) {
  if (typeof value == 'undefined')
    return '';
  return value.toLowerCase().removeAccents().replace(/ /g, "-").replace(/[^-a-z0-9]+/g, "").replace(/(--)/g, "-")
}

function generate_subdomain_auto() {
  var service_name = input_service_name.val();
  var new_subdomain = parse_subdomain_from_name(service_name);
  if (input_service_subdomain.val() === '') {
    input_service_subdomain.val(new_subdomain);
    input_service_subdomain.trigger('change');
  }
  input_service_subdomain.attr('placeholder', new_subdomain);
}

function update_subdomain_placeholder() {
  var service_name = input_service_name.val();
  var new_subdomain = parse_subdomain_from_name(service_name);
  input_service_subdomain.attr('placeholder', new_subdomain);

  var old_service_name = input_service_name.data('old-value');
  var old_subdomain = parse_subdomain_from_name(old_service_name);
  input_service_name.data('old-value', service_name);
  if (input_service_subdomain.val() === old_subdomain) {
    input_service_subdomain.val(new_subdomain);
    input_service_subdomain.trigger('change');
  }
}

if (!input_service_subdomain.is(':disabled')) {
  input_service_name.on('keyup', update_subdomain_placeholder);
  input_service_name.on('blur', generate_subdomain_auto);
  input_service_subdomain.on('blur', function () {
    if (input_service_subdomain.val() === '') {
      generate_subdomain_auto();
    }
  });
}


function input_subdomain_live_update(e) {
  var input = $(this);
  var form_group_livepreview = $('div.form-group.subdomain_livepreview');
  var value = input.val();
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

var input_url = $('input#route_url');
var input_protocol = $('select#route_protocol');
var input_hostname = $('input#route_hostname');
var input_port = $('input#route_port');
var input_protocol_test = $('select#route_protocol_test');
var input_hostname_test = $('input#route_hostname_test');
var input_port_test = $('input#route_port_test');

function input_url_live_update(e) {
  var form_groups_livepreview = $('div.form-group.url_livepreview');
  var value = input_url.val();
  if (value === '') {
    form_groups_livepreview.hide();
  } else {
    form_groups_livepreview.show();
  }

  var base_test_protocol = input_url.data('base-test-protocol');
  var base_test_hostname = input_url.data('base-test-hostname');
  var base_test_port = input_url.data('base-test-port');

  var base_protocol = input_url.data('base-protocol');
  var base_hostname = input_url.data('base-hostname');
  var base_port = input_url.data('base-port');

  var protocol_test = input_protocol_test.val();
  var hostname_test = input_hostname_test.val();
  var port_test = input_port_test.val();

  var protocol = input_protocol.val();
  var hostname = input_hostname.val();
  var port = input_port.val();

  if (protocol_test === '')
    protocol_test = base_test_protocol;
  if (hostname_test === '')
    hostname_test = base_test_hostname;
  if (port_test === '')
    port_test = base_test_port;

  if (protocol === '')
    protocol = base_protocol;
  if (hostname === '')
    hostname = base_hostname;
  if (port === '')
    port = base_port;

  $('#route_url_test_livepreview').val(protocol_test + '://' + hostname_test + ':' + port_test + value);
  $('#route_url_livepreview').val(protocol + '://' + hostname + ':' + port + value);
}

$(document).ready(function() {

  $('input#service_subdomain, input#proxy_subdomain, input#route_subdomain').on('keyup change', input_subdomain_live_update).each(input_subdomain_live_update);
  input_url.on('keyup change', input_url_live_update).each(input_url_live_update);
  input_protocol_test.on('keyup change', input_url_live_update);
  input_hostname_test.on('keyup change', input_url_live_update);
  input_port_test.on('keyup change', input_url_live_update);
  input_protocol.on('keyup change', input_url_live_update);
  input_hostname.on('keyup change', input_url_live_update);
  input_port.on('keyup change', input_url_live_update);

});