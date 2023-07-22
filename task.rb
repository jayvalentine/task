# Container for tasks.
class TaskContainer
    def initialize()
        @now = nil
        @next = nil
        @soon = []
        @later = []
    end

    def now; @now; end
    def next; @next; end

    def soon; @soon; end
    def later; @later; end
end
