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

  resources :ua_record_groups, only: [:index], as: 'ua_record_groups', path: '/collections/ua-record-groups', controller: 'ua_record_groups'

  post '/index_finding_aids', to: 'index_finding_aids#create'
end
