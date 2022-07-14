# frozen_string_literal: true

# Copy of ArcLight Core Traject indexing config for DUL customizations
# Last checked for updates: ArcLight v0.3.3.
# https://github.com/projectblacklight/arclight/blob/master/lib/arclight/traject/ead2_config.rb

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'
require 'arclight/exceptions'
require 'arclight/level_label'
# DUL Customization: use custom normalized date
require_relative '../normalized_date'
# UM Customization: use custom normalized title
require_relative '../normalized_title'
require 'active_model/conversion' ## Needed for Arclight::Repository
require 'active_support/core_ext/array/wrap'
# DUL Customization: use custom digital object model
require_relative '../digital_object'
require 'arclight/year_range'
require 'arclight/repository'
require 'arclight/missing_id_strategy'

# DUL Customization: extend the ArcLight core namespaceless
# Nokogiri reader so it also squishes consecutive spaces / newline
# characters. See DulArclight::Traject::DulCompressedReader
require_relative 'dul_compressed_reader'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage
#

NAME_ELEMENTS = %w[corpname famname name persname].freeze

# DUL CUSTOMIZATION: separate out restrictions <accessrestrict> <userestrict> <phystech> from
# other searchable notes, in order to revise inheritance rules during indexing.
SEARCHABLE_NOTES_FIELDS = %w[
  accruals
  altformavail
  appraisal
  arrangement
  bibliography
  bioghist
  custodhist
  fileplan
  note
  odd
  originalsloc
  otherfindaid
  prefercite
  processinfo
  relatedmaterial
  scopecontent
  separatedmaterial
].freeze

DID_SEARCHABLE_NOTES_FIELDS = %w[
  abstract
  materialspec
  physloc
].freeze

# DUL CUSTOMIZATION: separated from SEARCHABLE_NOTES for more
# refined indexing
RESTRICTION_FIELDS = %w[
  accessrestrict
  userestrict
  phystech
].freeze

settings do
  # DUL Customization: Swap out Arclight::Traject::NokogiriNamespacelessReader with
  # custom DulCompressedReader to remove namespaces AND squish unwanted whitespace.
  provide 'reader_class_name', 'DulArclight::Traject::DulCompressedReader'
  provide 'solr_writer.commit_on_close', 'true'
  provide 'repository', ENV['REPOSITORY_ID']
  provide 'logger', Logger.new($stderr)
end

each_record do |_record, context|
  next unless settings['repository']

  context.clipboard[:repository] = Arclight::Repository.find_by(
    slug: settings['repository']
  ).name
end

# ==================
# Top level document
# ==================

to_field 'id', extract_xpath('/ead/eadheader/eadid'), strip, gsub('.', '-')
# to get the filename for Aeon for SCRC and Clements
to_field 'publicid_ssi', extract_xpath('/ead/eadheader/eadid/@publicid')

# DUL CUSTOMIZATION: add high component position to collection so the collection record
# appears after all components. Default was nil, which sorted between first [0] & second [1] component.
#to_field 'sort_ii' do |_record, accumulator|
  #accumulator << '999999'
#end

# DUL CUSTOMIZATION: Permalink & ARK. NOTE the ARK will be derived from the
# permalink, and not the other way around; ARK is not stored atomically in the EAD.
# Strip out any wayward spaces or linebreaks that might end up in the url attribute
# and only capture the value if it's a real permalink (with an ARK).
#to_field 'permalink_ssi' do |record, accumulator|
  #url = record.at_xpath('/ead/eadheader/eadid').attribute('url')&.value
  #url.gsub(/[[:space:]]/, '')
  #accumulator << url if url.include?('ark:')
#end

#to_field 'ark_ssi' do |_record, accumulator, context|
  #next unless context.output_hash['permalink_ssi']

  #permalink = context.output_hash['permalink_ssi'].first
  #path = URI(permalink).path&.delete_prefix!('/')
  #accumulator << path
#end

