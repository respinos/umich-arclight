# frozen_string_literal: true

# Test replicated from ArcLight core to confirm that DUL ArcLight is
# set up with a comparable testing framework. Consider removing the
# replicated tests in the future when there are tests specific to
# DUL ArcLight's local customizations.

require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  # Modeled after ArcLight core, see:
  # https://github.com/projectblacklight/arclight/blob/master/spec/controllers/catalog_controller_spec.rb
  describe 'index action customizations' do
    context 'child_components view' do
      it 'does not start a search_session' do
        allow(controller).to receive(:search_results)
        session[:history] = []
        get :index, params: { q: 'foo', view: 'child_components' }
        expect(session[:history]).to be_empty
      end

      it 'does not store a preferred_view' do
        allow(controller).to receive(:search_results)
        session[:preferred_view] = 'list'
        get :index, params: { q: 'foo', view: 'child_components' }
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
end
