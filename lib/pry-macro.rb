require "pry-macro/version"
require 'highline/import'
require 'pry'

module PryMacro
  MacroString = Struct.new(:name, :command)

  Commands = Pry::CommandSet.new do
    create_command 'record-macro', 'Starts a recording session' do
      banner <<-BANNER
        Usage: record-macro

        Starts recording a macro.
      BANNER

      def process
        # Define a few extra ivars on the current pry session so we can persist some state to use
        unless _pry_.instance_variable_defined?(:@record_stack)
          _pry_.instance_variable_set(:@record_stack, [])
          _pry_.instance_variable_set(:@macro_strings, [])
          _pry_.class.class_eval 'attr_accessor :record_stack, :macro_strings'
        end

        # By using a stack we can potentially have multiple sessions going. Use at your own peril though...
        _pry_.record_stack << Pry.history.session_line_count
      end
    end

    create_command 'stop-macro', 'Stops a recording session, and saves a macro' do
      banner <<-BANNER
        Usage: stop-macro [-n name] [-d desc]

        Stops recording a macro, loads the command, and caches it for later saving if
        desired. If no name is provided, user will be prompted for one. Descriptions 
        may be provided, but will default to 'no description'
      BANNER

      def setup
        if !_pry_.instance_variable_defined?(:@record_stack) && _pry_.record_stack.empty?
          raise 'Cannot stop recording when no recorder is running'
        end

        session_begin = _pry_.record_stack.pop
        session_end   = Pry.history.session_line_count

        # Get the history between the start and end of the recording session
        @history = 
          Pry.history
             .to_a
             .last(session_end - session_begin - 1)
             .reduce(StringIO.new) { |io, item| io.puts(item); io }
      end

      def options(opts)
        opts.on :n, :name, "Name to use to define the macro",
                           optional_argument: true, as: String
        opts.on :d, :desc, "Description of the macro",
                           optional_argument: true, as: String
        opts.on :v, :verbose, "Echoes back the macro definition"
      end

      def process
        # Have to have a name to execute this later
        name = opts[:n] || ask('Macro Name: ')
        desc = opts[:d] || 'no description'

        history_lines = @history.string.lines.map { |s| "      #{s}"}.join.chomp.tap { |h|
          h.sub!(/^ {6}/,'') # First line won't need the spacing
        }

        # Save the command into a string, and make it look decent
        # Tinge of a heredocs hack
        command_string = <<-COMMAND_STRING.gsub(/^ {10}/, '')
          Pry::Commands.block_command '#{name}', '#{desc}' do
            _pry_.input = StringIO.new(
              <<-MACRO.gsub(/^ {4,6}/, '')
                #{history_lines}
              MACRO
            )
          end
        COMMAND_STRING

        puts command_string if opts[:v]

        # ...so that we can save the contents for saving later (optional)
        _pry_.macro_strings << MacroString.new(name, command_string)
        # ...as well as evaluating it and making it immediately usable to us.
        eval command_string
      end
    end

    create_command 'save-macro', 'Saves a named macro to your .pryrc file on the tail end' do
      banner <<-BANNER
        Usage: save-macro [-p path]

        Saves a cached macro to your ~/.pryrc or the path specified.
      BANNER

      def options(opts)
        opts.on :p, :path, "Pathname to save macro in",
                           optional_argument: true, as: String
      end

      def process
        raise 'No Macros are defined!' unless _pry_.instance_variable_defined?(:@macro_strings)
        raise 'Invalid path!' if opts[:p] && !Dir[opts[:p]]
        raise 'Must specify the macro to save!' if args.empty?

        path  = opts[:p] || Dir.home
        macro = _pry_.macro_strings.find(
          # If nothing is found, raise the error
          -> { raise "Command #{args.first} not found!" }
        ) { |m| m.name == args.first }

        # Append the Pryrc with the macro, leaving blank lines
        File.open(File.join(path, '.pryrc'), 'a') { |f| f.puts '', macro.command, '' }
      end
    end
  end
end

Pry.commands.import PryMacro::Commands