to_field 'title_filing_si', extract_xpath('/ead/eadheader/filedesc/titlestmt/titleproper[@type="filing"]')
to_field 'title_ssm' do |record, accumulator|
  result = record.xpath('/ead/archdesc/did/unittitle')
  result = result.collect do |n|
    if n.kind_of?(Nokogiri::XML::Attr)
      # attribute value
      n.value
    else
      # text from node
      n.xpath('.//text()[not(ancestor-or-self::unitdate)]').collect(&:text).tap do |arr|
        arr.reject! { |s| s =~ (/\A\s+\z/) }
      end.join(" ")
    end
  end
  accumulator.concat result
end
to_field 'title_formatted_ssm' do |record, accumulator|
  whole_title = record.xpath('/ead/archdesc/did/unittitle').to_a
  no_dates = whole_title.select { |elem| elem.to_s !~ /unitdate/ }
  accumulator.concat no_dates
end
to_field 'title_teim', extract_xpath('/ead/archdesc/did/unittitle')
to_field 'ead_ssi', extract_xpath('/ead/eadheader/eadid')

to_field 'unitdate_ssm', extract_xpath('/ead/archdesc/did/unitdate|/ead/archdesc/did/unittitle/unitdate')
to_field 'unitdate_bulk_ssim', extract_xpath('/ead/archdesc/did/unitdate[@type="bulk"]|/ead/archdesc/did/unittitle/unitdate[@type="bulk"]')
to_field 'unitdate_inclusive_ssm', extract_xpath('/ead/archdesc/did/unitdate[@type="inclusive"]|/ead/archdesc/did/unittitle/unitdate[@type="inclusive"]')
to_field 'unitdate_other_ssim', extract_xpath('/ead/archdesc/did/unitdate[not(@type)]|/ead/archdesc/did/unittitle/unitdate[not(@type)]')

# Aleph ID (esp. for request integration)
to_field 'bibnum_ssim', extract_xpath('/ead/eadheader/filedesc/notestmt/note/p/num[@type="aleph"]')

# All top-level docs treated as 'collection' for routing / display purposes
to_field 'level_ssm' do |_record, accumulator|
  accumulator << 'collection'
end

# Keep the original top-level archdesc/@level for Level facet in addition to 'Collection'
to_field 'level_sim' do |record, accumulator|
  level = record.at_xpath('/ead/archdesc').attribute('level')&.value
  other_level = record.at_xpath('/ead/archdesc').attribute('otherlevel')&.value

  accumulator << Arclight::LevelLabel.new(level, other_level).to_s
  accumulator << 'Collection' unless level == 'collection'
end

to_field 'unitid_ssm', extract_xpath('/ead/archdesc/did/unitid')
to_field 'unitid_teim', extract_xpath('/ead/archdesc/did/unitid')
to_field 'collection_unitid_ssm', extract_xpath('/ead/archdesc/did/unitid')

# DUL CUSTOMIZATION: UA Record Groups
to_field 'ua_record_group_ssim' do |_record, accumulator, context|
  unitid = context.output_hash['collection_unitid_ssm']
  id = if unitid then unitid.first.split('.') else [''] end
  if id[0] == 'UA'
    group = id[1]
    subgroup = id[2]
    accumulator << group
    accumulator << [group, subgroup].join(':')
  end
end

# DUL CUSTOMIZATION: use DUL rules for NormalizedDate
to_field 'normalized_date_ssm' do |_record, accumulator, context|
  accumulator << DulArclight::NormalizedDate.new(
    context.output_hash['unitdate_inclusive_ssm'],
    context.output_hash['unitdate_bulk_ssim'],
    context.output_hash['unitdate_other_ssim']
  ).to_s
end

# DUL CUSTOMIZATION: use DUL rules for NormalizedDate in title normalization
to_field 'normalized_title_ssm' do |_record, accumulator, context|
  dates = context.output_hash['normalized_date_ssm']&.first
  title = context.output_hash['title_ssm']&.first
  accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
end

# DUL CUSTOMIZATION: preserve formatting tags in titles
to_field 'normalized_title_formatted_ssm' do |_record, accumulator, context|
  dates = context.output_hash['normalized_date_ssm']&.first
  title = context.output_hash['title_formatted_ssm']&.first.to_s
  accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
end

