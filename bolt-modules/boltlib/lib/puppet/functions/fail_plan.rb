# frozen_string_literal: true

require 'bolt/error'

# Raises a Bolt::PlanFailure exception to signal to callers that the plan failed.
#
# Plan authors should call this function when their plan is not successful. The
# error may then be caught by another plans run_plan function or in bolt itself
Puppet::Functions.create_function(:fail_plan) do
  # Fail a plan, generating an exception from the parameters.
  # @param msg An error message.
  # @param kind An easily matchable error kind.
  # @param details Machine-parseable details about the error.
  # @param issue_code Unused.
  # @return Raises an exception.
  # @example Raise an exception
  #   fail_plan('We goofed up', 'task-unexpected-result', { 'result' => 'null' })
  dispatch :from_args do
    param 'String[1]', :msg
    optional_param 'String[1]', :kind
    optional_param 'Hash[String[1], Any]', :details
    optional_param 'String[1]', :issue_code
  end

  # Fail a plan, generating an exception from an existing Error object.
  # @param error An error object.
  # @return Raises an exception.
  # @example Raise an exception
  #   fail_plan(Error('We goofed up', 'task-unexpected-result', { 'result' => 'null' }))
  dispatch :from_error do
    param 'Error', :error
  end

  def from_args(msg, kind = nil, details = nil, issue_code = nil)
    executor = Puppet.lookup(:bolt_executor) { nil }
    executor&.report_function_call('fail_plan')

    raise Bolt::PlanFailure.new(msg, kind || 'bolt/plan-failure', details, issue_code)
  end

  def from_error(err)
    from_args(err.message, err.kind, err.details, err.issue_code)
  end
end
