module C-IO-DIRECT
     imports C-CONFIGURATION
     imports ARRAY
     imports BOOL
     imports INT
     imports MAP
     imports BITS-SYNTAX
     imports MEMORY-SYNTAX
     imports SETTINGS-SYNTAX
     imports SYMLOC-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-MEMORY-READING-SYNTAX
     imports C-MEMORY-WRITING-SYNTAX
     imports C-TYPING-SYNTAX

     syntax KItem ::= writeBytes(SymLoc, DataList)
     syntax KItem ::= writeByte(SymLoc, CValue)

     rule writeBytes(Loc:SymLoc, D:DataList, _) => writeBytes(Loc, D)
          [structural]

     rule writeBytes(Loc:SymLoc, dataList(ListItem(V:CValue) L:List))
          => writeByte(Loc, V) ~> writeBytes(Loc +bytes 1, dataList(L))
          [structural]

     rule writeBytes(_, dataList(.List)) => .K
          [structural]

     rule <k> writeByte(loc(Base:SymBase, Offset:Int), V:CValue) => .K ...</k>
          <mem>...
               Base |-> object(_, Len:Int, (M::Array => M[Offset <- V]))
          ...</mem>
          requires (Offset <Int Len)
          [structural]

     syntax KItem ::= readByte(SymLoc)
     // loc, size in bytes, aux list
     syntax KItem ::= "readBytes-aux" "(" SymLoc "," Int "," List ")"

     rule readBytes(Loc:SymLoc, Size:Int, _)
          => readBytes-aux(Loc, Size, .List)
          [structural]

     // fixme sNat
     rule readBytes-aux(Loc:SymLoc, Size:Int, Aux:List)
          => readByte(Loc)
          ~> readBytes-aux(Loc +bytes 1, Size -Int 1, Aux)
          requires Size:Int >Int 0
          [structural]
     rule (tv(V:CValue, T::UType) => .K)
          ~> readBytes-aux(_, _, (Aux:List => Aux ListItem(tv(V, T))))
          [structural]

     syntax List ::= values(List) [function, klabel(valuesRValue)]
     rule values(ListItem(tv(K::CValue, _)) L:List) => ListItem(K) values(L)
     rule values(.List) => .List

     rule readBytes-aux(_, 0, Aux:List) => dataList(values(Aux))
          [structural]

     rule <k> readByte(loc(Base:SymBase, Offset:Int))
               => tv({M[Offset]}:>Bits, utype(no-type))
          ...</k>
          <mem>...
               Base |-> object(_, _, M::Array)
          ...</mem>
          requires Offset in_keys(M)
          [structural]
     rule <k> readByte(loc(Base:SymBase, Offset:Int))
               => tv(piece(0, cfg:bitsPerByte), utype(no-type))
          ...</k>
          <mem>...
               Base |-> object(_, _,
                    M::Array => M[Offset <- piece(0, cfg:bitsPerByte)])
          ...</mem>
          requires notBool (Offset in_keys(M))
          [structural]

     rule readBytesForWriting(Loc:SymLoc, Size:Int, .List, _)
          => readBytes-aux(Loc, Size, .List)

endmodule