to_field 'collection_ssm' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end
to_field 'collection_sim' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end
to_field 'collection_ssi' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end
to_field 'collection_title_tesim' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', [])
end

to_field 'repository_ssm' do |_record, accumulator, context|
  accumulator << context.clipboard[:repository]
end

to_field 'repository_sim' do |_record, accumulator, context|
  accumulator << context.clipboard[:repository]
end

to_field 'creator_ssm', extract_xpath('/ead/archdesc/did/origination')
to_field 'creator_sim', extract_xpath('/ead/archdesc/did/origination')
to_field 'creator_ssim', extract_xpath('/ead/archdesc/did/origination')
to_field 'creator_sort' do |record, accumulator|
  accumulator << record.xpath('/ead/archdesc/did/origination').map { |c| c.text.strip }.join(', ')
end

to_field 'creator_persname_ssm', extract_xpath('/ead/archdesc/did/origination/persname'), strip
to_field 'creator_persname_ssim', extract_xpath('/ead/archdesc/did/origination/persname'), strip
to_field 'creator_corpname_ssm', extract_xpath('/ead/archdesc/did/origination/corpname'), strip
to_field 'creator_corpname_sim', extract_xpath('/ead/archdesc/did/origination/corpname'), strip
to_field 'creator_corpname_ssim', extract_xpath('/ead/archdesc/did/origination/corpname'), strip
to_field 'creator_famname_ssm', extract_xpath('/ead/archdesc/did/origination/famname')
to_field 'creator_famname_ssim', extract_xpath('/ead/archdesc/did/origination/famname')

to_field 'creators_ssim' do |_record, accumulator, context|
  accumulator.concat context.output_hash['creator_persname_ssm'] if context.output_hash['creator_persname_ssm']
  accumulator.concat context.output_hash['creator_corpname_ssm'] if context.output_hash['creator_corpname_ssm']
  accumulator.concat context.output_hash['creator_famname_ssm'] if context.output_hash['creator_famname_ssm']
end

to_field 'places_sim', extract_xpath('/ead/archdesc/controlaccess/geogname|/ead/archdesc/controlaccess/controlaccess/geogname')
to_field 'places_ssim', extract_xpath('/ead/archdesc/controlaccess/geogname|/ead/archdesc/controlaccess/controlaccess/geogname')
to_field 'places_ssm', extract_xpath('/ead/archdesc/controlaccess/geogname|/ead/archdesc/controlaccess/controlaccess/geogname')

