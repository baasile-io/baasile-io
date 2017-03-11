$.fn.select2.defaults.set("theme", "bootstrap");

$(document).ready(function(e) {

  $('a[data-toggle="tab"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

  $('input.input-placeholder-live-update').on('keyup change', function(e) {
    input = $(this);
    $('#'+input.data('target')).attr('placeholder', input.val());
  });

  $('select[data-layer="tags"]').select2({
    tags: true,
    multiple: true,
    tokenSeparators: [' '],
    language: I18n.locale
  });

  $('select.select2').select2({
    language: I18n.locale
  });

});
