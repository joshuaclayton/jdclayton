module Fusionary
  module Util
    module Text
      def add_text(text, options)
        original_lines = File.readlines options[:to]
        new_lines = Array.new

        new_lines << text if options[:before] == :end or options[:after] == :start
        for line in original_lines
          if line =~ options[:before]
            new_lines << text
            new_lines << line
          elsif line =~ options[:after]
            new_lines << line
            new_lines << text
          else
            new_lines << line
          end
        end
        new_lines << text if options[:before] == :end or options[:after] == :end

        File.open(options[:to], "w") do |file|
          new_lines.each { |line| file.puts line }
        end
      end
    end
  end
end