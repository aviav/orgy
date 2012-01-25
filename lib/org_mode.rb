require "org_mode/version"

module OrgMode
  # Your code goes here...
  class FileParser
    NodeTitle = %r{ 
      ^   # beginning of line
      (
      \*+ # multiple stars 
      \s+ # one or more whitespace
      .*  # anything
      )
      $   # untill end of line
    }xs

    class << self

      def parse(buffer)
        beginning_of_file, nodes, ending_of_file =
          parse_into_tokens(buffer)
        tokens = buffer.split(NodeTitle)
        OrgMode::File.new
      end


      # Private: splits buffer into different parts
      #   First part is beginning of file
      #   Second part are the nodetitles in combination
      #   with the content
      #   Third part is the ending of the file
      # 
      # buffer - org mode data
      #
      # Returns beginning_of_file, nodes, and ending
      #   if beginning is not present and empy string is 
      #   returned. This function will never return nil
      # 
      def parse_into_tokens buffer
        tokens = buffer.split(NodeTitle).map(&:rstrip)
        beginning_of_file = tokens.shift || ''

        nodes = []
        while !tokens.empty?
          nodes << Array.new(2) { tokens.shift }
        end

        nodes.map! { |t,c| [t,c[1..-1] || ''] }

        [ beginning_of_file, nodes, "" ]
      end

      def grab_until_first_node
        @buffer.take
      end

      def grab_all_nodes
      end

      def grab_last_node_until_end
      end
    end
end

class File
end

class Node
end
end
