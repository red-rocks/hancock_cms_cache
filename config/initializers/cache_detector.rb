
module ActionView
  module Helpers
    module CacheHelper

      if Hancock.rails4?
        def cache_fragment_name(name = {}, options = nil)
          skip_digest = options && options[:skip_digest]

          if skip_digest
            begin
              if Hancock::Cache.config.runtime_cache_detector
                _name = Hancock::Cache::Fragment.name_from_view(name)
                if !respond_to?(:hancock_cache_fragments) or (frag = hancock_cache_fragments[_name]).nil? or !frag.enabled
                  _desc = "" #"#{@virtual_path}\noptions: #{options}"
                  _virtual_path = @virtual_path
                  Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path)
                end
              end
            rescue
            end

            name
          else
            fragment_name_with_digest(name)
          end
        end

      elsif Hancock.rails5?
        def cache_fragment_name(name = {}, skip_digest: nil, virtual_path: nil)
          if skip_digest
            begin
              if Hancock::Cache.config.runtime_cache_detector
                _name = Hancock::Cache::Fragment.name_from_view(name)
                if !respond_to?(:hancock_cache_fragments) or (frag = hancock_cache_fragments[_name]).nil? or !frag.enabled
                  _desc = "" #"#{virtual_path}\noptions: #{options}"
                  _virtual_path = virtual_path
                  Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path)
                end
              end
            rescue
            end

            name
          else
            fragment_name_with_digest(name, virtual_path)
          end
        end
      end

    end
  end
end
