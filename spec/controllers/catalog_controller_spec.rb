# frozen_string_literal: true

# Test replicated from ArcLight core to confirm that DUL ArcLight is
# set up with a comparable testing framework. Consider removing the
# replicated tests in the future when there are tests specific to
# DUL ArcLight's local customizations.

require 'spec_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index action customizations' do
    context 'online_contents view' do
      it 'does not start a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'online_contents' }
        expect(session[:history]).to be_empty
      end

      it 'does not store a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'online_contents' }
        expect(session[:preferred_view]).to eq 'list'
      end
    end

    context 'any other view' do
      it 'starts a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'list' }
        expect(session[:history]).not_to be_empty
      end

      it 'stores a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'gallery' }
        expect(session[:preferred_view]).to eq 'gallery'
      end
    end
  end

  describe '#facet_limit_for' do
    let(:blacklight_config) { controller.blacklight_config }

    it 'defaults to a limit of 10 for shown field facets' do
      expect(blacklight_config.facet_fields.key?('collection_sim')).to be true
      expect(blacklight_config.facet_fields['collection_sim'].limit).to eq 10
      expect(controller.facet_limit_for('collection_sim')).to eq 10
    end
  end
end
