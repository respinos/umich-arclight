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

  updatAllText = function() {
    $('.responsiveTruncatorToggle').text("show more").append(" <i class='fas fa-chevron-circle-down'></i>").wrapInner("<span class='btn-wrapper'></span>");
    $('.responsiveTruncatorToggle').addClass('showing-less');
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
  updatAllText();

  // click button
  $('.responsiveTruncatorToggle').click(function() {
    $this = this;
    toggleExpanded($this);
    toggleText($this);
  });
  
  $(window).bind("resize", function() {

    $('.responsiveTruncatorToggle').parent('.card-text').removeClass('expanded');
    
    updatAllText();

    // need to do this again after binding resize?
    $('.responsiveTruncatorToggle').click(function() {
      $this = this;
      toggleExpanded($this);
      toggleText($this);
    });

  });

});
