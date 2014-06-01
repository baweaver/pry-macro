# require 'spec_helper'

# Need to find a more effective way to spec this all out. There are some nuances I haven't quite
# grasped in mocking out pry commands. As soon as I can figure out the last few bits this will
# get built on Travis and put under a bit more process.

# describe 'PryMacro' do
#   before :all do
#     @str_output = StringIO.new

#     @t = pry_tester do
#       def insert_nil_input
#         @pry.update_input_history(nil)
#       end

#       def last_exception=(e)
#         @pry.last_exception = e
#       end
#     end

#     _pry_.stub(
#       input: @t.pry.input
#     )

#     @t.eval 'record'
#     @t.pry.input = StringIO.new('1')
#     binding.pry
#     @t.eval 'stop -n test_macro'
#   end

#   describe '#record' do
#     it 'sets instance variables on @t.pry' do
#       expect(@t.pry.instance_variable_defined?(:@record_stack)).to be_true
#       expect(@t.pry.instance_variable_defined?(:@macro_strings)).to be_true
#     end
#   end

#   describe '#stop' do
#     context 'Record stack is empty' do
#       before { @t.pry.stub(record_stack: []) }

#       it 'raises an error' do
#         expect { @t.eval 'stop' }.to raise_error()
#       end
#     end

#     context 'Record stack present' do
#       it 'pops the start from the record stack' do
#         expect(@t.pry.record_stack.empty?).to be_true
#       end

#       it 'creates a the macro' do
#         expect(@t.eval 'test_macro').to be(1)
#       end

#       it 'caches the macro in @macro_strings' do
#         expect(@t.pry.macro_strings.first.name).to be ('test_macro')
#       end
#     end
#   end

  # describe '#save-macro' do
  #   context 'No Macros are defined' do
  #     before { @t.pry.stub(macro_strings: [])}

  #     it 'raises an error' do
  #       expect { @t.eval 'save' }.to raise_error()
  #     end
  #   end

  #   context 'Macros are defined' do
  #     it 'saves the macro to .pryrc' do
  #       fake_file = StringIO.new
  #       File.stub(puts: fake_file)

  #       @t.eval 'save'

  #       expect(fake_file.string).to_not be_empty
  #     end
  #   end
  # end
# end
