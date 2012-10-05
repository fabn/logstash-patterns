require 'spec_helper'

shared_context "grok setup" do

  # Grok instance
  let(:grok) { Grok.new }

  before :each do
    # add grok patterns
    Dir['grok-patterns/*'].each do |pattern_file|
      grok.add_patterns_from_file(pattern_file)
    end
    # Add tested pattern file
    grok.add_patterns_from_file(tested_pattern_file) if respond_to?(:tested_pattern_file)
    # Compile the pattern if given
    grok.compile(pattern) if respond_to?(:pattern)
  end
end

# @param [String] pattern the pattern under test
# @param [Array<String>] matching a list of matching patterns
# @param [Array<String>, nil] not_matching a list of not matching patterns
shared_examples "a grok pattern matcher" do |pattern, matching, not_matching|

  let(:pattern) { pattern }
  include_context "grok setup"

  matching.each do |match|
    it "should match \"#{match}\" (against \"#{pattern}\")" do
      grok.match(match).should be_a Grok::Match
    end
  end

  not_matching.to_a.each do |match|
    it "should not match \"#{match}\" (against \"#{pattern}\")" do
      grok.match(match).should_not be_a Grok::Match
    end
  end

end

# @param [String] pattern the pattern under test
# @param [String] example the string to match
# @param [Hash,Array] fields an hash of expected matched fields
shared_examples "a grok field matcher" do |pattern, example, fields|

  let(:pattern) { pattern }
  include_context "grok setup"

  case fields
    when Array
      fields.each do |field|
        it "should match field \"#{field}\" for \"#{example}\"" do
          grok.match(example).should have_logstash_field(field)
        end
      end
    when Hash
      fields.each do |field, value|
        it "should match field \"#{field}\" with \"#{value}\" for \"#{example}\"" do
          grok.match(example).should have_logstash_field(field).with_value(value)
        end
      end
    else
      # ignore the example
  end

end
