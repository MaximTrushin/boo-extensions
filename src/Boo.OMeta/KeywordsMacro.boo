namespace Boo.OMeta

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro keywords:
"""
Generates an accessor rule for each string keyword. The generated code
relies on the existence of a parametrized keyword rule.

From:
	
	keywords "foo", "bar"
	
it generates:

	keywords = FOO | BAR
	FOO = ((KW >> t) and ("foo" is tokenValue(t))) ^ t
	BAR = ((KW >> t) and ("bar" is tokenValue(t))) ^ t
"""

	block as Block = keywords.ParentNode

	rules = []
	for keyword in keywords.Arguments:
		match keyword:
			case StringLiteralExpression(Value: name):
				keywordRule = ReferenceExpression(Name: name.ToUpper())
				block.Add([| $keywordRule = ((KW >> t) and ($keyword is tokenValue(t))) ^ t |])
				rules.Add(keyword)
		
	block.Add([| keywords = $(choicesRuleFrom(rules)) |])
	
def choicesRuleFrom(rules as List):
	rule as Expression = rules[0]
	for name as Expression in rules[1:]:
		rule = [| $rule | $name |]
	return rule
