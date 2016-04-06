require 'spec_helper'

RSpec.describe SSHClient::Connection do
  let(:connection) { described_class.new }
  let(:buffer) { String.new }

  before do
    SSHClient.config.add_listener(:test) { |data| buffer << data }
  end

  after do
    SSHClient.config.remove_listener :test
  end

  describe '#exec' do
    subject do
      connection.exec 'hostname'
      connection.close
    end

    it do
      expect { subject }.to change { buffer[`hostname`.strip] }.from nil
    end

    context 'many commands' do
      subject do
        connection.exec "hostname\nuname -a"
        connection.close
      end

      it 'hostname' do
        expect { subject }.to change { buffer[`hostname`.strip] }.from nil
      end

      it 'uname -a' do
        expect { subject }.to change { buffer[`uname -a`.strip] }.from nil
      end

    end
  end

  describe '#batch_exec' do
    subject do
      connection.batch_exec do
        hostname
        uname '-a'
      end
    end

    it 'hostname' do
      expect { subject }.to change { buffer[`hostname`.strip] }.from nil
    end

    it 'uname -a' do
      expect { subject }.to change { buffer[`uname -a`.strip] }.from nil
    end

  end
end
