RSpec::Matchers.define :relocate_to do |expected_path|
  @expected_path = expected_path
  match do
    md = response.body.match(/<script>top\.location = '(.*)'<\/script>/)
    next false unless md

    _, @actual_path = md.to_a

    case @expected_path
    when Regexp
      @actual_path =~ expected_path
    when String
      @actual_path == expected_path
    else
      raise
    end
  end

  description do
    "relocate to #{@actual_path}"
  end

  failure_message_for_should do |model|
    "expected to be respond with relocate to #{@expected_path} but #{@actual_path}"
  end
end
