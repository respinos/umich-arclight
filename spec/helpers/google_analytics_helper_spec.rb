# frozen_string_literal: true

describe GoogleAnalyticsHelper, type: :helper do
  describe 'ga_user_properties' do
    context 'with document' do
      before do
        allow(helper).to receive(:collection_show_page?).and_return(true)
      end

      it 'returns a hash with properties for page type, and repository' do
        slug = 'scrc'
        collection_id = "umich-#{slug}-001"
        repository_name = 'University of Michigan. Special Collections Research Center'
        config = instance_double 'Arclight::Repository',
                                 slug: slug
        document = instance_double 'Blacklight::SolrDocument',
                                   repository_config: config,
                                   repository: repository_name,
                                   eadid: collection_id

        assign(:document, document)
        user_properties = JSON.parse(helper.ga_user_properties)
        expect(user_properties).to include(
          'page_type' => 'Collection Page',
          'repository_id' => ":#{slug}:",
          'collection_id' => ":#{collection_id}:"
        )
      end
    end
  end

  describe 'ga_repository_id' do
    context 'with document' do
      slug = 'scrc'
      repository_name = 'University of Michigan. Special Collections Research Center'

      it 'a document with repository should return the slug' do
        config = instance_double 'Arclight::Repository',
                                 slug: slug
        document = instance_double 'Blacklight::SolrDocument',
                                   repository_config: config,
                                   repository: repository_name

        assign(:document, document)
        expect(helper.ga_repository_id).to eq(slug)
      end
    end

    context 'with no document, but params' do
      before do
        allow(helper).to receive(:params).and_return(f: { 'repository_sim' => ['University of Michigan. Bentley Historical Library'] })
      end

      slug = 'bhl'
      repository_name = 'University of Michigan. Bentley Historical Library'

      it 'is finding the repository from a filtered query' do
        config = double('Arclight::Repository', slug: slug, name: repository_name)
        repository = class_double('Arclight::Repository',
                                  find_by: config).as_stubbed_const
        expect(helper.ga_repository_id).to eq(slug)
      end
    end
  end

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
