RSpec::Matchers.define :have_logstash_field do |field|
  chain :with_value do |value|
    @value= value
  end

  match do |grok_match|
    # avoid running the assertion on non matching data
    grok_match.should be_a Grok::Match
    grok_captures = grok_match.captures()
    grok_field = grok_captures.keys.grep(/.*:#{field}$/)
    if @value
      grok_captures[grok_field.first].first.should == @value
    else
      grok_field.size.should equal 1
    end
  end

  failure_message_for_should do |grok_match|
    if !grok_match.is_a?(Grok::Match) # non matching data case
      "grok did not matched the text for the given argument"
    elsif @value
      "\"#{field}\" isn't set to \"#{@value}\" in #{grok_match.captures()}"
    else
      "\"#{field}\" suffix not present in #{grok_match.captures().keys}"
    end
  end
end
