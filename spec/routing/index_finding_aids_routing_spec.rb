RSpec.describe "index_finding_aids routing", type: :routing do

  specify {
    expect(post: '/index_finding_aids')
      .to route_to(controller: 'index_finding_aids', action: 'create')
  }

end
