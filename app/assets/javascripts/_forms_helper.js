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

  function format_select2_option(s) {
    if (!s.id)
      return s.text;
    var el = $(s.element);
    var icon = el.data('icon');
    var type_class = el.data('class');
    var text_right = el.data('text-right');
    var template = '';
    if (typeof text_right != 'undefined')
      template = template + '<span class="float-right text-muted">' + text_right + '</span>';
    if (typeof icon != 'undefined')
      template = template + '<i class="' + icon + '"></i> ';
    return template + '<span class="' + type_class + '">' + s.text + '</span>';
  }

  $('select.select2').select2({
    language: I18n.locale,
    templateResult: format_select2_option,
    templateSelection: format_select2_option,
    escapeMarkup: function (markup) { return markup; }
  });

  function format_service_select2_option(s) {
    if (!s.id)
      return s.text;
    var el = $(s.element);
    var type = el.data('type');
    var parent_service = el.data('parent');
    var type_class = el.data('class');
    var parent_service_type = el.data('parent-type');
    var template = '<span class="' + type_class + '"><span class="float-right text-muted">' + I18n.t('types.service_types.' + type + '.title') + '</span><i class="' + I18n.t('types.service_types.' + type + '.icon') + '"></i> ' + s.text;
    if (typeof parent_service != 'undefined')
      template = '<small class="text-muted"><i class="' + I18n.t('types.service_types.' + parent_service_type + '.icon') + '"></i> ' + parent_service + ' <i class="fa fa-fw fa-caret-right"></i></small> ' + template;
    return template + '</span>';
  }

  $('select.services-select2').select2({
    language: I18n.locale,
    templateResult: format_service_select2_option,
    templateSelection: format_service_select2_option,
    escapeMarkup: function (markup) { return markup; }
  });

});
