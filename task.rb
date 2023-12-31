#!/usr/bin/ruby

require 'yaml'

# Provides a view over a slice of an array.
class ArrayView
    def initialize(array, start_index)
        @array = array
        @start_index = start_index
    end

    # Appends an element to the end of the underlying array.
    def <<(value)
        @array << value
    end

    # Indexes into the underlying array.
    def [](index)
        held_slice()[index]
    end

    # Returns true if the held slice of the underlying array is empty,
    # false otherwise.
    def empty?
        held_slice.empty?
    end

    # Returns size of the held slice of the underlying array.
    def size
        held_slice.size
    end

    # Executes block for each element of held slice.
    def each(&block)
        held_slice.each(&block)
    end

    # Read-only view of underlying array
    def held_slice
        if @array.size < @start_index
            []
        else
            @array[@start_index..-1]
        end
    end
    private :held_slice
end

# Container for tasks.
class TaskContainer
    def initialize()
        @high_prio = []
        @low_prio = []
        
        # Any high-prio task that is not "now" or "next"
        # is "soon".
        @soon = ArrayView.new(@high_prio, 2)

        @later = ArrayView.new(@low_prio, 0)
    end

    def self.from_h(h)
        t = self.new
        t.now = h[:now] unless h[:now].nil?
        t.next = h[:next] unless h[:next].nil?
        h[:soon].each { |task| t.soon << task }
        h[:later].each { |task| t.later << task }

        t
    end

    def to_h
        h = {}
        h[:now] = @high_prio[0] unless @high_prio.size < 1
        h[:next] = @high_prio[1] unless @high_prio.size < 2
        
        h[:soon] = if @high_prio.size < 3
            []
        else
            @high_prio[2..-1]
        end

        h[:later] = @low_prio
        
        h
    end

    # The task that needs to be done now - i.e. is "in progress"
    # (or about to be).
    #
    # Only one task can be "now" - because you can only do one thing at once.
    # Setting "now" when another task is already "now" makes the existing task "next"
    def now; @high_prio[0]; end
    def now=(s)
        raise "Invalid task: '#{s.inspect}'" unless s.is_a? String
        @high_prio.unshift(s)
    end

    # The task that needs to be done next (after "now")
    #
    # Only one task can be "next" - because time is linear.
    # Setting "next" when another task is already "next" makes the existing task "soon"
    def next; @high_prio[1]; end
    def next=(s)
        raise "Invalid task: '#{s.inspect}'" unless s.is_a? String

        # Insert task into second place in array, or first if array is empty.
        if @high_prio.empty?
            @high_prio << s
        else
            @high_prio.insert(1, s)
        end
    end

    def soon; @soon; end
    def later; @later; end

    FindResult = Struct.new("FindResult", :result, :tasks)

    # Marks the task with the given keywords as done.
    # Returns a FindResult indicating the result of the operation.
    def done(keyword_string)
        matching_index_high_prio, matching_index_low_prio = find_tasks(keyword_string)

        # Result is true if exactly one task matched the keywords.
        result = (matching_index_high_prio.size + matching_index_low_prio.size) == 1

        tasks =  matching_index_high_prio.map { |i| @high_prio[i] }
        tasks += matching_index_low_prio.map  { |i| @low_prio[i] }

        # Only mark tasks as done if result is true.
        if result
            if matching_index_high_prio.size == 1
                @high_prio.delete_at(matching_index_high_prio.first)
            elsif matching_index_low_prio.size == 1
                @low_prio.delete_at(matching_index_low_prio.first)
            end
        end

        FindResult.new(result, tasks)
    end

    # Bumps the task with the given keywords to 'now'.
    # Returns a FindResult indicating the result of the operation.
    def bump(keyword_string)
        matching_index_high_prio, matching_index_low_prio = find_tasks(keyword_string)

        # Result is true if exactly one task matched the keywords.
        result = (matching_index_high_prio.size + matching_index_low_prio.size) == 1

        tasks =  matching_index_high_prio.map { |i| @high_prio[i] }
        tasks += matching_index_low_prio.map  { |i| @low_prio[i] }

        # Only bump if result was successful.
        if result
            t = if matching_index_high_prio.size == 1
                @high_prio.delete_at(matching_index_high_prio.first)
            elsif matching_index_low_prio.size == 1
                @low_prio.delete_at(matching_index_low_prio.first)
            end

            self.now = t
        end

        FindResult.new(result, tasks)
    end

    # Finds tasks that match given keyword string.
    def find_tasks(keyword_string)
        matching_index_high_prio = []
        matching_index_low_prio = []

        @high_prio.each_with_index do |s, i|
            if keyword_match(s, keyword_string)
                matching_index_high_prio << i
            end
        end

        @low_prio.each_with_index do |s, i|
            if keyword_match(s, keyword_string)
                matching_index_low_prio << i
            end
        end

        [matching_index_high_prio, matching_index_low_prio]
    end
    private :find_tasks

    # Returns true if the given string matches the keyword string,
    # and false otherwise.
    def keyword_match(s, keyword_string)
        s = s.split
        keyword_string.split.all? { |kw| s.include?(kw) }
    end
    private :keyword_match
