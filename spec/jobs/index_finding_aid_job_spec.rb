require 'spec_helper'

RSpec.describe IndexFindingAidJob, type: :job do
  include ActiveJob::TestHelper

  let(:file) { 'path/to/file.xml' }
  let(:repository_id) { 'repo' }
  let(:stdout_and_stderr) { 'stdout and stderr' }
  let(:process_status) { instance_double("Process::Status", "process_status", success?: success) }
  let(:success) { true }

  before do
    allow(Open3).to receive(:capture2e).with({"REPOSITORY_ID" => repository_id},
                                             "bundle exec traject -u #{Blacklight.default_index.connection.base_uri.to_s.chomp("/")} -i xml -c ./lib/dul_arclight/traject/ead2_config.rb #{file}")
      .and_return([stdout_and_stderr, process_status])
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { described_class.perform_later(file, repository_id) }.to have_enqueued_job(described_class).with(file, repository_id).on_queue("index")
  end

  it 'puts stdout and stderr' do
    expect { perform_enqueued_jobs { described_class.perform_later(file, repository_id) } }.to output(stdout_and_stderr + "\n").to_stdout_from_any_process
  end

  context 'when failure' do
    let(:success) { false }

    it 'raises an exception' do
      expect { described_class.perform_now(file, repository_id) }.to raise_exception(DulArclight::IndexError, stdout_and_stderr)
    end
  end
end
