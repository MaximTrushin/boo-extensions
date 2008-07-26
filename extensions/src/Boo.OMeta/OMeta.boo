namespace Boo.OMeta

import Boo.Adt

interface OMetaInput:
	
	IsEmpty as bool:
		get
	
	Head as object:
		get
		
	Tail as OMetaInput:
		get
		
data OMetaMatch(Input as OMetaInput) = SuccessfulMatch(Value as object) | FailedMatch()

class StringInput(OMetaInput):
	
	final _input as string
	final _position as int
	
	def constructor(input as string):
		_input = input
	
	def constructor(input as string, position as int):
		_input = input
		_position = position
		
	IsEmpty:
		get: return _position >= _input.Length
		
	Head:
		get: return _input[_position]
		
	Tail:
		get: return StringInput(_input, _position+1)
		
	override def ToString():
		return "StringInput(${(null if IsEmpty else 'Head: ' + Head)})"


def any(input as OMetaInput) as OMetaMatch:
	if input.IsEmpty: return FailedMatch(input)
	return SuccessfulMatch(input.Head, input.Tail)
	
def character(input as OMetaInput, expected as char) as OMetaMatch:
	if not input.IsEmpty and expected.Equals(input.Head):
		return SuccessfulMatch(input.Tail, input.Head)
	return FailedMatch(input)
	
def string_(input as OMetaInput, expected as string) as OMetaMatch:
	for ch in expected:
		m = character(input, ch)
		if m isa FailedMatch: return m
		input = m.Input
	return SuccessfulMatch(input, expected)
