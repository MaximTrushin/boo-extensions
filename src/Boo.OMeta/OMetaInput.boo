namespace Boo.OMeta

import System
import System.Collections
import System.Collections.Specialized

class OMetaInput:

	static def For(enumerable as IEnumerable) as OMetaInput:
		return ForEnumerator(enumerable.GetEnumerator())
		
	static def ForEnumerator(enumerator as IEnumerator) as OMetaInput:
		return ForEnumerator(enumerator, 0)
		
	static def ForEnumerator(enumerator as IEnumerator, position as int) as OMetaInput:
		if enumerator.MoveNext():
			return EnumeratorInput(enumerator, position)
		return EndOfEnumeratorInput(position)
		
	static def Singleton(o) as OMetaInput:
		return OMetaInputCons(o, Empty())
		
	static def Empty():
		return OMetaInput()
	
	protected def constructor():
		pass
		
	virtual IsEmpty as bool:
		get: return true
		
	virtual Head as object:
		get: raise InvalidOperationException()
		
	virtual Tail as OMetaInput:
		get: raise InvalidOperationException()
		
	virtual Position:
		get: return int.MaxValue
	
	virtual def Prepend(argument) as OMetaInput:
		return OMetaInputCons(argument, self)
		
	virtual def SetMemo(key as string, value) as OMetaInput:
		return OMetaInputWithMemo(key, value, self)
		
	virtual def GetMemo(key as string):
		return null
		
	override def ToString():
		return "OMetaInput()"
		
internal class DelegatingInput(OMetaInput):
	
	final _input as OMetaInput
	
	def constructor(input as OMetaInput):
		_input = input
	
	override Head:
		get: return _input.Head
	
	override IsEmpty:
		get: return _input.IsEmpty
		
	override Tail:
		get: return _input.Tail
						
	override Position:
		get: return _input.Position
		
	override def SetMemo(key as string, value):
		return _input.SetMemo(key, value)
		
	override def GetMemo(key as string):
		return _input.GetMemo(key)
		
	override def ToString():
		return _input.ToString()
		
internal class OMetaInputWithMemo(DelegatingInput):
	final _dictionary as ListDictionary
	_tail as OMetaInput

	def constructor(key as string, value, input as OMetaInput):
		super(input)
		_dictionary = ListDictionary()
		_dictionary.Add(key, value)

	protected def constructor(input as OMetaInput, dictionary as ListDictionary):
		self(input, dictionary, null)

	protected def constructor(input as OMetaInput, dictionary as ListDictionary, tail as OMetaInput):
		super(input)
		_dictionary = dictionary
		_tail = tail

	protected def Clone():
		dictionaryCopy = ListDictionary()
		for item as DictionaryEntry in _dictionary:	dictionaryCopy.Add(item.Key, item.Value)
		return OMetaInputWithMemo(_input, dictionaryCopy)

	protected def SetDictionaryEntry(key as string, value):
		_dictionary[key] = value
 	
	override Tail:
		get: return _tail or _tail = OMetaInputMemoTail(self, _input.Tail)

	override def SetMemo(key as string, value) as OMetaInput:
		newInputWithMemo = Clone()
		newInputWithMemo.SetDictionaryEntry(key, value)
		return newInputWithMemo

	override def GetMemo(key as string):
		if _dictionary.Contains(key): return _dictionary[key]
		return _input.GetMemo(key)

	override def Prepend(argument) as OMetaInput:
		return OMetaInputWithMemo(_input.Prepend(argument), _dictionary, self)

internal class OMetaInputMemoTail(DelegatingInput):

	final _parent as OMetaInputWithMemo
	_tail as OMetaInput

	def constructor(parent as OMetaInputWithMemo, input as OMetaInput):
		self(parent, input, null)

	def constructor(parent as OMetaInputWithMemo, input as OMetaInput, tail as OMetaInput):
		super(input)
		_parent = parent
		_tail = tail

	override Tail:
		get: return _tail or _tail = OMetaInputMemoTail(_parent, _input.Tail)

	override def SetMemo(key as string, value) as OMetaInput:
		return OMetaInputMemoTail(_parent.SetMemo(key, value), _input)

	override def GetMemo(key as string):
		return _parent.GetMemo(key)

	override def Prepend(argument) as OMetaInput:
		return OMetaInputMemoTail(_parent, _input.Prepend(argument), self)
		
internal class OMetaInputCons(OMetaInput):
	
	[getter(Head)] _argument as object
	[getter(Tail)] _tail as OMetaInput
	
	def constructor(argument, tail as OMetaInput):
		_argument = argument
		_tail = tail
		
	override Position:
		get: return Tail.Position
		
	override IsEmpty:
		get: return false
		
	override def ToString():
		return "cons($_argument, $_tail)"

internal class EnumeratorInput(OMetaInput):
	
	final _position as int
	final _input as IEnumerator
	final _head as object
	_tail as OMetaInput
	
	internal def constructor(input as IEnumerator, position as int):
		_input = input
		_head = input.Current
		_position = position
		
	override Position:
		get: return _position
		
	override IsEmpty:
		get: return false
		
	override Head:
		get: return _head
	
	override Tail:
		get: return _tail or _tail = ForEnumerator(_input, _position + 1)
		
	override def ToString():
		return "OMetaInput(Head: $Head, Position: $Position)"
		
internal class EndOfEnumeratorInput(OMetaInput):
	
	def constructor(position as int):
		_position = position
		
	[getter(Position)]
	_position as int
