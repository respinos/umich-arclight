# frozen_string_literal: true

module DulArclight
  # Custom presentation methods for show partial
  class ShowPresenter < Arclight::ShowPresenter
    def heading
      values = [document.normalized_title]
      if document.level != 'collection'
        values << document.collection_name
      end
      values << document.repository
      values.join(" - ")
    end
  end
end
