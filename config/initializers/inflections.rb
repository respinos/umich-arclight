# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

# DUL CUSTOMIZATION: account for inflections that ActiveSupport misses,
# e.g., 1 linear feet; 1.0 Cubic Feet; 1 film feet, etc...
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.singular(/^(.+) feet/, '\1 foot')
  inflect.singular(/^(.+) Feet/, '\1 Foot')
  inflect.irregular 'leaf', 'leaves'
  inflect.irregular 'Leaf', 'Leaves'
  inflect.uncountable %w[VHS]
end
