# frozen_string_literal: true

# Extends Blacklight's helpers to customize DUL ArcLight.
# Last checked for updates: v7.2.
# See:
# https://github.com/projectblacklight/blacklight/blob/v7.2.0/app/helpers/blacklight/blacklight_helper_behavior.rb
# ---------------------------------------
module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  ##
  # Get the page's HTML title (DUL Customization: strip html markup from page title)
  #
  # @return [String]
  #
  def render_page_title
    (sanitize(content_for(:page_title), tags: []) if content_for?(:page_title)) || sanitize(@page_title, tags: []) || application_name
  end
end
