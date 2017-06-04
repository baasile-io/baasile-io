$(document).ready(function() {

  var modal_message = $(".b-io-modal-message");
  var modal_background = $(".b-io-modal-background");
  var modal = $(".b-io-modal");
  var modal_close_btn = $('.popover-title a')

  modal_message.hide();
  modal.show();
  modal_message.fadeIn();
  modal_close_btn.on('click', function(e) {
    e.preventDefault();
    $(this).parent().parent().parent().parent().hide();
  });
  modal_background.on('click', function() {
    $(this).parent().hide();
  });

});