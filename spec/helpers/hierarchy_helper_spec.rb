describe HierarchyHelper, type: :helper do
  describe '#map_ua_record_group_codes' do
    context 'when a top record group mapping exists' do
      let(:item) { instance_double('item', qvalue: '01', value: '01') }

      it 'returns a mapped value' do
        expect(helper.map_ua_record_group_codes(item)).to eq('01 &mdash; General Information and University History')
      end
    end

    context 'when a group + subgroup mapping exists' do
      let(:item) { instance_double('item', qvalue: '31:11', value: '11') }

      it 'returns a mapped value' do
        expect(helper.map_ua_record_group_codes(item)).to eq('11 &mdash; Student Organizations - Recreational Sports')
      end
    end

    context 'when no group + subgroup mapping exists' do
      let(:item) { instance_double('item', qvalue: '999:02', value: '02') }

      it 'returns "Unknown" in label' do
        expect(helper.map_ua_record_group_codes(item)).to eq('02 &mdash; Unknown')
      end
    end
  end
end
