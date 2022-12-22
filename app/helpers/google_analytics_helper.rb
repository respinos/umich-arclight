# frozen_string_literal: true

# Helpers for sending data to GA, especially custom
# dimensions for tracking by page type and collection slug
module GoogleAnalyticsHelper
  # Google Analytics Custom Dimensions.
  # These are logged with every pageview and custom Event. They are
  # selectable as dimensions in Analytics reports alongside standard
  # fields tracked by Google.
  # https://developers.google.com/analytics/devguides/collection/gtagjs/setting-values

  def delimit(coll_or_colls)
    ":#{Array(coll_or_colls).join(':')}:"
  end

  def ga_user_properties
    {
      collection_id: delimit(ga_collection_id),
      page_type: ga_page_type,
      repository_id: delimit(ga_repository_id)
    }.reject { |_key, value| value.blank? || value == '::' }
      .to_json.html_safe
  end

  def ga_collection_id
    # within_collection_context? doesn't quite help b/c we can't get the slug
    # out of a within-collection search, just the title
    @document&.eadid
  end

  def ga_repository_id
    if params[:f].present? && params[:f]['repository_sim'].present?
      repository_config = Arclight::Repository.find_by(name: params[:f]['repository_sim'].first)
      return repository_config.slug
    end
    @document&.repository_config&.slug
  end

  def ga_page_type
    if search_results_page_zero_results?
      'No Results Page'
    elsif search_results_page_with_results?
      'Search Results Page'
    elsif home_page?
      'Homepage'
    elsif collection_show_page?
      'Collection Page'
    elsif component_show_page?
      'Component Page'
    elsif bookmarks_page?
      'Bookmarks Page'
    elsif ua_record_groups_page?
      'UA Record Groups Page'
    else
      'Other Page'
    end
  end

  private

  def search_results_page_with_results?
    search_results_page? && response_has_results?
  end

  def search_results_page_zero_results?
    search_results_page? && !response_has_results?
  end

  def home_page?
    catalog_controller? && controller.action_name == 'index' \
      && respond_to?(:has_search_parameters?) && !has_search_parameters?
  end

  def collection_show_page?
    catalog_controller? && controller.action_name == 'show' \
      && @document&.level == 'collection'
  end

  def component_show_page?
    catalog_controller? && controller.action_name == 'show' \
      && @document&.level != 'collection'
  end

  def search_results_page?
    catalog_controller? && controller.action_name == 'index' \
      && respond_to?(:has_search_parameters?) && has_search_parameters?
  end

  def ua_record_groups_page?
    controller.controller_name == 'ua_record_groups'
  end

  def bookmarks_page?
    controller.controller_name == 'bookmarks'
  end

  def catalog_controller?
    controller.controller_name == 'catalog'
  end

  def response_has_results?
    @response.present? && @response.respond_to?(:total) \
      && @response.total.positive?
  end
end
