# Copied from the DeepStruct gem
# Modified to return Null on unknown key
module DeepStruct
  class HashWrapper < DeepWrapper
    def method_missing(method, *args, &block)
      return @value.send(method, *args, &block) if @value.respond_to?(method)
      method = method.to_s
      if method.chomp!('?')
        key = method.to_sym
        self.has_key?(key) && !!self[key]
      elsif method.chomp!('=')
        raise ArgumentError, "wrong number of arguments (#{arg_count} for 1)", caller(1) if args.length != 1
        self[method] = args[0]
      elsif args.length == 0 && self.has_key?(method)
        self[method]
      else
        Hem::Null.new
      end
    end

    def to_hash_sym
      unwrap.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end
  end
end
