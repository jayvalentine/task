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
        @array[@start_index + index]
    end

    # Returns true if the held slice of the underlying array is empty,
    # false otherwise.
    def empty?
        @array.size <= @start_index
    end

    # Returns size of the held slice of the underlying array.
    def size
        size = @array.size - @start_index
        size = 0 if size < 0
        size
    end
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
        @high_prio.insert(1, s)
    end

    def soon; @soon; end
    def later; @later; end
end

def get_task
    ARGV[1..-1].join(" ")
end

if $0 == __FILE__
    # Should have at least one argument.
    if ARGV.size < 1
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

        exit 1
    end

    COMMAND = ARGV[0]
    TASKFILE = "tasks.yaml"

    # Load current tasks from YAML file if it exists.
    tasks = if File.exist?(TASKFILE)
        TaskContainer::from_h(YAML::load(File.read(TASKFILE)))
    else
        TaskContainer.new
    end

    # Perform the user's command.
    if COMMAND == "now"
        tasks.now = get_task()
    elsif COMMAND == "next"
        tasks.next = get_task()
    elsif COMMAND == "soon"
        tasks.soon << get_task()
    elsif COMMAND == "later"
        tasks.later << get_task()
    elsif COMMAND == "status"
        puts "now:   #{tasks.now}"
        puts "next:  #{tasks.next}"
        puts ""

        puts "soon:"
        tasks.soon.each  { |t| puts "       #{t}" }
        puts "later:"
        tasks.later.each { |t| puts "       #{t}" }
    end

    # Save current tasks back to YAML file.
    File.write(TASKFILE, YAML::dump(tasks.to_h))
end
