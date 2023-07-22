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

    # Setting #now when not empty should push that task
    # into #next
    def test_now_when_full
        t = TaskContainer.new
        t.now = "a new task"
        t.now = "another new task"

        assert_equal("another new task", t.now)
        assert_equal("a new task", t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting #next when empty should not change any other properties.
    def test_next_when_empty
        t = TaskContainer.new
        t.now = "a new task"
        t.next = "another new task"

        assert_equal("a new task", t.now)
        assert_equal("another new task", t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting #next when not empty should push the existing task
    # into #soon
    def test_next_when_empty
        t = TaskContainer.new
        t.next = "next task"
        t.next = "oops need to do something else first"

        assert_nil(t.now)
        assert_equal("oops need to do something else first", t.next)
        
        assert_equal(1, t.soon.size)
        assert_equal("next task", t.soon[0])

        assert_true(t.later.empty?)
    end

    # Setting #next when not empty should push the existing task
    # into #soon. Here we make sure that task is the first one in #soon
    def test_next_when_not_empty_first_soon
        t = TaskContainer.new
        t.soon << "needs doing soon"
        t.next = "needs doing next"
        t.next = "oops need to do something else first"

        assert_nil(t.now)
        assert_equal("oops need to do something else first", t.next)

        assert_equal(2, t.soon.size)
        assert_equal("needs doing next", t.soon[0])
        assert_equal("needs doing soon", t.soon[1])
    end

    # Tests that tasks can be loaded from hash.
    def test_from_hash
        h = {
            now: "current task",
            next: "next task",
            soon: [
                "one task",
                "two task"
            ],
            later: [
                "three task",
                "four task"
            ]
        }

        t = TaskContainer::from_h(h)

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        
        assert_equal(2, t.soon.size)
        assert_equal("one task", t.soon[0])
        assert_equal("two task", t.soon[1])

        assert_equal(2, t.later.size)
        assert_equal("three task", t.later[0])
        assert_equal("four task", t.later[1])
    end
end
