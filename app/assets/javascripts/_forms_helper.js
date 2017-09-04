$.fn.select2.defaults.set("theme", "bootstrap");


function matchStart (query, item) {
  var term = query.term;
  if (typeof term == 'undefined' || term == '')
    return item;
  var text = item.text;
  if (text.toUpperCase().indexOf(term.toUpperCase()) != -1) {
    return item;
  }
  var el = $(item.element);
  var description = el.data('description') || '';
  if (description.toUpperCase().indexOf(term.toUpperCase()) != -1) {
    return item;
  }
  var parent = el.data('parent') || '';
  if (parent.toUpperCase().indexOf(term.toUpperCase()) != -1) {
    return item;
  }
  return null;
}

function format_service_select2_option(s) {
  if (!s.id)
    return '<span class="text-muted">' + s.text + '</span>';
  var el = $(s.element);
  var type = el.data('type');
  var text_right = el.data('text-right');
  var parent_service = el.data('parent');
  var type_class = el.data('class');
  var description = el.data('description');
  var parent_service_type = el.data('parent-type');
  var template = '<span class="' + type_class + '"><span class="float-right">' + I18n.t('types.service_types.' + type + '.title') + text_right + '</span><i class="' + I18n.t('types.service_types.' + type + '.icon') + '"></i> ' + s.text;
  if (typeof parent_service != 'undefined')
    template = '<span class="text-muted"><i class="' + I18n.t('types.service_types.' + parent_service_type + '.icon') + '"></i> ' + parent_service + ' <i class="fa fa-fw fa-caret-right"></i></span> ' + template;
  template = template + '</span>';
  if (typeof description != 'undefined')
    template = template + '<br /><small>' + description + '</small>';
  return template;
}

function format_service_select2_selection(s) {
  if (!s.id)
    return '<span class="text-muted">' + s.text + '</span>';
  var el = $(s.element);
  var type = el.data('type');
  var text_right = el.data('text-right');
  var parent_service = el.data('parent');
  var type_class = el.data('class');
  var parent_service_type = el.data('parent-type');
  var template = '<span class="' + type_class + '"><span class="float-right">' + I18n.t('types.service_types.' + type + '.title') + text_right + '</span><i class="' + I18n.t('types.service_types.' + type + '.icon') + '"></i> ' + s.text;
  if (typeof parent_service != 'undefined')
    template = '<span class="text-muted"><i class="' + I18n.t('types.service_types.' + parent_service_type + '.icon') + '"></i> ' + parent_service + ' <i class="fa fa-fw fa-caret-right"></i></span> ' + template;
  template = template + '</span>';
  return template;
}

function format_select2_result(s) {
  if (!s.id)
    return s.text;
  var el = $(s.element);
  var icon = el.data('icon');
  var type_class = el.data('class');
  var depth = el.data('depth');
  var text_right = el.data('text-right');
  var description = el.data('description');
  var template = '';
  if (typeof text_right != 'undefined')
    template = template + '<span class="float-right text-muted">' + text_right + '</span>';
  if (typeof depth != 'undefined' && depth != '0')
    var i = parseInt(depth);
  while (i-- >= 0)
    template = template + '&nbsp;';
  if (typeof icon != 'undefined')
    template = template + '<i class="' + icon + '"></i> ';
  template = template + '<span class="' + type_class + '">' + s.text + '</span>';
  if (typeof description != 'undefined')
    template = template + '<br /><small>' + description + '</small>';
  return template;
}

function format_select2_selection(s) {
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
  template = template + '<span class="' + type_class + '">' + s.text + '</span>';
  return template;
}

window.apply_select2 = function(input) {
  input.select2({
    language: I18n.locale,
    templateResult: format_select2_result,
    templateSelection: format_select2_selection,
    minimumResultsForSearch: 5,
    escapeMarkup: function (markup) { return markup; },
    matcher: matchStart
  });
};

window.activate_select2 = function() {
  $('select.select2').each(function() {
    window.apply_select2($(this));
  });
};

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

  window.activate_select2();

  $('select.services-select2').select2({
    language: I18n.locale,
    templateResult: format_service_select2_option,
    templateSelection: format_service_select2_selection,
    minimumResultsForSearch: 5,
    escapeMarkup: function (markup) { return markup; },
    matcher: matchStart
  });

  $(document).on("focus", ".date-picker", function(e) {
    $(this).datepicker({
      format: "yyyy-mm-dd",
      weekStart: 1,
      autoclose: true,
      language: I18n.locale
    });
  });

  $.extend($.fn.autoNumeric.defaults, {
    digitGroupSeparator: ' ',
    decimalCharacter: '.',
    currencySymbol: ' €',
    currencySymbolPlacement: 's',
    unformatOnSubmit: true
  });

  $('input.autonumeric').autoNumeric('init');

  $('input.intl-tel-input').each(function() {
    var input = $(this),
      hidden_input = input.data('hidden-input');

    input.intlTelInput({
      utilsScript: "/assets/javascripts/google-utils.js",
      separateDialCode: true,
      initialCountry: 'auto',
      hiddenInput: hidden_input,
      geoIpLookup: function (callback) {
        $.get("https://ipinfo.io", function () {
        }, "jsonp").always(function (resp) {
          var countryCode = (resp && resp.country) ? resp.country : "";
          callback(countryCode);
        });
      }
    });
  });

});
