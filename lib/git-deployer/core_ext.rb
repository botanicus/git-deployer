# coding: utf-8

module Kernel
  def quiet(&block)
    # old_stdout = STDOUT.dup
    # STDOUT.reopen("/dev/null")
    returned = block.call
    # STDOUT.reopen(old_stdout)
    # return returned
  end
  
  def quiet!(&block)
    old_stderr = STDERR.dup
    STDERR.reopen("/dev/null", "a")
    returned = quiet(&block)
    STDERR.reopen(old_stderr)
    return returned
  end
end
