$(document).ready(function(e) {

  if ($('form.edit_price, form#new_price').length > 0) {
    var price_pricing_type_input = $('#price_pricing_type');
    var price_pricing_duration_type_input = $('#price_pricing_duration_type');
    var price_route_id_input = $('#price_route_id');
    var price_free_count_input = $('#price_free_count');
    var price_deny_after_free_count_true_input = $('#price_deny_after_free_count_true');
    var price_deny_after_free_count_false_input = $('#price_deny_after_free_count_false');
    var price_unit_cost_input = $('#price_unit_cost');

    function price_update_form_state() {
      if (price_pricing_type_input.val() == 'subscription') {
        toggle_input(price_route_id_input, true);
        toggle_input(price_free_count_input, true);
        toggle_input(price_deny_after_free_count_true_input, true);
        toggle_input(price_deny_after_free_count_false_input, true);
        toggle_input(price_unit_cost_input, true);

        if (price_pricing_duration_type_input.val() == 'prepaid') {
          price_pricing_duration_type_input.val('monthly');
        }
        price_pricing_duration_type_input.find('option[value="prepaid"]').prop('disabled', true);
      } else {
        if (price_pricing_type_input.val() == 'per_call') {
          toggle_input(price_route_id_input, false);
        } else if (price_pricing_type_input.val() == 'per_parameter') {
          toggle_input(price_route_id_input, true);
        }

        toggle_input(price_free_count_input, false);
        toggle_input(price_deny_after_free_count_true_input, false);
        toggle_input(price_deny_after_free_count_false_input, false);

        price_unit_cost_update_input_state();

        price_pricing_duration_type_input.find('option[value="prepaid"]').prop('disabled', false);
      }
      window.apply_select2(price_pricing_duration_type_input);
    }

    function toggle_input(input, disable) {
      var input_type = input[0].type;
      var input_id = input[0].id;
      var container = $('div.form-group.' + input_id.replace(/_true/, ''));
      if (disable) {
        if (input_type != 'radio') {
          input.attr('disabled', 'disabled');
        }
        if (input_type == 'select-one') {
          input.val('');
        }
        container.hide();
      } else {
        input.removeAttr('disabled');
        container.show();
      }
      input.trigger('change');
    }

    function price_unit_cost_update_input_state() {
      if (price_deny_after_free_count_true_input.is(':checked')) {
        toggle_input(price_unit_cost_input, true);
      } else {
        toggle_input(price_unit_cost_input, false);
      }
    }

    price_pricing_type_input.on('change', price_update_form_state);
    price_deny_after_free_count_true_input.on('change', price_unit_cost_update_input_state);
    price_deny_after_free_count_false_input.on('change', price_unit_cost_update_input_state);
    price_update_form_state();
  }

});

