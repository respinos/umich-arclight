RSpec.describe IndexFindingAidsController, type: :controller do
  describe '#create' do
    let(:token) { SecureRandom.hex(8) }
    let(:payload) do
      {
        'commits' => [
          {
            'id' => 'b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327',
            'added' => ['README.md'],
            'modified' => ['.gitlab-ci.yml'],
            'removed' => []
          },
          {
            'id' => 'da1560886d4f094c3e6c9ef40349f7d38b5d27d7',
            'added' => [],
            'modified' => ['ead/rubenstein/rushbenjaminandjulia.xml'],
            'removed' => ['ead/rubenstein/appleberrydilmus.xml']
          }
        ]
      }
    end

    before do
      allow(DulArclight).to receive(:gitlab_token) { token }
      allow(controller).to receive(:update_finding_aid_data).and_return(nil)
    end

    it 'requires a Gitlab token header' do
      post :create, body: payload.to_json, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'require a Gitlab event header' do
      request.headers['X-Gitlab-Token'] = token
      post :create, body: payload.to_json, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    specify do
      expect(IndexFindingAidJob)
        .to receive(:perform_later)
        .with('spec/fixtures/ead/rubenstein/rushbenjaminandjulia.xml', 'rubenstein')
        .and_call_original
      expect(DeleteFindingAidJob)
        .to receive(:perform_later)
        .with('appleberrydilmus')
        .and_call_original
      request.headers['X-Gitlab-Token'] = token
      request.headers['X-Gitlab-Event'] = 'Push Hook'
      post :create, body: payload.to_json, as: :json
      expect(response).to have_http_status(:accepted)
    end
  end
end
