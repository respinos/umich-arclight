# frozen_string_literal: true

##
# Helpers used for the DUL-Arclight homepage
module HomepageHelper
  def config_features
    @config ||= begin
                  YAML.safe_load(::File.read(config_filename))
                rescue Errno::ENOENT
                  {}
                end
  end

  def config_filename
    Rails.root.join('config', 'featured_images.yml')
  end

  def random_feature
    img_index = config_features['image_list'].keys.sample
    config_features['image_list'][img_index]
  end

  def collection_count
    search_service = Blacklight.repository_class.new(blacklight_config)
    @response = search_service.search(
      q: "level_sim:Collection",
      rows: 1
    )
    @response.response['numFound']
  end
end
