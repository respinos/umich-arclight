RSpec.describe BuildSuggestJob do

  it "works" do
    expect { BuildSuggestJob.perform_now }.not_to raise_error
  end

end
