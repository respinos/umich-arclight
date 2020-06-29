RSpec.describe BuildSuggestJob do
  it 'works' do
    expect { described_class.perform_now }.not_to raise_error
  end
end
