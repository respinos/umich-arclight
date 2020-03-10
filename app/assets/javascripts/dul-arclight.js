Blacklight.onLoad(function () {

  /* =================== */
  /* BOOTSTRAP PLUGINS   */
  /* =================== */

  /* Bootstrap popovers out-of-the-box don't work on async-loaded DOM */
  /* elements, e.g. contextual tree nav, thus we have to trigger them */
  /* this way. */

  var popOverSettings = {
      placement: 'right',
      container: 'body',
      html: true,
      trigger: 'hover',
      selector: '[data-toggle="popover"]',
      content: function () {
        return $(this).data('content');
      }
  }

  $('body').popover(popOverSettings);

  /* =================== */
  /* SEARCH BOX BEHAVIOR */
  /* =================== */

  /* Searching within a collection should not yield results */
  /* grouped by collection. */

  $('form.search-query-form').submit(() => {
    if ($('select#within_collection').val()) {
      $('input#group').remove();
    }
  });



  /* ================= */
  /* MASTHEAD BEHAVIOR */
  /* ================= */


  /* DUL masthead primary navigation menu toggle */
  $('a#full-menu-toggle').on('click',function(e) {

    e.preventDefault();

    $('#dul-masthead-region-megamenu').slideToggle();

    // toggle FA content
    var el  = $('a#full-menu-toggle span.nav-icon'); 
    el.html(el.html() == '<i class="fas fa-bars"></i>' ? '<i class="fas fa-times"></i>' : '<i class="fas fa-bars"></i>');
      
  });



  /* =========== */
  /* Context Nav */
  /* =========== */

  // Remove 'sr-only' class from context header
  $('#context h2').removeClass("sr-only");

});
