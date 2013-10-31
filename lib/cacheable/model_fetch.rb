module Cacheable
	module ModelFetch
	
		def rails_assoc_cache_fetch(object, association_name, options={})
			if options[:belongs_to]
				cache_key = belong_association_cache_key(association_name, options[:polymorphic])
			else
				cache_key = have_association_cache_key(association_name)
			end

			unless result = read_from_cache(cache_key)
				association_cache.delete(association_name)
				result = object.send(association_name)
				write_to_cache(cache_key, result)
			end
			result
		end

		def coder_from_record(record)
			unless record.nil?
				coder = { :class => record.class }
				record.encode_with(coder)
				coder
			end
		end

		def record_from_coder(coder)
			record = coder[:class].allocate
			record.init_with(coder)
		end

		def write_to_cache(key, value)
			unless value.is_a?(Array)
				coder = coder_from_record(value)
			else
				coder = value.map {|obj| coder_from_record(obj) }
			end
			
			Rails.cache.write(key, coder)
			coder
		end

		def read_from_cache(key)
			coder = Rails.cache.read(key)
			return nil if coder.nil?
			
			unless coder.is_a?(Array)
				record_from_coder(coder)
			else
				coder.map { |obj| record_from_coder(obj) }
			end
		end
	end
end