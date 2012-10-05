require 'spec_helper'

describe "postfix grok patterns" do

  let(:tested_pattern_file) { 'patterns/postfix' }

  describe "%{QUEUEID}" do

    it_should_behave_like "a grok pattern matcher",
                          description,
                          %w(38D2311EF05: NOQUEUE:),
                          %w(foo bar)

  end

  describe "%{ADDRESS}" do

    it_should_behave_like "a grok pattern matcher",
                          description,
                          %w(<user@example.com>),
                          %w(not_valid_address)

    it_should_behave_like "a grok field matcher",
                          description,
                          "<user@example.com>",
                          {local: 'user', remote: 'example.com'}

  end

end
