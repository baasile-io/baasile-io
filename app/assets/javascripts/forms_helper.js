$(document).ready(function(e) {

  $('a[data-toggle="tab"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

  $('input.input-placeholder-live-update').on('keyup change', function(e) {
    input = $(this)
    $('#'+input.data('target')).attr('placeholder', input.val());
  });

});
