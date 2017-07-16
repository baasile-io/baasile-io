var close_custom_modal = function(e) {
  e.preventDefault();
  $(this).parent().parent().parent().parent().hide();
};

$(document).ready(function() {

  var modal_message = $(".b-io-modal-message");
  var modal_background = $(".b-io-modal-background");
  var modal = $(".b-io-modal");
  var modal_close_btn = $('.popover-title a');
  var modal_ignore_btn = $('.popover-content .btn-ignore');

  modal_message.hide();
  modal.show();
  modal_message.fadeIn();
  modal_close_btn.on('click', close_custom_modal);
  modal_ignore_btn.on('click', close_custom_modal);
  modal_background.on('click', function() {
    $(this).parent().hide();
  });

});