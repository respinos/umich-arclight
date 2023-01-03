# frozen_string_literal: true

# Controller for our /help page
class HelpController < ApplicationController
  def help
    render "arclight/help"
  end

end
