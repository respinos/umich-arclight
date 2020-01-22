Blacklight.onLoad(function () {
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
