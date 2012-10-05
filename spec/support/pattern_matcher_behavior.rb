require 'spec_helper'

shared_examples "a grok pattern matcher for" do |pattern, matching, not_matching|

  # Grok instance
  let(:grok) { Grok.new }

  before :each do
    # add grok patterns
    Dir['grok-patterns/*'].each do |pattern_file|
      grok.add_patterns_from_file(pattern_file)
    end
    # Add tested pattern file
    grok.add_patterns_from_file(tested_pattern_file) if respond_to?(:tested_pattern_file)
  end

  matching.each do |match|
    it "should match #{match} against #{pattern}" do
      grok.compile(pattern)
      grok.match(match).should be_a Grok::Match
    end
  end

  not_matching.each do |match|
    it "should not match #{match} against #{pattern}" do
      grok.compile(pattern)
      grok.match(match).should_not be_a Grok::Match
    end
  end

end