end

def get_task
    ARGV[1..-1].join(" ")
end

def usage
    puts "usage: task <command> [<task>]"
    puts ""
    puts "commands for adding a new task:"
    puts "    now:    add a new task to do right now"
    puts "    next:   add a new task to do next"
    puts "    soon:   add a new task to do soon"
    puts "    later:  add a new task to do later"
    puts ""
    puts "for interacting with existing tasks:"
    puts "    status: display current tasks"
    puts "    done:   mark task as done"
    puts "    bump:   mark task as highest priority"
    puts ""
    puts "other commands:"
    puts "    help:   display this text"
    puts ""
end

def status(tasks)
    puts FORMATTER.new(tasks).result()
end

if $0 == __FILE__
    require_relative 'plain_formatter'
    require_relative 'color_block_formatter'

    # Should have at least one argument.
    if ARGV.size < 1
        usage()
        exit 1
    end

    FORMATTERS = {
        "plain" => PlainFormatter,
        "color" => ColorBlockFormatter
    }
    
    COMMAND = ARGV[0]
    TASKDIR = ENV["TASKDIR"] || abort("TASKDIR is not set")
    TASKFILE = File.join(TASKDIR, "tasks.yaml")
    TASKCONFIG = YAML::load(File.read(File.join(TASKDIR, "taskconfig.yaml")))

    FORMATTER = FORMATTERS[TASKCONFIG["formatter"]]

    # Load current tasks from YAML file if it exists.
    tasks = if File.exist?(TASKFILE)
        TaskContainer::from_h(YAML::load(File.read(TASKFILE)))
    else
        TaskContainer.new
    end

    # Perform the user's command.
    if COMMAND == "help"
        usage()
        exit 0
    elsif COMMAND == "now"
        tasks.now = get_task()
    elsif COMMAND == "next"
        tasks.next = get_task()
    elsif COMMAND == "soon"
        tasks.soon << get_task()
    elsif COMMAND == "later"
        tasks.later << get_task()
    elsif COMMAND == "status"
        # status displayed below so this command doesn't do anything in particular.
        # it's in the list here so that the tool doesn't error.
    elsif COMMAND == "done"
        kw = get_task()
        result = tasks.done(kw)
        if result.result
            puts "task '#{result.tasks.first}' done"
        elsif result.tasks.empty?
            puts "no task matching keywords '#{kw}'"
        else
            puts "multiple tasks matching '#{kw}':"
            result.tasks.each do |t|
                puts "    #{t}"
            end
        end
        puts ""
    elsif COMMAND == "bump"
        kw = get_task()
        result = tasks.bump(kw)
        if result.result
            puts "task '#{result.tasks.first}' bumped"
        elsif result.tasks.empty?
            puts "no task matching keywords '#{kw}'"
        else
            puts "multiple tasks matching '#{kw}':"
            result.tasks.each do |t|
                puts "    #{t}"
            end
        end
        puts ""
    else
        puts "unknown command '#{COMMAND}'"
        puts ""

        usage()
        exit 1
    end

    status(tasks)

    # Save current tasks back to YAML file.
    File.write(TASKFILE, YAML::dump(tasks.to_h))
end
