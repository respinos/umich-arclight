# frozen_string_literal: true

# Overrides Blacklight Core file
# See: https://github.com/projectblacklight/blacklight/blob/master/app/models/concerns/blacklight/document/email.rb
# Last checked for updates: Blacklight 7.5.0
module Blacklight::Document::Email
  # Return a text string that will be the body of the email
  def to_email_text
    body = []
    body << I18n.t('blacklight.email.text.title', value: normalized_title) if normalized_title.present?
    body << I18n.t('blacklight.email.text.description', value: short_description) if short_description.present?
    body << I18n.t('blacklight.email.text.in', value: parent_labels.join(' > ')) if parent_labels.present?
    body << I18n.t('blacklight.email.text.physdesc', value: physdesc.join('; ')) if physdesc.present?
    body << I18n.t('blacklight.email.text.containers', value: containers.join('; ')) if containers.present?
    return body.join("\n") unless body.empty?
  end
end
