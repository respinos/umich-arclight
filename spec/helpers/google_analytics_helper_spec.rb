# frozen_string_literal: true

describe GoogleAnalyticsHelper, type: :helper do
  describe 'ga_page_type' do
    context 'with search results page with no results' do
      before do
        allow(helper).to receive(:search_results_page_zero_results?)\
          .and_return(true)
      end

      it 'is considered a No Results page' do
        expect(helper.ga_page_type).to eq('No Results Page')
      end
    end

    context 'with search results page that has results' do
      before do
        allow(helper).to receive(:search_results_page_zero_results?)\
          .and_return(false)
        allow(helper).to receive(:search_results_page_with_results?)\
          .and_return(true)
      end

      it 'is considered a Search Results page' do
        expect(helper.ga_page_type).to eq('Search Results Page')
      end
    end

    context 'with homepage URL' do
      before do
        allow(helper).to receive(:home_page?).and_return(true)
      end

      it 'is considered a Homepage' do
        expect(helper.ga_page_type).to eq('Homepage')
      end
    end

    context 'with a collection show page' do
      before do
        allow(helper).to receive(:collection_show_page?).and_return(true)
      end

      it 'is considered a Collection Page' do
        expect(helper.ga_page_type).to eq('Collection Page')
      end
    end

    context 'with a component show page' do
      before do
        allow(helper).to receive(:component_show_page?).and_return(true)
      end

      it 'is considered a Component Page' do
        expect(helper.ga_page_type).to eq('Component Page')
      end
    end

    context 'with a bookmarks page' do
      before do
        allow(helper).to receive(:bookmarks_page?).and_return(true)
      end

      it 'is considered a Bookmarks Page' do
        expect(helper.ga_page_type).to eq('Bookmarks Page')
      end
    end

    context 'with the UA record groups page' do
      before do
        allow(helper).to receive(:ua_record_groups_page?).and_return(true)
      end

      it 'is considered a UA Record Groups Page' do
        expect(helper.ga_page_type).to eq('UA Record Groups Page')
      end
    end

    context 'with a page that does not match any of the defined types' do
      before do
        allow(helper).to receive(:search_results_page_zero_results?)\
          .and_return(false)
        allow(helper).to receive(:search_results_page_with_results?)\
          .and_return(false)
        allow(helper).to receive(:home_page?).and_return(false)
        allow(helper).to receive(:collection_show_page?).and_return(false)
        allow(helper).to receive(:component_show_page?).and_return(false)
        allow(helper).to receive(:bookmarks_page?).and_return(false)
        allow(helper).to receive(:ua_record_groups_page?).and_return(false)
      end

      it 'is considered an Other Page' do
        expect(helper.ga_page_type).to eq('Other Page')
      end
    end
  end
end
