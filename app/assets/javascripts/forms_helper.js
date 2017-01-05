$(document).ready(function(e) {

  $('a[data-toggle="tab"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

});
