# frozen_string_literal: true

##
# Helpers used for presenting debugging info in search results
# when parameter debug=true is present.
module DebugInfoHelper
  def display_debug_info?
    params.fetch(:debug, false) == 'true'
  end
end
