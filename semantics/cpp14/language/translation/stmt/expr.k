module CPP-STMT-EXPR
     imports C-CONFIGURATION
     imports CPP-ABSTRACT-SYNTAX
     imports CPP-SYNTAX
     imports CPP-COMMON-STMT-EXPR-SYNTAX

     rule <k> ExpressionStmt(V:Val)  => .K ...</k>
          <elab>... .K => ExpressionStmt(V) </elab>
          requires isTExpr(V) andBool notBool isConvertableDiscardedExpr(V)

     rule ExpressionStmt(V::GLVal => prDiscardedExpr(V))
          requires isConvertableDiscardedExpr(V)

     rule ExpressionStmt(V:Val) => .K
          requires notBool isTExpr(V) andBool notBool isConvertableDiscardedExpr(V)

     rule prDiscardedExpr(pre(E::Expr, Tr::Trace, T::CPPType)) => pre(prDiscardedExpr(E), Tr, T)
     rule glDiscardedExpr(le(E::Expr, Tr::Trace, T::CPPType)) => pre(glDiscardedExpr(E), Tr, T)
     rule glDiscardedExpr(xe(E::Expr, Tr::Trace, T::CPPType)) => pre(glDiscardedExpr(E), Tr, T)
     rule glDiscardedExpr(pre(E::Expr, Tr::Trace, T::CPPType)) => pre(glDiscardedExpr(E), Tr, T)

     rule NullStmt() => .K

endmodule
