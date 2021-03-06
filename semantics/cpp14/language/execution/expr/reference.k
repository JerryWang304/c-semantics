module CPP-EXPR-REFERENCE
     imports C-CONFIGURATION
     imports BOOL
     imports CPP-BITSIZE-SYNTAX
     imports CPP-DYNAMIC-SYNTAX
     imports CPP-MEMORY-ALLOC-SYNTAX
     imports CPP-REFERENCE-SYNTAX
     imports CPP-SYMLOC-SYNTAX
     imports CPP-SYNTAX
     imports CPP-TYPING-SYNTAX

     // we need this result tag because lvalues of reference type aren't KResults
     context bindReference(HOLE:Expr, _) [result(LVal)]

     rule <k> bindReference(lv(Loc1::SymLoc, Tr::Trace, T1::CPPType), lv(Loc2::SymLoc, _, T2::CPPType))
              => lv(Loc1, Tr, T1) ...</k>
          <references>... .Map => stripProv(Loc1) |-> Loc2 ...</references>
          requires isCPPLVRefType(T1) andBool notBool isCPPBitfieldType(T2) andBool isReferenceCompatible(innerType(T1), T2)

     rule <k> bindReference(lv(Loc1::SymLoc, Tr::Trace, T1::CPPType), xv(Loc2::SymLoc, _, T2::CPPType))
              => lv(Loc1, Tr, T1) ...</k>
          <references>... .Map => stripProv(Loc1) |-> Loc2 ...</references>
          requires notBool isCPPBitfieldType(T2)  andBool isReferenceCompatible(innerType(T1), T2) andBool notBool isCPPClassType(T2)

     rule <k> bindReference(lv(Loc::SymLoc, Tr1::Trace, T1::CPPType), prv(V::CPPValue, Tr2::Trace, T2::CPPType))
              => allocObject(!I @ D, innerType(T1), byteSizeofType(innerType(T1)))
              ~> bindReference(lv(Loc, Tr1, T1), lv(lnew(!I:Int @ D, innerType(T1)), noTrace, innerType(T1)) := prv(V, Tr2, T2)) ...</k>
          <duration> D::Duration </duration>
          requires notBool isCPPClassType(T2) andBool notBool isCPPArrayType(T2) andBool notBool isCPPClassType(T1)

endmodule
