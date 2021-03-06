module Cacheable
  module Keys

    def self.included(base)
      base.extend(Cacheable::Keys::ClassKeys)
      base.send :include, Cacheable::Keys::InstanceKeys
    end

    module ClassKeys

      def attribute_cache_key(attribute, value)
        "#{cacheable_table_name}/attribute/#{attribute}/#{URI.escape(value.to_s)}"
      end

      def all_attribute_cache_key(attribute, value)
        "#{cacheable_table_name}/attribute/#{attribute}/all/#{URI.escape(value.to_s)}"
      end

      def class_method_cache_key(meth, *args)
        key = "#{cacheable_table_name}/class_method/#{meth}"
        args.flatten!
        key += "/#{args.join('+')}" if args.any?
        return key
      end

      def instance_cache_key(param)
        "#{cacheable_table_name}/#{param}"
      end

      def cacheable_table_name
        self.base_class.name.tableize
      end

    end

    module InstanceKeys

      def model_cache_keys
        ["#{self.class.cacheable_table_name}/#{self.id.to_i}", "#{self.class.cacheable_table_name}/#{self.to_param}"]
      end

      def model_cache_key
        "#{self.class.cacheable_table_name}/#{self.id.to_i}"
      end

      def method_cache_key(meth)
        "#{model_cache_key}/method/#{meth}"
      end

      # Returns nil if association cannot be qualified
      def belong_association_cache_key(name, polymorphic=nil)
        name = name.to_s if name.is_a?(Symbol)

        if polymorphic && self.respond_to?(:"#{name}_type")
          return nil unless self.send(:"#{name}_type").present?
          "#{base_class_or_name(self.send(:"#{name}_type"))}/#{self.send(:"#{name}_id")}"
        else
          "#{base_class_or_name(name)}/#{self.send(:"#{name}_id")}"
        end
      end

      def have_association_cache_key(name)
        "#{model_cache_key}/association/#{name}"
      end

      # If it isa class.  It should be the base_class name
      # else it should just be a name tableized
      def base_class_or_name(name)
        name = begin
          name.capitalize.constantize.base_class.name
        rescue NameError # uninitialized constant
          name
        end
        name.tableize
      end

    end

  end
end