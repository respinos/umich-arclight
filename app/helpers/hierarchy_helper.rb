# NOTE: This helper overrides some methods that are part of the Blacklight Hierarchy gem
# (blacklight-hierarchy). So it is potentially unstable and should be inspected carefully
# whenever that gem is updated.

# Last checked for updates: blacklight_hierarchy_helper gem v4.0.0.
# See:
# https://github.com/sul-dlss/blacklight-hierarchy/blob/master/app/helpers/blacklight/hierarchy_helper.rb
#
module HierarchyHelper
  include Blacklight::HierarchyHelper
  # NOTE: This helper overrides some methods that are part of the
  #       Blacklight hierarchy gem.

  # Identical to Blacklight::HierarchyHelper method
  def render_qfacet_value(facet_solr_field, item, options = {})
    (link_to_unless(options[:suppress_link],
                    q_value(facet_solr_field, item),
                    q_facet_params(facet_solr_field, item),
                    class: 'facet_select') + ' ' + render_facet_count(item.hits)).html_safe
  end

  # DUL CUSTOMIZATION: This method has been overridden from Blacklight::HierarchyHelper in
  # order to map the facet value to a text label.
  def q_value(facet_solr_field, item)
    if facet_solr_field.to_s == 'ua_record_group_ssim'
      map_ua_record_group_codes(item)
    else
      item.value
    end
  end

  # Identical to Blacklight::HierarchyHelper method
  def q_facet_params(facet_solr_field, item)
    search_state.add_facet_params(facet_solr_field, item.qvalue).to_h
  end

  # Map the UA record group codes to display their titles instead - this only works in the
  # facet, not the selection history. See field_config_helpers.rb for the facet selection history.
  def map_ua_record_group_codes(item)
    group_keys = item.qvalue.split(':')
    label = group_keys.count > 1 ? subgroup_label(group_keys) : group_label(group_keys)
    [item.value, label].join(' &mdash; ').html_safe
  end

  def subgroup_label(group_keys)
    UA_RECORD_GROUPS.dig(group_keys[0], 'subgroups', group_keys[1], 'title') || 'Unknown'
  end

  def group_label(group_keys)
    UA_RECORD_GROUPS.dig(group_keys[0], 'title') || 'Unknown'
  end
end
