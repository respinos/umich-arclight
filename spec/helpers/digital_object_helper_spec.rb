describe DigitalObjectHelper, type: :helper do
  describe '#erec_aeon_link' do
    let(:obj) do
      DulArclight::DigitalObject.new(
        label: 'My Digital Object',
        href: 'https://somewhere.oit.duke.edu/some/path',
        role: 'electronic-record-master',
        xpointer: 'RL12345-ABC-6789'
      )
    end
    let(:doc) do
      instance_double('document',
                      accessrestrict: ['<p>Collection is open for research.</p>'],
                      bibnums: ['002164677'],
                      collection_name: 'Awesome collection',
                      creator: 'Person',
                      eadid: 'gedney',
                      extent: '2 GB',
                      id: 'gedney_aspace_123',
                      normalized_date: 'bulk 1766-1845')
    end

    it 'maps nonblank properties into OpenURL parameters for an Aeon link' do
      expect(helper.erec_aeon_link(obj, doc)).to \
        eq('https://duke.aeon.atlas-sys.com/logon/?' + \
        [
          'Action=10',
          'Form=30',
          'genre=manuscript',
          'rfe_dat=Aleph%3A002164677',
          'rft.access=Collection+is+open+for+research.',
          'rft.au=Person',
          'rft.barcode=RL12345-ABC-6789',
          'rft.callnum=electronic-record-master',
          'rft.collcode=Electronic_Record',
          'rft.date=bulk+1766-1845',
          'rft.eadid=gedney',
          'rft.pub=gedney_aspace_123',
          'rft.site=SCL',
          'rft.stitle=My+Digital+Object+--+2+GB',
          'rft.title=Awesome+collection',
          'rft.volume=https%3A%2F%2Fsomewhere.oit.duke.edu%2Fsome%2Fpath'
        ].join('&'))
    end
  end
end
