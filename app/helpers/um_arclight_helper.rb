# frozen_string_literal: true

# Helper methods specific to UM ArcLight
# ---------------------------------------
module UmArclightHelper
  # Render an html <title> appropriate string for a set of search parameters, based on local requirements
  # @param [ActionController::Parameters] params
  # @return [String]
  # adapated from https://github.com/projectblacklight/blacklight/blob/main/app/helpers/blacklight/catalog_helper_behavior.rb#L207
  def render_search_as_breadcrumbs_to_page_title(search_state_or_params) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    search_state = if search_state_or_params.is_a? Blacklight::SearchState
                     search_state_or_params
                   else
                     controller.search_state_class.new(params, blacklight_config, self)
                   end

    constraints = []
    suffixes = []
    prefix = t('blacklight.search.page_title.prefix')
    add_prefix = true

    if search_state.query_param.present?
      unless search_state.search_field&.key.blank? || default_search_field?(search_state.search_field.key)
        q_label = label_for_search_field(search_state.search_field.key)
      end

      constraints += if q_label.present?
                       [t('blacklight.search.page_title.constraint', label: q_label, value: search_state.query_param)]
                     else
                       [search_state.query_param]
                     end
    end

    if search_state.filters.any?
      repository = collection = nil
      has_level_collection = false

      search_state.filters.each do |filter|
        if filter.key == 'repository_sim'
          repository = filter.values.first
        elsif filter.key == 'collection_sim'
          collection = filter.values.first
        elsif filter.key == 'level_sim'
          has_level_collection = filter.values.first == 'Collection'
        else
          constraints << render_search_to_page_title_filter(filter.key, filter.values)
        end
      end
      suffixes << repository unless repository.nil?
      if collection.nil?
        suffixes.unshift 'Collections' if has_level_collection && suffixes.present?
      else
        suffixes.unshift collection
        add_prefix = constraints.present?
      end
    end

    title = []
    title += [constraints.join(' / ')] unless constraints.empty?
    unless suffixes.empty?
      title << '-' unless title.empty?
      title << suffixes.join(' - ')
    end
    title.unshift prefix if add_prefix
    _title = title.join(' ')
  end

  SKIPPABLE_KEYS = ['containers', 'physdesc_tesim', 'creators_ssim', 'abstract_tesim', 'scopecontent_tesim']
  def is_interesting_component?(document)
    (blacklight_config.component_fields.keys.find do |key|
      (SKIPPABLE_KEYS.exclude?(key) && document.fetch(key, nil).present?)
    end) || document.is_linkable?
  end
end
