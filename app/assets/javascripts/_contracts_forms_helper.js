$(document).ready(function(e) {

  var contract_duration_type_input = $('#contract_contract_duration_type');
  var contract_expected_start_date_input = $('#contract_expected_start_date');
  var contract_expected_end_date_input = $('#contract_expected_end_date');
  var contract_expected_contract_duration_input = $('#contract_expected_contract_duration');

  function contract_update_form_state() {
    if(contract_duration_type_input.val() == 'custom') {
      contract_expected_end_date_input.removeAttr('disabled');
      contract_expected_contract_duration_input.removeAttr('disabled');
    } else {
      contract_expected_end_date_input.attr('disabled', 'disabled');
      contract_expected_contract_duration_input.attr('disabled', 'disabled');
    }
  };

  contract_duration_type_input.on('change', contract_update_form_state);
  contract_update_form_state();

});

