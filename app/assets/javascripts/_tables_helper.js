$(document).on('click', 'table.table-link > tbody > tr > td, table.table-link > tbody > tr > th', function(e) {
  e.preventDefault();
  var line = $(this).parent();
  var link = line.data('link');
  if (typeof link != 'undefined') {
    line.addClass('table-active');
    location.href = link;
  }
});