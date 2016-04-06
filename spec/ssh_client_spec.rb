require 'spec_helper'

describe SSHClient do
  it 'has a version number' do
    expect(SSHClient::VERSION).not_to be nil
  end

  describe '.connect' do
    describe 'return connection' do
      after { described_class.close }
      subject { described_class.connect }
      it { is_expected.to be_an SSHClient::Connection }
    end

    context 'with block' do
      let(:buffer) { String.new }

      before do
        SSHClient.config.add_listener(:test) { |data| buffer << data }
      end

      after do
        SSHClient.config.remove_listener :test
      end

      subject do
        described_class.connect do
          uname '-a'
        end
      end

      it { expect { subject }.to change { buffer[`uname -a`.strip] }.from nil }
    end
  end
end
