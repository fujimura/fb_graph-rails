module FbGraph::Rails
  module Utils

    # parse signed request * without verification *
    #
    def parse_signed_request(signed_request)
      encoded_sig, payload = signed_request.split('.')
      data = ActiveSupport::JSON.decode base64_url_decode(payload)
    end
    def base64_url_decode(str)
      encoded_str = str.gsub('-', '+').gsub('_', '/')
      encoded_str += '=' while !(encoded_str.size % 4).zero?
      Base64.decode64(encoded_str)
    end

    # go outside of iframe by rewriting url of frame with JavaScript.
    #
    def relocate_to(url_for_options, options = {})
      to = url_for(url_for_options)
      render :text => "<script>top.location = '#{to}'</script>"
    end

  end
end
