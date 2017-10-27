var main_container_div = $('div#main_container');
var main_content_div = $('div#main_content');
var main_content_first_header_div = main_container_div.find('div.b-io-content--header').first();
var config_min_height_overflow = 400;

var content_overflow_state = function() {
  var window_height = window.innerHeight;
  var main_container_offset = main_container_div.offset();
  var main_content_offset = main_content_div.offset();
  var overflow_height = window_height - main_container_offset.top;

  if (overflow_height > config_min_height_overflow) {
    var main_content_height = window_height - main_content_offset.top;

    main_container_div
      .css('height', overflow_height + 'px');

    main_content_div
      .css('height', main_content_height + 'px')
      .css('overflow', 'scroll')
      .css('overflow-x', 'auto');
  } else {

    main_container_div
      .css('height', 'auto');

    main_content_div
      .css('height', 'auto')
      .css('overflow', 'auto');
  }
};

$(document).ready(function() {

  if(window.activate_content_overflow) {

    main_content_div.on("scroll", function () {
      if (this.scrollTop > 0) {
        main_content_first_header_div.addClass('with-shadow');
      } else {
        main_content_first_header_div.removeClass('with-shadow');
      }
    });

    if (main_container_div.length > 0) {
      content_overflow_state();

      $(window).resize(content_overflow_state);
    }

  }
});