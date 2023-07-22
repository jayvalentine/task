# Container for tasks.
class TaskContainer
    def initialize()
        @now = nil
        @next = nil
        @soon = []
        @later = []
    end

    # The task that needs to be done now - i.e. is "in progress"
    # (or about to be).
    #
    # Only one task can be "now" - because you can only do one thing at once.
    # Setting "now" when another task is already "now" makes the existing task "next"
    def now; @now; end
    def now=(s)
        if @now.nil?
            @now = s
        end
    end

    def next; @next; end

    def soon; @soon; end
    def later; @later; end
end
