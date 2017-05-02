$(document).ready(function(e) {

  if ($('form.edit_proxy, form#new_proxy').length > 0) {
    var proxy_proxy_parameter_test_attributes_authorization_mode_input = $('#proxy_proxy_parameter_test_attributes_authorization_mode');
    var proxy_proxy_parameter_attributes_authorization_mode_input = $('#proxy_proxy_parameter_attributes_authorization_mode');
    var proxy_proxy_parameter_test_attributes_authorization_mode_container = $('#proxy_proxy_parameter_test_attributes_authorization_mode_inputs');
    var proxy_proxy_parameter_attributes_authorization_mode_container = $('#proxy_proxy_parameter_attributes_authorization_mode_inputs');

    function proxy_parameter_form_state() {
      if (proxy_proxy_parameter_test_attributes_authorization_mode_input.val() == 'null') {
        proxy_proxy_parameter_test_attributes_authorization_mode_container.hide();
      } else {
        proxy_proxy_parameter_test_attributes_authorization_mode_container.show();
      }
      if (proxy_proxy_parameter_attributes_authorization_mode_input.val() == 'null') {
        proxy_proxy_parameter_attributes_authorization_mode_container.hide();
      } else {
        proxy_proxy_parameter_attributes_authorization_mode_container.show();
      }
    }

    proxy_proxy_parameter_test_attributes_authorization_mode_input.on('change', proxy_parameter_form_state);
    proxy_proxy_parameter_attributes_authorization_mode_input.on('change', proxy_parameter_form_state);
    proxy_parameter_form_state();
  }

});

