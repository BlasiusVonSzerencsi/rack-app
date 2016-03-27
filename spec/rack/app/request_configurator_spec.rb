require 'spec_helper'

describe Rack::App::RequestConfigurator do

  let(:instance) { Object.new.tap { |o| o.extend(described_class) } }

  let(:request_env) do
    {
        ::Rack::PATH_INFO => '/hello/world/'
    }
  end
  describe '#configure' do
    subject { instance.configure(request_env) }

    it { is_expected.to include({Rack::App::Constants::ORIGINAL_PATH_INFO => '/hello/world/'}) }

    it { is_expected.to include({::Rack::PATH_INFO => '/hello/world'}) }
  end

end