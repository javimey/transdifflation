module Transdifflation

  # Writes YAML
  class YAMLWriter

    #Method used to prettify generated YAML
    def self.to_yaml(hash)
      method = hash.respond_to?(:ya2yaml) ? :ya2yaml : :to_yaml
      string = hash.deep_stringify_keys.send(method)
      yaml_string = string.gsub("!ruby/symbol ", ":").sub("---","")
      yaml_string = yaml_string.gsub(/(\?) "([\w\s\\]+)"\n/) do |match|
        match.sub(/\?\s+/, "").chomp
      end
      yaml_string = yaml_string.split("\n").map(&:rstrip).join("\n").strip
    end
  end
end

#Method used to prettify generated YAML. Expands Hash class
class Hash
  # Convert keys into strings recursively
  def deep_stringify_keys
    new_hash = {}
    self.each do |key, value|
      new_hash.merge!(key.to_s => (value.is_a?(Hash) ? value.deep_stringify_keys : value))
    end
  end
end