to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/acqinfo/*[local-name()!="head"]')
to_field 'acqinfo_ssim', extract_xpath('/ead/archdesc/descgrp/acqinfo/*[local-name()!="head"]')

to_field 'access_subjects_ssim', extract_xpath('/ead/archdesc/controlaccess', to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    # DUL CUSTOMIZATION: pull out genreform into its own field
    %w[subject function occupation].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
end

to_field 'access_subjects_ssm' do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash['access_subjects_ssim'])
end

# DUL CUSTOMIZATION: capture formats (genreform) field separately from subjects
to_field 'formats_ssim', extract_xpath('/ead/archdesc/controlaccess/genreform|/ead/archdesc/controlaccess/controlaccess/genreform')
to_field 'formats_ssm' do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash['formats_ssim'])
end

# DUL CUSTOMIZATION: omit electronic-record-* DAOs so they don't count as online access
to_field 'has_online_content_ssim', extract_xpath('.//dao[not(starts-with(@role,"electronic-record"))]') do |_record, accumulator|
  accumulator.replace([accumulator.any?])
end

# DUL CUSTOMIZATION: count all DAOs from the top-level down; omit the electronic-record-*
# ones.
to_field 'total_digital_object_count_isim' do |record, accumulator|
  accumulator << record.xpath('.//dao[not(starts-with(@role,"electronic-record"))]').count
end

# DUL CUSTOMIZATION: get all unique DAO roles present anywhere in this collection
to_field 'all_dao_roles_ssim' do |record, accumulator|
  accumulator.concat record.xpath('.//dao/@role')
  accumulator.uniq!(&:text)
end

# DUL CUSTOMIZATION: capture the DAO @role & @xpointer attributes
to_field 'digital_objects_ssm', extract_xpath('/ead/archdesc/did/dao|/ead/archdesc/dao', to_text: false) do |_record, accumulator|
  accumulator.map! do |dao|
    label = dao.attributes['title']&.value ||
            dao.attributes['xlink:title']&.value ||
            dao.xpath('daodesc/p')&.text
    href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
    role = (dao.attributes['role'] || dao.attributes['xlink:role'])&.value
    xpointer = (dao.attributes['xpointer'] || dao.attributes['xlink:xpointer'])&.value
    DulArclight::DigitalObject.new(label: label, href: href, role: role, xpointer: xpointer).to_json
  end
end

to_field 'extent_ssm', extract_xpath('/ead/archdesc/did/physdesc/extent')
to_field 'extent_teim', extract_xpath('/ead/archdesc/did/physdesc/extent')

# DUL CUSTOMIZATION: Capture text in physical description; separate values for text directly
# in physdesc vs. in individual child elements e.g., <extent>, <dimensions>, or <physfacet>
to_field 'physdesc_tesim', extract_xpath('/ead/archdesc/did/physdesc/child::*')
to_field 'physdesc_tesim', extract_xpath('/ead/archdesc/did/physdesc[not(child::*)]')

to_field 'date_range_sim', extract_xpath('/ead/archdesc/did/unitdate/@normal|/ead/archdesc/did/unittitle/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end

to_field 'date_range_sim', extract_xpath('/ead/archdesc/did/unittitle/unitdate') do |record, accumulator|
  range = Arclight::YearRange.new(record.include?('/') ? record : record.map { |v| v.tr('-', '/') })
  accumulator << range.to_s
end


SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']", to_text: false)
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/descgrp/#{selector}/*[local-name()!='head']", to_text: false)
  to_field "#{selector}_heading_ssm", extract_xpath("/ead/archdesc/#{selector}/head") unless selector == 'prefercite'
  to_field "#{selector}_heading_ssm", extract_xpath("/ead/archdesc/descgrp/#{selector}/head") unless selector == 'prefercite'
  to_field "#{selector}_teim", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']")
  to_field "#{selector}_teim", extract_xpath("/ead/archdesc/descgrp/#{selector}/*[local-name()!='head']")
end

DID_SEARCHABLE_NOTES_FIELDS.map do |selector|
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/did/#{selector}", to_text: false)
  to_field "#{selector}_teim", extract_xpath("/ead/archdesc/did/#{selector}/*[local-name()!='head']")
end

# DUL CUSTOMIZATION
RESTRICTION_FIELDS.map do |selector|
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']", to_text: false)
  to_field "#{selector}_tesim", extract_xpath("/ead/archdesc/descgrp/#{selector}/*[local-name()!='head']", to_text: false)
  to_field "#{selector}_heading_ssm", extract_xpath("/ead/archdesc/#{selector}/head")
  to_field "#{selector}_heading_ssm", extract_xpath("/ead/archdesc/descgrp/#{selector}/head")
  to_field "#{selector}_teim", extract_xpath("/ead/archdesc/#{selector}/*[local-name()!='head']")
  to_field "#{selector}_teim", extract_xpath("/ead/archdesc/descgrp/#{selector}/*[local-name()!='head']")
end

NAME_ELEMENTS.map do |selector|
  to_field 'names_coll_ssim', extract_xpath("/ead/archdesc/controlaccess/#{selector}|/ead/archdesc/controlaccess/controlaccess/#{selector}"), unique, strip
  to_field 'names_ssim', extract_xpath("//#{selector}"), strip
  to_field "#{selector}_ssm", extract_xpath("//#{selector}"), strip
end

# DUL CUSTOMIZATION: separate language vs langmaterial fields that don't have language
# Probably just a DUL modification; mix of conventions in use in our data
to_field 'language_ssm', extract_xpath('/ead/archdesc/did/langmaterial/language')
to_field 'langmaterial_ssm', extract_xpath('/ead/archdesc/did/langmaterial[not(descendant::language)]')

to_field 'descrules_ssm', extract_xpath('/ead/eadheader/profiledesc/descrules')

# DUL CUSTOMIZATION: add index
to_field 'indexes_tesim', extract_xpath('/ead/archdesc/index', to_text: false)

# DUL CUSTOMIZATION: count the child components from the top-level
to_field 'child_component_count_isim' do |record, accumulator|
  accumulator << record.xpath('/ead/archdesc/dsc/*[is_component(.)]', NokogiriXpathExtensions.new).count
end

# DUL CUSTOMIZATION: count all descendant components from the top-level
to_field 'total_component_count_isim' do |record, accumulator|
  accumulator << record.xpath('/ead/archdesc/dsc//*[is_component(.)]', NokogiriXpathExtensions.new).count
end

# =============================
# Each component child document
# <c> <c01> <c12>
# =============================

# rubocop:disable Metrics/BlockLength
compose 'components', ->(record, accumulator, _context) { accumulator.concat record.xpath('//*[is_component(.)]', NokogiriXpathExtensions.new) } do
  to_field 'publicid_ssi' do |record, accumulator, context|
    accumulator << if record.attribute('publicid_ssi').blank?
                     context.clipboard[:parent].output_hash['publicid_ssi']
                   else
                     record.attribute('publicid_ssi')
                   end
  end
  to_field 'ref_ssi' do |record, accumulator, context|
    accumulator << if record.attribute('id').blank?
                     strategy = Arclight::MissingIdStrategy.selected
                     hexdigest = strategy.new(record).to_hexdigest
                     parent_id = context.clipboard[:parent].output_hash['id'].first
                     # logger.debug('MISSING ID WARNING') do
                     #   [
                     #     "A component in #{parent_id} did not have an ID so one was minted using the #{strategy} strategy.",
                     #     "The ID of this document will be #{parent_id}#{hexdigest}."
                     #   ].join(' ')
                     # end
                     record['id'] = hexdigest
                     hexdigest
                   else
                     record.attribute('id')&.value&.strip&.gsub('.', '-')
                   end
  end
  to_field 'ref_ssm' do |_record, accumulator, context|
    accumulator.concat context.output_hash['ref_ssi']
  end

  # DUL CUSTOMIZATION: separate parent/child ids with an
  # underscore, especially for cleaner component URLs.
  to_field 'id' do |_record, accumulator, context|
    accumulator << [
      context.clipboard[:parent].output_hash['id'],
      context.output_hash['ref_ssi']
    ].join('_')
  end

  to_field 'ead_ssi' do |_record, accumulator, context|
    accumulator << context.clipboard[:parent].output_hash['ead_ssi'].first
  end

  to_field 'title_filing_si', extract_xpath('./did/unittitle'), first_only
  to_field 'title_ssm', extract_xpath('./did/unittitle')
  to_field 'title_formatted_ssm', extract_xpath('./did/unittitle', to_text: false)
  to_field 'title_teim', extract_xpath('./did/unittitle')

  to_field 'unitdate_bulk_ssim', extract_xpath('./did/unitdate[@type="bulk"]')
  to_field 'unitdate_inclusive_ssm', extract_xpath('./did/unitdate[@type="inclusive"]')
  to_field 'unitdate_other_ssim', extract_xpath('./did/unitdate[not(@type)]')

  # DUL CUSTOMIZATION: use DUL rules for NormalizedDate
  to_field 'normalized_date_ssm' do |_record, accumulator, context|
    accumulator << DulArclight::NormalizedDate.new(
      context.output_hash['unitdate_inclusive_ssm'],
      context.output_hash['unitdate_bulk_ssim'],
      context.output_hash['unitdate_other_ssim']
    ).to_s
  end

  # DUL CUSTOMIZATION: use DUL rules for NormalizedDate in title normalization
  to_field 'normalized_title_ssm' do |_record, accumulator, context|
    dates = context.output_hash['normalized_date_ssm']&.first
    title = context.output_hash['title_ssm']&.first
    accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
  end

  # DUL CUSTOMIZATION: use DUL rules for NormalizedDate
  to_field 'normalized_title_formatted_ssm' do |_record, accumulator, context|
    dates = context.output_hash['normalized_date_ssm']&.first
    title = context.output_hash['title_formatted_ssm']&.first.to_s
    accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
  end

  # Aleph ID (esp. for request integration)
  to_field 'bibnum_ssim', extract_xpath('/ead/eadheader/filedesc/notestmt/note/p/num[@type="aleph"]')

  to_field 'component_level_isim' do |record, accumulator|
    accumulator << 1 + NokogiriXpathExtensions.new.is_component(record.ancestors).count
  end

  to_field 'parent_ssim' do |record, accumulator, context|
    accumulator << context.clipboard[:parent].output_hash['id'].first
    accumulator.concat NokogiriXpathExtensions.new.is_component(record.ancestors).reverse.map { |n| n.attribute('id')&.value }
  end

  to_field 'parent_ssi' do |_record, accumulator, context|
    accumulator << context.output_hash['parent_ssim'].last
  end

  to_field 'parent_unittitles_ssm' do |_rec, accumulator, context|
    # top level document
    accumulator.concat context.clipboard[:parent].output_hash['normalized_title_ssm']
    parent_ssim = context.output_hash['parent_ssim']
    components = context.clipboard[:parent].output_hash['components']

    # other components
    if parent_ssim && components
      ancestors = parent_ssim.drop(1).map { |x| [x] }
      accumulator.concat components.select { |c| ancestors.include? c['ref_ssi'] }.flat_map { |c| c['normalized_title_ssm'] }
    end
  end

  to_field 'parent_unittitles_teim' do |_record, accumulator, context|
    accumulator.concat context.output_hash['parent_unittitles_ssm']
  end

  to_field 'parent_levels_ssm' do |_record, accumulator, context|
    ## Top level document
    accumulator.concat context.clipboard[:parent].output_hash['level_ssm']
    ## Other components
    context.output_hash['parent_ssim']&.drop(1)&.each do |id|
      accumulator.concat Array
        .wrap(context.clipboard[:parent].output_hash['components'])
        .select { |c| c['ref_ssi'] == [id] }.map { |c| c['level_ssm'] }.flatten
    end
  end

  to_field 'unitid_ssm', extract_xpath('./did/unitid')
  to_field 'collection_unitid_ssm' do |_record, accumulator, context|
    accumulator.concat Array.wrap(context.clipboard[:parent].output_hash['unitid_ssm'])
  end
  to_field 'repository_ssm' do |_record, accumulator, context|
    accumulator << context.clipboard[:parent].clipboard[:repository]
  end
  to_field 'repository_sim' do |_record, accumulator, context|
    accumulator << context.clipboard[:parent].clipboard[:repository]
  end
  to_field 'collection_ssm' do |_record, accumulator, context|
    accumulator.concat context.clipboard[:parent].output_hash['normalized_title_ssm']
  end
  to_field 'collection_sim' do |_record, accumulator, context|
    accumulator.concat context.clipboard[:parent].output_hash['normalized_title_ssm']
  end
  to_field 'collection_ssi' do |_record, accumulator, context|
    accumulator.concat context.clipboard[:parent].output_hash['normalized_title_ssm']
  end

  to_field 'extent_ssm', extract_xpath('./did/physdesc/extent')
  to_field 'extent_teim', extract_xpath('./did/physdesc/extent')

  # DUL CUSTOMIZATION: Capture text in physical description; separate values for text directly
  # in physdesc vs. in individual child elements e.g., <extent>, <dimensions>, or <physfacet>
  to_field 'physdesc_tesim', extract_xpath('./did/physdesc/child::*')
  to_field 'physdesc_tesim', extract_xpath('./did/physdesc[not(child::*)]')

  to_field 'creator_ssm', extract_xpath('./did/origination')
  to_field 'creator_ssim', extract_xpath('./did/origination')
  to_field 'creators_ssim', extract_xpath('./did/origination')
  to_field 'creator_sort' do |record, accumulator|
    accumulator << record.xpath('./did/origination').map(&:text).join(', ')
  end
  to_field 'collection_creator_ssm' do |_record, accumulator, context|
    accumulator.concat Array.wrap(context.clipboard[:parent].output_hash['creator_ssm'])
  end

  # DUL CUSTOMIZATION: omit DAO @role electronic-record-* from counting as online content
  # as they are not really online and thus shouldn't get the icon/facet value.
  to_field 'has_online_content_ssim', extract_xpath('.//dao[not(starts-with(@role,"electronic-record"))]') do |_record, accumulator|
    accumulator.replace([accumulator.any?])
  end
  to_field 'child_component_count_isim' do |record, accumulator|
    accumulator << NokogiriXpathExtensions.new.is_component(record.children).count
  end

  to_field 'ref_ssm' do |record, accumulator|
    accumulator << record.attribute('id')
  end

  to_field 'level_ssm' do |record, accumulator|
    level = record.attribute('level')&.value
    other_level = record.attribute('otherlevel')&.value
    accumulator << Arclight::LevelLabel.new(level, other_level).to_s
  end

  to_field 'level_sim' do |_record, accumulator, context|
    next unless context.output_hash['level_ssm']

    accumulator.concat context.output_hash['level_ssm']&.map(&:capitalize)
  end

  to_field 'sort_ii' do |_record, accumulator, context|
    accumulator.replace([context.position])
  end

  # DUL CUSTOMIZATION: redefine parent as top-level collection <accessrestrict>
  to_field 'parent_access_restrict_tesim' do |_record, accumulator, context|
    accumulator.concat Array.wrap(context.clipboard[:parent].output_hash['accessrestrict_tesim'])
  end

  # DUL CUSTOMIZATION: redefine parent as top-level collection <userestrict>
  to_field 'parent_access_terms_tesim' do |_record, accumulator, context|
    accumulator.concat Array.wrap(context.clipboard[:parent].output_hash['userestrict_tesim'])
  end

  # DUL CUSTOMIZATION: redefine parent as top-level collection <phystech>
  to_field 'parent_access_phystech_tesim' do |_record, accumulator, context|
    accumulator.concat Array.wrap(context.clipboard[:parent].output_hash['phystech_tesim'])
  end

  # DUL CUSTOMIZATION: redefine component <accessrestrict> & <userestrict> as own values OR values from
  # the nearest non-collection ancestor that has these values.
  RESTRICTION_FIELDS.map do |selector|
    to_field "#{selector}_tesim", extract_xpath("./#{selector}/*[local-name()!='head']", to_text: false)

    # Capture closest ancestor's restrictions BUT only under these conditions:
    # 1) the component doesn't have its own restrictions
    # 2) the ancestor is in the <dsc> (i.e., not top-level)
    to_field "#{selector}_tesim",
             extract_xpath("./ancestor::*[#{selector}][ancestor::dsc][position()=1]/#{selector}/*[local-name()!='head']",
                           to_text: false) do |_record, accumulator, context|
      accumulator.replace [] if context.output_hash["#{selector}_tesim"].present?
    end
  end

  # DUL CUSTOMIZATION: count all online access DAOs from this level down; omit the
  # electronic-record ones as they are not really online access.
  to_field 'total_digital_object_count_isim' do |record, accumulator|
    accumulator << record.xpath('.//dao[not(starts-with(@role,"electronic-record"))]').count
  end

  # DUL Customization: capture the DAO @role & @xpointer attribute
  to_field 'digital_objects_ssm', extract_xpath('./dao|./did/dao', to_text: false) do |_record, accumulator|
    accumulator.map! do |dao|
      label = dao.attributes['title']&.value ||
              dao.attributes['xlink:title']&.value ||
              dao.xpath('daodesc/p')&.text
      href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
      role = (dao.attributes['role'] || dao.attributes['xlink:role'])&.value
      xpointer = (dao.attributes['xpointer'] || dao.attributes['xlink:xpointer'])&.value
      DulArclight::DigitalObject.new(label: label, href: href, role: role, xpointer: xpointer).to_json
    end
  end

  to_field 'date_range_sim', extract_xpath('./did/unitdate/@normal|./did/unittitle/unitdate/@normal', to_text: false) do |_record, accumulator|
    range = Arclight::YearRange.new
    next range.years if accumulator.blank?

    ranges = accumulator.map(&:to_s)
    range << range.parse_ranges(ranges)
    accumulator.replace range.years
  end

  to_field 'date_range_sim', extract_xpath('./did/unittitle/unitdate') do |record, accumulator|
    range = Arclight::YearRange.new(record.include?('/') ? record : record.map { |v| v.tr('-', '/') })
    accumulator << range.to_s
  end

  NAME_ELEMENTS.map do |selector|
    to_field 'names_ssim', extract_xpath("./controlaccess/#{selector}"), unique, strip
    to_field "#{selector}_ssm", extract_xpath(".//#{selector}"), unique, strip
  end

  # DUL CUSTOMIZATION: Bugfix field geogname --> places
  to_field 'places_sim', extract_xpath('./controlaccess/geogname|./controlaccess/controlaccess/geogname')
  to_field 'places_ssm', extract_xpath('./controlaccess/geogname|./controlaccess/controlaccess/geogname')
  to_field 'places_ssim', extract_xpath('./controlaccess/geogname|./controlaccess/controlaccess/geogname')

  to_field 'access_subjects_ssim', extract_xpath('./controlaccess', to_text: false) do |_record, accumulator|
    accumulator.map! do |element|
      # DUL CUSTOMIZATION: pull out genreform into its own field
      %w[subject function occupation].map do |selector|
        element.xpath(".//#{selector}").map(&:text)
      end
    end.flatten!
  end

  to_field 'access_subjects_ssm' do |_record, accumulator, context|
    accumulator.concat(context.output_hash.fetch('access_subjects_ssim', []))
  end

  # DUL CUSTOMIZATION: capture formats (genreform) field separately from subjects
  to_field 'formats_ssim', extract_xpath('./controlaccess/genreform|./controlaccess/controlaccess/genreform')
  to_field 'formats_ssm' do |_record, accumulator, context|
    accumulator.concat(context.output_hash.fetch('formats_ssim', []))
  end

  # DUL CUSTOMIZATION: Components no longer inherit collection-level acqinfo values
  to_field 'acqinfo_ssim', extract_xpath('./acqinfo/*[local-name()!="head"]')
  to_field 'acqinfo_ssim', extract_xpath('./descgrp/acqinfo/*[local-name()!="head"]')

  # DUL CUSTOMIZATION: separate language vs langmaterial fields that don't have language
  # Probably just a DUL modification; mix of conventions in use in our data
  to_field 'language_ssm', extract_xpath('./did/langmaterial/language')
  to_field 'langmaterial_ssm', extract_xpath('./did/langmaterial[not(descendant::language)]')

  to_field 'containers_ssim' do |record, accumulator|
    record.xpath('./did/container').each do |node|
      accumulator << [node.attribute('type'), node.text].join(' ').strip
    end
  end

  SEARCHABLE_NOTES_FIELDS.map do |selector|
    to_field "#{selector}_tesim", extract_xpath("./#{selector}/*[local-name()!='head']", to_text: false)
    to_field "#{selector}_heading_ssm", extract_xpath("./#{selector}/head")
    to_field "#{selector}_teim", extract_xpath("./#{selector}/*[local-name()!='head']")
  end
  DID_SEARCHABLE_NOTES_FIELDS.map do |selector|
    to_field "#{selector}_tesim", extract_xpath("./did/#{selector}", to_text: false)
    to_field "#{selector}_teim", extract_xpath("./did/#{selector}/*[local-name()!='head']")
  end
  to_field 'did_note_ssm', extract_xpath('./did/note')

  # DUL CUSTOMIZATION: add index
  to_field 'indexes_tesim', extract_xpath('./index', to_text: false)
end
# rubocop:enable Metrics/BlockLength

each_record do |_record, context|
  context.output_hash['components'] &&= context.output_hash['components'].select { |c| c.keys.any? }
end

##
# Used for evaluating xpath components to find
class NokogiriXpathExtensions
  # rubocop:disable Naming/PredicateName, Style/FormatString
  def is_component(node_set)
    node_set.find_all do |node|
      component_elements = (1..12).map { |i| "c#{'%02d' % i}" }
      component_elements.push 'c'
      component_elements.include? node.name
    end
  end
  # rubocop:enable Naming/PredicateName, Style/FormatString
end
