# frozen_string_literal: true

# Extends Blacklight's layout helpers to
# customize DUL ArcLight. See:
# https://github.com/projectblacklight/blacklight/blob/master/app/helpers/blacklight/layout_helper_behavior.rb
# ---------------------------------------
module BlacklightLayoutHelper
  include Blacklight::LayoutHelperBehavior
  ##
  # Classes used for sizing the main content of a Blacklight page
  # @return [String]
  def show_content_classes
    'show-document col-md-7 col-lg-8 order-md-2'
  end

  ##
  # Classes used for sizing the sidebar content of a Blacklight page
  # @return [String]
  def show_sidebar_classes
    'page-sidebar col-md-5 col-lg-4 order-md-1'
  end
end
