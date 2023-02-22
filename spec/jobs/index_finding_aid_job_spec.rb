require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe IndexFindingAidJob, type: :job do
  include ActiveJob::TestHelper

  let(:file) { 'path/to/file.xml' }
  let(:fd) { StringIO.open("<ead><eadheader><eadid>eadid.slug</eadid></eadheader></ead>") }
  let(:repository_id) { 'repo' }
  let(:path) { "#{DulArclight.finding_aid_data}/xml/#{repository_id}" }
  let(:dest) { "#{path}/eadid-slug.xml" }
  let(:stdout_and_stderr) { 'stdout and stderr' }
  let(:process_status) { instance_double("Process::Status", "process_status", success?: success) }
  let(:success) { true }

  before do
    allow(Open3).to receive(:capture2e).with({"REPOSITORY_ID" => repository_id},
                                             "bundle exec traject -u #{Blacklight.default_index.connection.base_uri.to_s.chomp("/")} -i xml -c ./lib/dul_arclight/traject/ead2_config.rb #{file}")
      .and_return([stdout_and_stderr, process_status])
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(file, "r:UTF-8:UTF-8").and_yield(fd)
    allow(FileUtils).to receive(:mkdir_p).with(path)
    allow(FileUtils).to receive(:copy_file).with(file, dest, {dereference: true, preserve: true, remove_destination: true})
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

  it 'copies the source file to data xml repo directory using eadid slug' do
    perform_enqueued_jobs { described_class.perform_later(file, repository_id) }
    expect(FileUtils).to have_received(:mkdir_p).with(path)
    expect(FileUtils).to have_received(:copy_file).with(file, dest, {dereference: true, preserve: true, remove_destination: true})
  end

  context 'when empty eadid tag' do
    let(:fd) { StringIO.open("<ead><eadheader><eadid></eadid></eadheader></ead>") }
    let(:dest) { "#{path}/#{File.basename(file, ".*")}.xml" }

    it 'copies the source file to data xml repo directory using basename' do
      perform_enqueued_jobs { described_class.perform_later(file, repository_id) }
      expect(FileUtils).to have_received(:mkdir_p).with(path)
      expect(FileUtils).to have_received(:copy_file).with(file, dest, {dereference: true, preserve: true, remove_destination: true})
    end
  end

  context 'when missing eadid tag' do
    let(:fd) { StringIO.open("<ead><eadheader></eadheader></ead>") }
    let(:dest) { "#{path}/#{File.basename(file, ".*")}.xml" }

    it 'copies the source file to data xml repo directory using basename' do
      perform_enqueued_jobs { described_class.perform_later(file, repository_id) }
      expect(FileUtils).to have_received(:mkdir_p).with(path)
      expect(FileUtils).to have_received(:copy_file).with(file, dest, {dereference: true, preserve: true, remove_destination: true})
    end
  end

  context 'when traject failure' do
    let(:success) { false }

    it 'raises an exception' do
      expect { described_class.perform_now(file, repository_id) }.to raise_exception(DulArclight::IndexError, stdout_and_stderr)
    end

    it 'does NOT copy source file to data xml repo directory' do
      expect { described_class.perform_now(file, repository_id) }.to raise_exception(DulArclight::IndexError, stdout_and_stderr)
      expect(FileUtils).not_to have_received(:mkdir_p).with(path)
      expect(FileUtils).not_to have_received(:copy_file).with(file, dest, {dereference: true, preserve: true, remove_destination: true})
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
