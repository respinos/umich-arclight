module UmArclight
  class DownloadHelper
    attr_accessor :document

    def initialize(document)
      @document = document
    end

    def ead_file_path
      # look for the document eadid first
      filename = File.join(DulArclight.finding_aid_data, 'ead', repo_id, "#{eadid}.xml")
      return filename if File.exist?(filename)

      return ead_filename_from_publicid if request_pattern_present?
    end

    def html_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_id, "#{eadid}.html")
    end

    def pdf_file_path
      File.join(DulArclight.finding_aid_data, 'pdf', repo_id, "#{eadid}.pdf")
    end

    def ead_filename_from_publicid
      # look for a filename based on publicid_ssi + request_pattern
      publicid = document.publicid
      request_pattern = document.repository_config.request_pattern
      match = Regexp.new(request_pattern).match(publicid)
      filename = File.join(DulArclight.finding_aid_data, 'ead', repo_id, match[1])
      return filename if File.exist?(filename)
    end

    def repo_id
      document.repository_config&.slug
    end

    delegate :eadid, to: :document

    def request_pattern_present?
      document.repository_config&.request_pattern_present?
    end

    def ead_available?
      File.exist?(ead_file_path)
    end

    def pdf_available?
      File.exist?(pdf_file_path)
    end
  end
end
