class DeleteFindingAidJob < ApplicationJob
  queue_as :delete

  def perform(eadid)
    Blacklight.default_index.connection.delete_by_query("ead_ssi:#{eadid}")
    Blacklight.default_index.connection.commit
  end
end
