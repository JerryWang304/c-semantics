module CPP-EXECUTION-IO
     imports CPP-MEMORY-READING-SYNTAX
     imports CPP-MEMORY-WRITING-SYNTAX
     imports C-CONFIGURATION
     imports BOOL
     imports INT
     imports BITS-SYNTAX
     imports MEMORY-SYNTAX
     imports SETTINGS-SYNTAX
     imports SYMLOC-SYNTAX
     imports C-COMMON-EXPR-EVAL-SYNTAX
     imports C-IO-BUFFERED-SYNTAX
     imports CPP-BITSIZE-SYNTAX
     imports CPP-ERROR-SYNTAX
     imports CPP-TYPING-SYNTAX

     rule <k> writeBytes(Loc::SymLoc, dataList(Bytes::List), T::CPPType)
              => checkWrite(Loc, T)
              ~> setModified(Loc, T)
              ~> writeBytes(Loc, Bytes)
          ...</k>
          <initializing> false </initializing>
          requires notBool isLinkerLoc(Loc)

     rule <k> writeBytes(Loc::SymLoc, dataList(Bytes::List), T::CPPType)
              => writeBytes(Loc, Bytes)
          ...</k>
          <initializing> true </initializing>
          requires notBool isLinkerLoc(Loc)

     rule <k> writeBytes(loc((Base::SymBase => Base'), _), _, _) ...</k>
          <linkings>... Base |-> Base'::SymBase ...</linkings>

     syntax KItem ::= checkWrite(SymLoc, CPPType) [klabel(cppCheckWrite)]
     rule checkWrite(loc(Base::SymBase, Offset::Int), T::CPPType) => .K

     syntax KItem ::= setModified(SymLoc, CPPType) [klabel(cppSetModified)]
     rule <k> setModified(Loc::SymLoc, T::CPPType)
              => setModified(Loc, byteSizeofType(T), .K, Modified)
          ...</k>
          <active-blocks> Modified::Map </active-blocks>

     syntax Error ::= "errorReadOutOfBounds"
     syntax K ::= assertInBounds(Int, Int) [klabel(cppAssertInBounds)]

     rule assertInBounds(Offset::Int, Len::Int)
          => assert(Offset <Int Len, errorReadOutOfBounds) [macro]

     syntax KItem ::= "readBytes-aux" "(" SymLoc "," Int "," List "," CPPType ")"

     rule readBytes(Loc::SymLoc, Size::Int, T::CPPType)
          => readBytes-aux(Loc +bytes (Size -Int 1), Size, .List, T)
          requires notBool isLinkerLoc(Loc)

     rule <k> readBytes(loc((Base::SymBase => Base'), _), _, _) ...</k>
          <linkings>... Base |-> Base'::SymBase ...</linkings>

     rule readBytes-aux(_, 0, Aux::List, _) => dataList(Aux)

     rule <k> readBytes-aux(loc(Base::SymBase, Offset::Int), Size::Int, Aux::List, T::CPPType)
              => assertInBounds(Offset, Len)
              ~> readBytes-aux(loc(Base, Offset) +bytes -1, Size -Int 1, ListItem(M[Offset]) Aux, T)
          ...</k>
          <mem>...
               Base |-> object(_, Len::Int, M::Array)
          ...</mem>
          <locs-written> Locs::Set </locs-written>
          <buffer> .List </buffer>
          requires Size >Int 0 andBool Offset in_keys(M)
     rule <k> readBytes-aux(loc(Base::SymBase, Offset::Int), Size::Int, Aux::List, T::CPPType)
              => assertInBounds(Offset, Len)
              ~> readBytes-aux(loc(Base, Offset) +bytes -1, Size -Int 1, ListItem(M[Offset]) Aux, T)
          ...</k>
          <mem>...
               Base |-> object(_, Len::Int, M::Array)
          ...</mem>
          <locs-written> Locs::Set </locs-written>
          <buffer> Mem::List </buffer>
          requires Size >Int 0 andBool notBool (loc(Base, Offset) in locations(Mem)) andBool Offset in_keys(M)
     rule <k> readBytes-aux(loc(Base::SymBase, Offset::Int), Size::Int, Aux::List, T::CPPType)
              => assertInBounds(Offset, Len)
              ~> readBytes-aux(loc(Base, Offset) +bytes -1, Size -Int 1, ListItem(getUninitializedBits(loc(Base, Offset), ObjT)) Aux, T) ...</k>
          <mem>...
               Base |-> object(ObjT::CPPType, Len::Int, M::Array => M[Offset <- getUninitializedBits(loc(Base, Offset), ObjT)])
          ...</mem>
          <locs-written> Locs::Set </locs-written>
          <buffer> Mem::List </buffer>
          requires Size >Int 0 andBool notBool (loc(Base, Offset) in locations(Mem)) andBool notBool (Offset in_keys(M))

     syntax Bits ::= getUninitializedBits(SymLoc, CPPType) [function, klabel(getUninitializedBitsCpp)]
     rule getUninitializedBits(L::SymLoc, _) => piece(trap, cfg:bitsPerByte)
          requires notBool (isStaticDuration(L) orBool isThreadDuration(L))
     rule getUninitializedBits(L::SymLoc, _) => piece(0, cfg:bitsPerByte) [owise]

     rule getQualsAtOffset(ListItem(t(Q::Quals, _, _)) Ts::List)
          => Q +Quals getQualsAtOffset(Ts)


     rule (.K => DRAFTING("EIO1",
               "Reading outside the bounds of an object."))
          ~> errorReadOutOfBounds
          [structural]

     rule <k> getEffectiveType(Base::SymBase) => convertTypeToC(T) ...</k>
          <mem>... Base |-> object(T:CPPType, _, _) ...</mem>
          [structural]

endmodule
