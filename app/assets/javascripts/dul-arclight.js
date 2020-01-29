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
});
