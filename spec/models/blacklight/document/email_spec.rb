# frozen_string_literal: true

RSpec.describe 'Blacklight::Document::Email' do
  before(:all) do
    SolrDocument.use_extension(Blacklight::Document::Email)
  end

  context 'when some fields are missing' do
    it 'only renders fields that have values' do
      doc = SolrDocument.new(id: '1234', normalized_title_ssm: 'My Title')
      email_body = doc.to_email_text
      expect(email_body).to match(/Title: My Title/)
      expect(email_body).not_to match(/Containers:/)
    end
  end

  context 'when all mapped fields are present' do
    doc = SolrDocument.new(id: '1234')
    before do
      allow(doc).to receive(:normalized_title).and_return('My Title')
      allow(doc).to receive(:short_description).and_return('Truncated description of the thing...')
      allow(doc).to receive(:parent_labels).and_return(['Amazing Collection', 'A Nice Series', 'Parent Subseries'])
      allow(doc).to receive(:physdesc).and_return(['10 Items', '4 Linear Feet'])
      allow(doc).to receive(:containers).and_return(['Box 5'])
    end

    it 'renders values correctly for each field' do
      email_body = doc.to_email_text
      expect(email_body).to match(/Title: My Title/)
      expect(email_body).to match(/Description: Truncated description of the thing.../)
      expect(email_body).to match(/In: Amazing Collection > A Nice Series > Parent Subseries/)
      expect(email_body).to match(/Physical Description: 10 Items; 4 Linear Feet/)
      expect(email_body).to match(/Containers: Box 5/)
    end
  end
end
