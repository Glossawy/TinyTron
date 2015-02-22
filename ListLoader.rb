module ListLoader

	YAML_TYPE = "yml"
	CSV_TYPE = "csv"
	END_LINE_TYPE = "endline"

	def load_list(file)
		raise NotImplementedError, "ListLoader Mixin Not Implemented Properly!", caller
	end

	def get_list_type
		raise NotImplementedError, "ListLoader Mixin Not Implemented Properly!", caller
	end

	def is_valid?(file)
		return get_list_type == END_LINE_TYPE || file.downcase.include?(get_list_type)
	end
end

class CSVLoader
	include ListLoader

	attr_reader :list

	def initialize
		@list = []
	end

	def load_list(file)
		File.open(file) do |f|
			lines = f.readlines

			lines.each do |line|
				elements = line.split ','
				elements.select{|e| !e.empty?}.each do |e|
					@list.push(e)
				end
			end
		end
	end

	def get_list_type
		return ListLoader::CSV_TYPE
	end
end

class LineLoader
	include ListLoader

	attr_reader :list

	def initialize
		@list = []
	end

	def load_list(file)
		File.open(file) do |f|
			lines = f.readlines

			lines.each do |line|
				elements = line.split $/
				elements.select{|e| !e.empty?}.each do |e|
					@list.push(e)
				end
			end
		end
	end

	def get_list_type
		return ListLoader::END_LINE_TYPE
	end
end

class YAMLLoader
	require 'yaml'
	include ListLoader

	attr_reader :list

	def initialize
		@list = []
	end

	def load_list(file)
		File.open(file) do |f|
			data = YAML.load(f)

			data.players.each { |player| @list.push player }
		end
	end

	def get_list_type
		return ListLoader::YAML_TYPE
	end
end