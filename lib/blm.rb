module BLM
	class Document
		def initialize(source)
			@source = source
		end
		
		def header
			return @header if defined?(@header)
		
			@header = {}
			get_contents(@source, "#HEADER#", "#").each_line do |line|
				next if line.blank?
				key, value = line.split(":")
				@header[key.downcase.strip.to_sym] = value.gsub(/'/, "").strip
			end
			return @header
		end
	
		def definition
			return @definition if defined?(@definition)
		
			@definition = []
			get_contents(@source, "#DEFINITION#", "#DATA#").split(header[:eor]).first.split(header[:eof]).each do |field|
				next if field.empty?
				@definition << field.downcase.strip
			end
      # puts @definition.inspect
			return @definition
		end
	
		def data
			return @data if defined?(@data)
      # puts "EOR: '#{header[:eor]}'"
			@data = []
			# get_contents(@source, "#DATA#", "#END#").split(header[:eor]).each do |line|
			get_contents(@source, "#DATA#", "#END#").split(/#{Regexp.escape(header[:eor])}.{0,1}$/).each do |line|
      # puts "LINE: #{line}"
      # puts "DEFINITION: #{definition.inspect}"
				entry = {}
				line.split(header[:eof]).each_with_index do |field, index|
          # puts "FIELD: #{field}, INDEX: #{index}"
					entry[definition[index].to_sym] = field.strip
				end
				@data << Row.new(entry)
			end
			return @data
		end
	
		private
		def get_contents(string, start, finish)
			start = string.index(start) + start.size
			finish = string.index(finish, start) - 1 # - finish.size
			string[start..finish].strip
		end
	end
	
	class Row
		attr_accessor :attributes
		
		def initialize(hash)
			@attributes = hash
		end
	
		def method_missing(method, *arguments, &block)
			return @attributes[method] unless @attributes[method].nil?
		end
	end
end
