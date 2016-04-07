require 'spec_helper'

RSpec.describe SSHClient::ConfigItem do
  shared_examples 'default' do
    describe '#ssh_command' do
      before do
        config.hostname = 'localhost'
        config.username = 'vagrant'
      end

      subject { config.ssh_command }
      it { is_expected.to eq 'ssh vagrant@localhost' }

      context 'with_password' do
        before { config.password = 'vagrant' }
        it { is_expected.to eq 'sshpass -pvagrant ssh vagrant@localhost' }
      end
    end
  end

  context 'default configuration' do
    let(:config) { described_class.new }
    include_examples 'default'
  end

  context 'custom configuration' do
    let(:config) { described_class.new :custom }
    include_examples 'default'
  end

end
