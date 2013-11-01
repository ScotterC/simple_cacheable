module Cacheable
	
	module ClassMethods
			
		def fetch(id, &block)
			model_cache_key = [name.tableize, id.to_s].join("/")
			result = self.new.read_from_cache(model_cache_key)

			if result.nil?
				result = block_given? ? yield : self.find(id)
				self.new.write_to_cache(model_cache_key, result)
			end
			result
		end
	end

	module ModelFetch

		def fetch_association(object, association_name, options={}, &block)
			if options[:belongs_to]
				cache_key = belong_association_cache_key(association_name, options[:polymorphic])
			else
				cache_key = have_association_cache_key(association_name)
			end

			association_cache.delete(association_name)
			result = read_from_cache(cache_key)
			
			if result.nil?
				result = block_given? ? yield : object.send(association_name)
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
			if value.respond_to?(:to_a)
				value = value.to_a
				coder = value.map {|obj| coder_from_record(obj) }
			else
				coder = coder_from_record(value)
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