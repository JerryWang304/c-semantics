module C-TYPING-COMMON-SYNTAX
     imports LIST
     imports BASIC-K
     imports C-TYPING-SORTS
     imports COMMON-SORTS

     // Function id, def return type, def params, local declarations, body.
     syntax RValue ::= functionObject(CId, Type, List, K)

endmodule

module C-TYPING-COMMON
     imports C-CONFIGURATION
     imports K-REFLECTION
     imports C-SETTINGS-SYNTAX
     imports C-TYPING-SYNTAX
     imports FLOAT

     rule type(T:Type) => T
     rule type(typedDeclaration(T::Type, _)) => T
     rule type(T:SimpleType) => t(noQuals, .Set, T)
     rule type(T:SimpleArrayUType) => t(noQuals, .Set, qualSimple(T))
     rule type(ut(Mods::Set, T::SimpleUType)) => t(noQuals, Mods, qualSimple(T))

     rule utype(t(_, Mods::Set, T::SimpleType)) => ut(Mods, unqualSimple(T))
     rule utype(typedDeclaration(T::Type, _)) => utype(T)
     rule utype(T:SimpleType) => ut(.Set, unqualSimple(T))
     rule utype(T:SimpleArrayUType) => ut(.Set, T)
     rule utype(T:UType) => T

     syntax SimpleUType ::= unqualSimple(SimpleType) [function]
     rule unqualSimple(arrayType(T::Type, N::Int))
          => arrayUType(utype(T), N)
     rule unqualSimple(incompleteArrayType(T::Type))
          => incompleteArrayUType(utype(T))
     rule unqualSimple(flexibleArrayType(T::Type))
          => flexibleArrayUType(utype(T))
     rule unqualSimple(unspecifiedArrayType(T::Type))
          => unspecifiedArrayUType(utype(T))
     rule unqualSimple(variableLengthArrayType(T::Type, N:K))
          => variableLengthArrayUType(utype(T), N)
     rule unqualSimple(T::SimpleType) => T [owise]

     syntax SimpleType ::= qualSimple(SimpleUType) [function]
     rule qualSimple(arrayUType(T::UType, N::Int))
          => arrayType(type(T), N)
     rule qualSimple(incompleteArrayUType(T::UType))
          => incompleteArrayType(type(T))
     rule qualSimple(flexibleArrayUType(T::UType))
          => flexibleArrayType(type(T))
     rule qualSimple(unspecifiedArrayUType(T::UType))
          => unspecifiedArrayType(type(T))
     rule qualSimple(variableLengthArrayUType(T::UType, N:K))
          => variableLengthArrayType(type(T), N)
     rule qualSimple(T::SimpleUType) => T [owise]

     rule sameAlignas(Mods:Set, Mods':Set)
          => getAlignasMod(Mods) ==Int getAlignasMod(Mods')

     rule getAlignasMod(SetItem(alignas(N::Int)) _) => N
     rule getAlignasMod(_) => -1 [owise]

     rule noQuals => quals(.Set)

     rule Q::Qualifier inQuals quals(Qs::Set) => Q in Qs

     rule quals(Qs::Set) +Qual Q::Qualifier => quals(Qs SetItem(Q))

     rule quals(SetItem(Q) Qs::Set) -Qual Q::Qualifier => quals(Qs)
     rule Qs::Quals -Qual _ => Qs [owise]

     rule quals(Qs::Set) <=Quals quals(Qs'::Set) => Qs <=Set Qs'

     rule quals(Qs::Set) +Quals quals(Qs'::Set) => quals(Qs Qs')

     rule toQuals(SetItem(Q:Qualifier) S::Set) => toQuals(S) +Qual Q
     rule toQuals(SetItem(K::K) S::Set) => toQuals(S)
          requires notBool isQualifier(K)
     rule toQuals(.Set) => noQuals

     rule stripQualifiers(T::Type) => type(utype(T))

     rule getModifiers(ut(S::Set, _)) => S
     rule getModifiers(t(_, S::Set, _)) => S

     rule getTag(tag(S:CId, _, _)) => S

     rule getEnumAlias(S::TagId) => getEnumAlias'(getTagInfo(S))

     syntax SimpleType ::= "getEnumAlias'" "(" TagInfo ")" [function]
     rule getEnumAlias'(enumAlias(T::SimpleType)) => T
     rule getEnumAlias'(_) => no-type [owise]

     rule getFieldInfo(S:TagId) => toFieldInfo(getTagInfo(S))
     rule getFieldInfo(t(_, Mods::Set, structType(S::TagId)))
          => toFieldInfo(getTagInfo(S))
     rule getFieldInfo(t(_, Mods::Set, unionType(S::TagId)))
          => toFieldInfo(getTagInfo(S))
     rule getFieldInfo(_:Type) => toFieldInfo(.K) [owise]

     syntax FieldInfo ::= toFieldInfo(TagInfo) [function]
     rule toFieldInfo(Fields:FieldInfo) => Fields
     rule toFieldInfo(_) => fieldInfo(.List, 0, .Map, .Map, .Set) [owise]

     rule getTagInfo(S:TagId) => #getTagInfo(S, #configuration)

     syntax TagInfo ::= #getTagInfo(TagId, K) [function]
     rule #getTagInfo(tag(X::CId, Tu::String, B::BlockRef), <generatedTop>... <global>... <tags> M::Map </tags> ...</global> ...</generatedTop>)
          => extractTagInfo({M[Tu]}:>Map[tag(X, Tu, B)])
     syntax TagInfo ::= extractTagInfo(K) [function]
     rule extractTagInfo(fieldInfo(L::List, I::Int, M1::Map, M2::Map, S::Set)) => fieldInfo(L, I, M1, M2, S)
     rule extractTagInfo(enumAlias(T::SimpleType)) => enumAlias(T)
     rule extractTagInfo(_) => #incomplete [owise]

     rule numBytes(bool) => cfg:sizeofBool
     rule numBytes(_:SimpleSignedCharType) => cfg:sizeofSignedChar
     rule numBytes(short-int) => cfg:sizeofShortInt
     rule numBytes(int) => cfg:sizeofInt
     rule numBytes(long-int) => cfg:sizeofLongInt
     rule numBytes(long-long-int) => cfg:sizeofLongLongInt

     rule numBytes(float) => cfg:sizeofFloat
     rule numBytes(double) => cfg:sizeofDouble
     rule numBytes(long-double) => cfg:sizeofLongDouble

     rule numBytes(_:SimpleUnsignedCharType) => numBytes(signed-char)
     rule numBytes(unsigned-short-int) => numBytes(short-int)
     rule numBytes(unsigned-int) => numBytes(int)
     rule numBytes(unsigned-long-int) => numBytes(long-int)
     rule numBytes(unsigned-long-long-int) => numBytes(long-long-int)
     rule numBytes(enumType(S::TagId)) => numBytes(getEnumAlias(S))
     rule numBytes(_) => 0 [owise]

     rule typePrecision(ut(_, float)) => cfg:precisionofFloat
     rule typePrecision(ut(_, double)) => cfg:precisionofDouble
     rule typePrecision(ut(_, long-double)) => cfg:precisionofLongDouble
     rule maxFloatPrecision => 237

     rule typeExponent(ut(_, float)) => cfg:exponentofFloat
     rule typeExponent(ut(_, double)) => cfg:exponentofDouble
     rule typeExponent(ut(_, long-double)) => cfg:exponentofLongDouble
     rule maxFloatExponent => 19

     rule roundCFloat(T:FloatUType, F:Float) => roundFloat(F, typePrecision(T), typeExponent(T))
     rule Int2CFloat(T:FloatUType, I:Int) => Int2Float(I, typePrecision(T), typeExponent(T))
     rule zeroCFloat(T:FloatUType) => Int2CFloat(T, 0)

     syntax Int ::= numBits(SimpleType) [function]
     rule numBits(T::SimpleType) => numBytes(T) *Int cfg:bitsPerByte

     rule min(ut(_, bitfieldType(_:SimpleSignedType, N::Int)))
          => 0 -Int (1 <<Int absInt(N -Int 1))
     rule max(ut(_, bitfieldType(_:SimpleSignedType, N::Int)))
          => (1 <<Int absInt(N -Int 1)) -Int 1

     rule min(ut(_, _:SimpleSignedCharType))
          => 0 -Int (1 <<Int absInt(numBits(signed-char) -Int 1))
     rule max(ut(_, _:SimpleSignedCharType))
          => (1 <<Int absInt(numBits(signed-char) -Int 1)) -Int 1
     rule min(ut(_, short-int))
          => 0 -Int (1 <<Int absInt(numBits(short-int) -Int 1))
     rule max(ut(_, short-int))
          => (1 <<Int absInt(numBits(short-int) -Int 1)) -Int 1
     rule min(ut(_, int))
          => 0 -Int (1 <<Int absInt(numBits(int) -Int 1))
     rule max(ut(_, int))
          => (1 <<Int absInt(numBits(int) -Int 1)) -Int 1
     rule min(ut(_, long-int))
          => 0 -Int (1 <<Int absInt(numBits(long-int) -Int 1))
     rule max(ut(_, long-int))
          => (1 <<Int absInt(numBits(long-int) -Int 1)) -Int 1
     rule min(ut(_, long-long-int))
          => 0 -Int (1 <<Int absInt(numBits(long-long-int) -Int 1))
     rule max(ut(_, long-long-int))
          => (1 <<Int absInt(numBits(long-long-int) -Int 1)) -Int 1

     rule min(_:UnsignedIntegerUType) => 0

     rule max(ut(_, bool)) => 1

     rule max(ut(_, bitfieldType(_:SimpleUnsignedType, N::Int)))
          => (1 <<Int absInt(N)) -Int 1

     rule max(ut(_, _:SimpleUnsignedCharType))
          => (1 <<Int absInt(numBits(unsigned-char))) -Int 1
     rule max(ut(_, unsigned-short-int))
          => (1 <<Int absInt(numBits(unsigned-short-int))) -Int 1
     rule max(ut(_, unsigned-int))
          => (1 <<Int absInt(numBits(unsigned-int))) -Int 1
     rule max(ut(_, unsigned-long-int))
          => (1 <<Int absInt(numBits(unsigned-long-int))) -Int 1
     rule max(ut(_, unsigned-long-long-int))
          => (1 <<Int absInt(numBits(unsigned-long-long-int))) -Int 1

     rule min(ut(_, enumType(S::TagId))) => min(utype(getEnumAlias(S)))
     rule max(ut(_, enumType(S::TagId))) => max(utype(getEnumAlias(S)))

     rule innerType(T:UType) => innerType(type(T))

     rule innerType(t(Qs::Quals, _, arrayType(T::Type, _))) => addQualifiers(Qs, T)
     rule innerType(t(Qs::Quals, _, flexibleArrayType(T::Type))) => addQualifiers(Qs, T)
     rule innerType(t(Qs::Quals, _, incompleteArrayType(T::Type))) => addQualifiers(Qs, T)
     rule innerType(t(Qs::Quals, _, unspecifiedArrayType(T::Type))) => addQualifiers(Qs, T)
     rule innerType(t(Qs::Quals, _, variableLengthArrayType(T::Type, _))) => addQualifiers(Qs, T)
     rule innerType(t(_, _, bitfieldType(T::SimpleType, _))) => type(T)
     rule innerType(t(_, _, functionType(T::UType, _))) => type(T)
     rule innerType(t(_, _, pointerType(T::Type))) => T

     rule addQualifiers(Qs'::Quals, t(Qs::Quals, Mods::Set, T::SimpleType))
          => t(Qs +Quals Qs', Mods, T)

     rule getQualifiers(t(Qs::Quals, _, T:SimpleArrayType))
          => Qs +Quals getQualifiers(innerType(type(T)))
     rule getQualifiers(t(Qs::Quals, _, _)) => Qs [owise]

endmodule
