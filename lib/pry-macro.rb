require "pry-macro/version"
require 'pry'

module PryMacro
  MacroString = Struct.new(:name, :command)

  Pry::Commands.create_command 'macro-start' do
    def options(opts)
      opts.banner <<-BANNER
      Starts recording a macro.

      Usage: macro-start name [-d desc], [-v]

      Starts recording a macro, have to provide a macro name to be execute as command later.
      Descriptions may be provided, but will default to 'no description'.
    BANNER
      opts.on :d, :desc, "Description of the macro.",
        optional_argument: true, as: String
      opts.on :v, :verbose, "Echoes back the macro definition."
    end

    def process
      raise Pry::CommandError, "The command '#{command_name}' must specify macro name!" if args.empty?

      # Define a few extra ivars on the current pry session so we can persist some state to use
      unless _pry_.instance_variable_defined?(:@record_stack)
        _pry_.class.class_eval 'attr_accessor :record_stack, :macro_strings, :pry_macro_options', __FILE__, __LINE__
        _pry_.record_stack = []
        _pry_.macro_strings = []
        _pry_.pry_macro_options = {name: args.first, desc: opts[:desc], verbose: opts[:verbose]}
      end

      # By using a stack we can potentially have multiple sessions going. Use at your own peril though...
      _pry_.record_stack << Pry.history.session_line_count
    end
  end

  Pry.commands.create_command 'macro-stop' do
    def options(opts)
      opts.banner <<-BANNER
        Stops recording macro.

        Usage: macro-stop

        Stops recording a macro, loads the command, and caches it for later saving if desired.
      BANNER
    end

    def setup
      if !_pry_.instance_variable_defined?(:@record_stack) && _pry_.record_stack.empty?
        raise 'Cannot stop macro when macro is not start.'
      end

      session_begin = _pry_.record_stack.pop
      session_end   = Pry.history.session_line_count

      # Get the history between the start and end of the recording session
      session_history = Pry.history.to_a.last(session_end - session_begin)[0..-2].reject! {|e| e == 'edit' }
      @history = session_history.each_with_object(StringIO.new) {|history, io| io.puts(history) }
    end

    def process
      # Have to have a name to execute this later
      opts = _pry_.pry_macro_options

      # ppp opts.arguments.first
      name = opts[:name]
      desc = opts[:desc] || 'no description'

      history_lines = @history.string.lines.map { |s| "      #{s}"}.join.chomp.tap { |h|
        h.sub!(/^ {6}/, '') # First line won't need the spacing
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

      puts command_string if opts[:verbose]

      # ...so that we can save the contents for saving later (optional)
      _pry_.macro_strings << MacroString.new(name, command_string)
      # ...as well as evaluating it and making it immediately usable to us.
      eval command_string
    end
  end

  Pry.commands.create_command 'macro-save' do
    def options(opts)
      opts.banner <<-BANNER
        Save cached macro.

        Usage: macro-save name

        Saves a cached macro to your ~/.pry-macro.
      BANNER
    end

    def process
      raise 'No Macros are defined!' unless _pry_.instance_variable_defined?(:@macro_strings)
      raise Pry::CommandError, "The command '#{command_name}' must specify a macro name to execute later!" if args.empty?

      path  = Dir.home
      macro = _pry_.macro_strings.find(
        # If nothing is found, raise the error
        -> { raise "Command #{args.first} not found!" }
      ) { |m| m.name == args.first }

      dot_pryrc = File.readlines("#{Dir.home}/.pryrc")

      if dot_pryrc.grep(%r{^\s*load \"\#\{Dir.home\}/\.pry-macro\"}).empty?
        File.open(File.join(path, '.pryrc'), 'a') { |f| f.puts '', 'load "#{Dir.home}/.pry-macro"' }
      end

      # Append new macro to ~/.pry-macro
      File.open(File.join(path, '.pry-macro'), 'a') { |f| f.puts '', macro.command }
    end
  end
end
