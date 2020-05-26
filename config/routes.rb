Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

    mount Arclight::Engine => '/'

  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resource :advanced_search, only: [:show], as: 'advanced_search', path: '/advanced', controller: 'advanced_search'

  resources :ua_record_groups, only: [:index], as: 'ua_record_groups', path: '/collections/ua-record-groups', controller: 'ua_record_groups'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/index_finding_aids', to: 'index_finding_aids#create'
end
