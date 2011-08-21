module FbGraph::Rails
  module Node
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end
  end
  module ClassMethods
    def delegate_to_facebook(*args)
      args = args.dup
      options = args.last.is_a?(Hash) ? args.pop : {}

      cattr_accessor :ignore_errors
      self.ignore_errors = options[:ignore_errors] == true

      define_method :facebook_identifier do
        self.send(options[:identifier] || :identifier)
      end

      args.each do |attribute|
        define_method attribute do
          profile.nil? ? nil : profile.send(attribute)
        end
      end
    end
  end
  module InstanceMethods
    def profile
      return nil if @_profile_was_not_found

      @profile ||= begin
                     FbGraph.const_get(self.class.name).fetch facebook_identifier
                   rescue FbGraph::NotFound
                     raise unless self.class.ignore_errors
                     # nil can't be memoized
                     @_profile_was_not_found = true
                     nil
                   end
    end
  end
end
