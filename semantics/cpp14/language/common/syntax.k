module CPP-SORTS
     syntax CId ::= OpId
     syntax Init ::= Stmt | Expr
     syntax Expr ::= Name
     syntax Name
     syntax Stmt ::= Block
     syntax Block
     syntax OpId
     syntax Tag
endmodule

module CPP-SYNTAX
     imports CPP-SORTS
     imports INT-SYNTAX
     imports LIST
     imports COMMON-SORTS
     imports CPP-DYNAMIC-SORTS
     imports CPP-REVAL-SYNTAX
     imports CPP-TYPING-SORTS

     syntax OpId ::= "operatornew"
                   | "operatordelete"
                   | "operatornew[]"
                   | "operatordelete[]"
                   | "operator+"
                   | "operator-"
                   | "operator*"
                   | "operator/"
                   | "operator%"
                   | "operator^"
                   | "operator&"
                   | "operator|"
                   | "operator~"
                   | "operator!"
                   | "operator="
                   | "operator<"
                   | "operator>"
                   | "operator+="
                   | "operator-="
                   | "operator*="
                   | "operator/="
                   | "operator%="
                   | "operator^="
                   | "operator&="
                   | "operator|="
                   | "operator<<"
                   | "operator>>"
                   | "operator<<="
                   | "operator>>="
                   | "operator=="
                   | "operator!="
                   | "operator<="
                   | "operator>="
                   | "operator&&"
                   | "operator||"
                   | "operator++"
                   | "operator--"
                   | "operator,"
                   | "operator->*"
                   | "operator->"
                   | "operator()"
                   | "operator[]"

     // not technically operator ids, but used internally in order to process
     // syntax from the parser
     syntax OpId ::= "operator."
                   | "operator.*"
                   | "operator?"
                   | "operator_++"
                   | "operator++_"
                   | "operator_--"
                   | "operator--_"
                   

     syntax Expr ::= temp(Int, CPPType)
                   | newSize(Int)

     syntax CId ::= Destructor(CId)

     syntax ClassKey ::= Struct() | Union() | Class() 
     syntax Tag ::= ClassKey | Enum() | Typename() | NoTag()

     syntax TemplateKeyword ::= "template" | "no-template"

     syntax Expr ::= left:
                     Expr "[" Expr "]" [strict]
                   | Expr "++" [strict]
                   | Expr "--" [strict]
                   | BuiltinCallOp(Expr, List)
                   | ReinterpretCast(AType, Expr) [strict]
                   | ConstCast(AType, Expr) [strict]
                   > right:
                     "++" Expr [strict]
                   | "--" Expr [strict]
                   | NewOp(CPPType, Expr, K, K, Int)
                   | DeleteOp(Expr, Expr, K, Int)
                   | "*" Expr
                   | "&" Expr [strict]
                   | "!" Expr
                   | "-" Expr
                   | "+" Expr
                   | "~" Expr
                   | Expr "." TemplateKeyword Name
                   | Expr "->" TemplateKeyword Name
                   > left:
                     Expr ".*" Expr
                   | Expr "->*" Expr
                   > left:
                     Expr "*" Expr
                   | Expr "/" Expr
                   | Expr "%" Expr
                   > left:
                     Expr "+" Expr
                   | Expr "-" Expr
	           > left:
                     Expr "<<" Expr
                   | Expr ">>" Expr
                   > left:
                     Expr "<" Expr
                   | Expr "<=" Expr
                   | Expr ">" Expr
                   | Expr ">=" Expr
                   > left:
                     Expr "==" Expr
                   | Expr "!=" Expr
                   > left:
                     Expr "&" Expr
                   > left:
                     Expr "^" Expr
                   > left:
                     Expr "|" Expr
                   > left:
                     Expr "&&" Expr
                   > left:
                     Expr "||" Expr
                   > right:
                     Expr ":=" Init [strict(1)]
                   | Expr "+=" Init [strict(1)]
                   | Expr "-=" Init [strict(1)]
                   | Expr "*=" Init [strict(1)]
                   | Expr "/=" Init [strict(1)]
                   | Expr "%=" Init [strict(1)]
                   | Expr "^=" Init [strict(1)]
                   | Expr "&=" Init [strict(1)]
                   | Expr "|=" Init [strict(1)]
                   | Expr "<<=" Init [strict(1)]
                   | Expr ">>=" Init [strict(1)]
                   | ConditionalOp(Expr, Expr, Expr, ValueCategory, CPPType)
                   > left:
                     Comma(Expr, Expr)
     syntax Name ::= Name(NNS, CId)
                   | Name(NNS, CId, List)

     syntax Expr ::= ConvertType(CPPType, Expr)
                   | ExprLoc(CabsLoc, Expr)

     syntax Init ::= ExprLoc(CabsLoc, Init)
     syntax BraceInit ::= ExprLoc(CabsLoc, BraceInit)

     context _ := (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ += (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ -= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ *= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ /= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ %= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ ^= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ &= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ |= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ <<= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context _ >>= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context * (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) + _ [result(PRVal)]
     context _ + (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) - _ [result(PRVal)]
     context _ - (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) * _ [result(PRVal)]
     context _ * (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) / _ [result(PRVal)]
     context _ / (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) % _ [result(PRVal)]
     context _ % (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) ^ _ [result(PRVal)]
     context _ ^ (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) & _ [result(PRVal)]
     context _ & (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) | _ [result(PRVal)]
     context _ | (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) != _ [result(PRVal)]
     context _ != (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) == _ [result(PRVal)]
     context _ == (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) < _ [result(PRVal)]
     context _ < (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) <= _ [result(PRVal)]
     context _ <= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) > _ [result(PRVal)]
     context _ > (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) >= _ [result(PRVal)]
     context _ >= (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) << _ [result(PRVal)]
     context _ << (HOLE:Expr => reval(HOLE)) [result(PRVal)]
     context (HOLE:Expr => reval(HOLE)) >> _ [result(PRVal)]
     context _ >> (HOLE:Expr => reval(HOLE)) [result(PRVal)]

     syntax Block ::= BlockStmt(Int, List)
     syntax Decl
     syntax Stmt ::= LabelStmt(CId, List)
                   | GotoStmt(CId)
                   | ExpressionStmt(Expr) [strict]
                   | PRValExpressionStmt(Expr) [strict]
                   | ReturnOp(Expr)
                   | IfStmt(Decl, Stmt, Stmt)
                   | IfStmt(Expr, Stmt, Stmt)
                   | ForStmt(Expr, Stmt, Stmt) [klabel(ForStmt3)]

     context IfStmt((HOLE:Expr => reval(HOLE)), _, _) [result(PRVal)]

endmodule
