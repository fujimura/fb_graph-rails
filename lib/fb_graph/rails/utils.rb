module FbGraph::Rails
  module Utils

    # go outside of iframe by rewriting url of frame with JavaScript.
    #
    def relocate_to(url_for_options, options = {})
      to = url_for(url_for_options)
      render :text => "<script>top.location = '#{to}'</script>"
    end

  end
end
