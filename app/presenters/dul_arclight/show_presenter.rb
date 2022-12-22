# frozen_string_literal: true

module DulArclight
  # Custom presentation methods for show partial
  class ShowPresenter < Arclight::ShowPresenter
    def heading
      values = [document.normalized_title]
      values << document.collection_name if document.level != 'collection'
      values << document.repository
      values.join(' - ')
    end
  end
end
