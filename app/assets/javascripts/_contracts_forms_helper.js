$(document).ready(function(e) {

  var select_startup_id_catalog = $('#select_startup_id_catalog');

  select_startup_id_catalog.on('change', function() {
    var selector = $(this);
    var url = selector.data('url');
    var value = selector.val();

    window.location = url + '?startup_id=' + value;
  });

});

