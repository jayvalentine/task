require_relative '../task.rb'

require 'test/unit'

class TaskTest < Test::Unit::TestCase
    # When a new TaskContainer is generated...
    #
    # #now should be nil (no task)
    # #next should be nil (no task)
    # #soon should be empty (no tasks)
    # #later should be empty (no tasks)
    #
    def test_empty
        t = TaskContainer.new
        assert_nil(t.now)
        assert_nil(t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting TaskContainer #now when empty
    # should not change any other properties.
    def test_now_when_empty
        t = TaskContainer.new
        t.now = "a task i need to do now"

        assert_equal("a task i need to do now", t.now)
        assert_nil(t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end
end
