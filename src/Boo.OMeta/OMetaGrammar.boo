namespace Boo.OMeta

import Boo.Adt

data OMetaMatch(Input as OMetaInput) = \
		SuccessfulMatch(Value as object) \
		| FailedMatch(Failure as OMetaFailure) \
		| LR(@detected as bool) // internal use only

data OMetaRule(Memoize as bool, Rule as OMetaRuleCallable)

callable OMetaRuleCallable(context as OMetaEvaluationContext, input as OMetaInput) as OMetaMatch

interface OMetaGrammar:
	
	def InstallRule(ruleName as string, rule as OMetaRule)
	def Apply(context as OMetaEvaluationContext, rule as string, input as OMetaInput) as OMetaMatch
	def GetRule(ruleName as string) as OMetaRule
