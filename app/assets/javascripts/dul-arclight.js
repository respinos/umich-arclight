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
  $('body').tooltip({
    selector: '[data-toggle="tooltip"]'
  });

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


  /* ============== */
  /* Search Results */
  /* ============== */

  // Remove 'sr-only' class from applied search params label
  $('#appliedParams span.constraints-label').removeClass("sr-only");
  

  /* =========== */
  /* Context Nav */
  /* =========== */

  // Remove 'sr-only' class from context header
  $('#context h2').removeClass("sr-only");



  /* ======++++++++++++++===== */
  /* Augment truncation toggle */
  /* =====++++++++++++++====== */

  var $pathsToTarget = '';
  $pathsToTarget += '#documents .responsiveTruncatorToggle';
  $pathsToTarget += ', ';
  $pathsToTarget += '#results-nav-and-constraints .responsiveTruncatorToggle';
  $pathsToTarget += ', ';
  $pathsToTarget += '#content .al-grouped-results .responsiveTruncatorToggle';

  updateAllTruncatedText = function() {
    $( $pathsToTarget ).text("show more").append(" <i class='fas fa-chevron-circle-down'></i>").wrapInner("<span class='btn-wrapper'></span>");
    $( $pathsToTarget ).addClass('showing-less');
  }

  toggleExpanded = function() {
    if ( $($this).parent('.card-text').hasClass('expanded') ) {
      $($this).parent('.card-text').removeClass('expanded');
    } else {
      $($this).parent('.card-text').addClass('expanded');
    }
  }

  toggleText = function() {
    if ($($this).hasClass('showing-less')) {
      $($this).removeClass('showing-less').addClass('showing-more');
      $($this).text("show less").append(" <i class='fas fa-chevron-circle-up'></i>").wrapInner("<span class='btn-wrapper'></span>");
    } else {
      $($this).removeClass('showing-more').addClass('showing-less');
      $($this).text("show more").append(" <i class='fas fa-chevron-circle-down'></i>").wrapInner("<span class='btn-wrapper'></span>");
    }
  }

  // initial page load
  updateAllTruncatedText();

  // click collection or card button
  $( $pathsToTarget ).click(function() {
    $this = this;
    toggleExpanded($this);
    toggleText($this);
  });
  
  $(window).bind("resize", function() {

    $('.responsiveTruncatorToggle').parent('.card-text').removeClass('expanded');
    
    updateAllTruncatedText();

    // need to do this again after binding resize?
    $('.responsiveTruncatorToggle').click(function() {
      $this = this;
      toggleExpanded($this);
      toggleText($this);
    });

  });


  // account for dynamically loaded content
  if ($("body").hasClass("blacklight-catalog-show")) {

    // wait for document placeholder content to go away
    var checkExistDocument = setInterval(function() {

      var placeholderPath = $("#document .al-hierarchy-placeholder").html();

      if (undefined === placeholderPath) {
          updateAllTruncatedText();

          // click series button
          $( "#document #documents .responsiveTruncatorToggle" ).on( "click", function() {
            $this = this;
            toggleExpanded($this);
            toggleText($this);
          });

          $(window).bind("resize", function() {
            updateAllTruncatedText();

            // need to do this again after binding resize?
            $( "#document #documents .responsiveTruncatorToggle" ).on( "click", function() {
              $this = this;
              toggleExpanded($this);
              toggleText($this);
            });

          });

          clearInterval(checkExistDocument);
      } 
    }, 100);

  }



  /* ======================================== */
  /* Hide sidebar header && document children */
  /* ======================================== */
  
  if ($("body").hasClass("blacklight-catalog-show")) {
    
    // wait for collection placeholder content to go away
    var checkExistCollection = setInterval(function() {

      var placeholderPath = $("#collection-context .al-hierarchy-placeholder").html();
      var navPath = $("#collection-context .context-navigator .al-context-nav-parent").html();

      if (undefined === placeholderPath) {
          if (navPath.length == 0) {
            $("#context hr").fadeOut();
            $("#context .tab-content .tab-pane h2").fadeOut();
          }
          clearInterval(checkExistCollection);
      } 
    }, 100);
  }

});
