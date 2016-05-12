require 'spec_helper'

RSpec.describe SSHClient::Connection do
  before do
    SSHClient.config.logger = Logger.new('log/test.log')
    SSHClient.config.read_timeout = 0.5
  end

  after do
    connection.close
  end

  let(:connection) { described_class.new }

  describe '#exec!' do
    subject { connection.exec! 'hostname' }

    it { is_expected.to include `hostname`.strip }

    context 'many commands' do
      subject { connection.exec! "hostname\nuname -a" }
      it { is_expected.to include `hostname`.strip }
      it { is_expected.to include `uname -a`.strip }
    end

    # context 'long run' do
    #   subject { connection.exec! "tailf -1000 #{__FILE__}" }
    #   it { is_expected.to include 'long run' }
    # end

    context 'raise on error' do
      before { SSHClient.config.raise_on_errors = true }
      subject { connection.exec! "¯\\_(ツ)_/¯" }
      it do
        expect { subject }.to raise_error SSHClient::CommandExitWithError
      end
    end

    context 'with block' do
      subject do
        connection.exec! do
          hostname
          uname '-a'
        end
      end

      it { is_expected.to include `hostname`.strip }
      it { is_expected.to include `uname -a`.strip }
    end
  end
end
