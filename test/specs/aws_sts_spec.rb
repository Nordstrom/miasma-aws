require_relative '../helper'
require 'miasma/contrib/aws'

# NOTE: Role has read-only rights to cfn data

describe Miasma::Models::Orchestration::Aws do

  describe 'STS Assume Role', :vcr do

    before do
      @orchestration = Miasma.api(
        :type => :orchestration,
        :provider => :aws,
        :credentials => {
          :aws_access_key_id => ENV['MIASMA_AWS_ACCESS_KEY_ID'],
          :aws_secret_access_key => ENV['MIASMA_AWS_SECRET_ACCESS_KEY'],
          :aws_region => ENV['MIASMA_AWS_REGION'],
          :aws_sts_role_arn => ENV['MIASMA_AWS_STS_ROLE_ARN']
        }
      )
      VCR.use_cassette('Miasma_Models_Orchestration_Global/GLOBAL_sts_initialization') do
        @orchestration.stacks.all
      end
    end

    it 'should successfully complete read action' do
      @orchestration.stacks.all
    end

    it 'should error on write action' do
      result = nil
      proc do
        begin
          @orchestration.stacks.build.save
        rescue => result
          raise result
        end
      end.must_raise Miasma::Error::ApiError
      result.response.code.must_equal 403
    end

  end

  describe 'STS direct token', :vcr do
    before do
      @orchestration = Miasma.api(
        :type => :orchestration,
        :provider => :aws,
        :credentials => {
          :aws_access_key_id => ENV['MIASMA_AWS_ACCESS_KEY_ID_STS'],
          :aws_secret_access_key => ENV['MIASMA_AWS_SECRET_ACCESS_KEY_STS'],
          :aws_region => ENV['MIASMA_AWS_REGION'],
          :aws_sts_token => ENV['MIASMA_AWS_STS_TOKEN']
        }
      )
    end

    it 'should successfully complete read action' do
      @orchestration.stacks.all
    end

    it 'should error on write action' do
      result = nil
      proc do
        begin
          @orchestration.stacks.build.save
        rescue => result
          raise result
        end
      end.must_raise Miasma::Error::ApiError
      result.response.code.must_equal 403
    end

  end

end
