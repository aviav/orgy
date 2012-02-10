require 'org_mode/commands/agenda'
require 'tempfile'
require 'core_ext/string'
require 'support/capture_stdout'
require 'support/write_into_tempfile'
require 'timecop'

# Helper to execute agenda and compare the output
def execute_and_compare_stdout_with args, options, expected_output
  output = capture_stdout do
    @org_mode_commands_agenda.execute(args, options)
  end
  output.should == expected_output
end

describe OrgMode::Commands::Agenda do
  before do
    Timecop.freeze('2012-01-01 15:00')

    @org_mode_commands_agenda = OrgMode::Commands::Agenda.new
  end

  context '#execute' do
    context 'when loaded with one file' do
      it 'extracts and displays scheduled tasks correctly' do
        org_file = write_into_tempfile <<-eos.strip_indent(10)
          * TODO Scheduled task <1-1-2012 Wed 15:15>
        eos
        execute_and_compare_stdout_with [org_file.path], stub, <<-eos.strip_indent(10)
          Agenda ()
            2012-01-01
              TODO Scheduled task 
        eos
      end
      it 'ignores unscheduled tasks' do
        org_file = write_into_tempfile <<-eos.strip_indent(10)
          * TODO Scheduled task <1-1-2012 Wed 15:15>
          * TODO UnScheduled task
        eos
        execute_and_compare_stdout_with [org_file.path], stub, <<-eos.strip_indent(10)
          Agenda ()
            2012-01-01
              TODO Scheduled task 
        eos
      end
      it 'ignores done tasks' do
        org_file = write_into_tempfile <<-eos.strip_indent(10)
          * TODO Scheduled task <1-1-2012 Wed 15:15>
          * DONE Completed scheduled task <1-1-2012 Wed 15:15>
        eos
        execute_and_compare_stdout_with [org_file.path], stub, <<-eos.strip_indent(10)
          Agenda ()
            2012-01-01
              TODO Scheduled task 
        eos
      end
    end
    context 'when loaded with two files' do
      it 'displays both in expected format and sorted correctly' do
        org_file = write_into_tempfile <<-eos.strip_indent(10)
          * TODO Scheduled task on the 5th <5-1-2012 Wed 15:15>
        eos
        org_file2 = write_into_tempfile <<-eos.strip_indent(10)
          * TODO Scheduled task on the 1th <1-1-2012 Wed 15:15>
        eos
        execute_and_compare_stdout_with [org_file, org_file2].map(&:path), stub, 
          <<-eos.strip_indent(10)
          Agenda ()
            2012-01-01
              TODO Scheduled task on the 1th 
            2012-01-05
              TODO Scheduled task on the 5th 
        eos
      end
    end
  end
end