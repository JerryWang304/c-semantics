module CPP-MEMORY-WRITING-SYNTAX
     imports BASIC-K
     imports STRING-SYNTAX
     imports SYMLOC-SORTS
     imports CPP-DYNAMIC-SORTS
     imports CPP-TYPING-SORTS

     syntax KItem ::= write(SymLoc, K, CPPType) [klabel(writeCpp)]
                    | writeBytes(SymLoc, DataList, CPPType) [klabel(writeBytesCpp)]
                    | writeString(SymLoc, String) [klabel(writeStringCpp)]

     syntax DataList ::= splitBytes(PRVal) [function, klabel(splitBytesCpp)]

endmodule

module CPP-MEMORY-WRITING
     imports CPP-MEMORY-WRITING-SYNTAX
     imports STRING
     imports MEMORY-SYNTAX
     imports SYMLOC-SYNTAX
     imports CPP-BITSIZE-SYNTAX
     imports CPP-DYNAMIC-SYNTAX
     imports CPP-SYNTAX
     imports CPP-TYPING-SYNTAX

     context write(_, HOLE:K, _)

     rule write(Loc::SymLoc, V:PRVal, T::CPPType)
          => writeBytes(stripProv(Loc), splitBytes(V), T)

     rule splitBytes(prv(V::CPPValue, _, T::CPPType))
          => splitBytes(V, byteSizeofType(T))

     rule writeString(Loc::SymLoc, S::String)
          => ExpressionStmt(
               lv(Loc, noTrace, type(unsigned-char))
               := prv(ordChar(firstChar(S)), noTrace, type(unsigned-char)))
               ~> writeString(Loc +bytes 1, butFirstChar(S))
          requires S =/=String ""

     rule writeString(Loc::SymLoc, "")
          => .K

endmodule
