require "conversion.k"
require "env.k"
require "error.k"
require "init.k"
require "io.k"

require "decl/declarator.k"
require "decl/initializer.k"

require "expr/assignment.k"
require "expr/conditional.k"
require "expr/function-call.k"
require "expr/inc-and-dec.k"
require "expr/logical.k"
require "expr/name.k"
require "expr/new.k"
require "expr/reference.k"

require "stmt/block.k"
require "stmt/expr.k"
require "stmt/goto.k"
require "stmt/if.k"
require "stmt/labeled.k"
require "stmt/loop.k"
require "stmt/return.k"

require "cpp-extensions-execution.k"

module CPP-EXECUTION
     imports C-CONFIGURATION

     imports CPP-EXECUTION-CONVERSION
     imports CPP-ENV
     imports CPP-EXECUTION-ERROR
     imports CPP-EXECUTION-INIT
     imports CPP-EXECUTION-IO
     imports CPP-EXECUTION-EXPR-NAME

     imports CPP-DECL-DECLARATOR
     imports CPP-DECL-INITIALIZER

     imports CPP-EXPR-ASSIGNMENT
     imports CPP-EXPR-CONDITIONAL
     imports CPP-EXPR-FUNCTION-CALL
     imports CPP-EXPR-INC-AND-DEC
     imports CPP-EXPR-LOGICAL
     imports CPP-EXPR-NEW
     imports CPP-EXPR-REFERENCE

     imports CPP-STMT-BLOCK
     imports CPP-STMT-EXPR
     imports CPP-STMT-GOTO
     imports CPP-STMT-IF
     imports CPP-STMT-LABELED
     imports CPP-STMT-LOOP
     imports C-CPP-STMT-RETURN

     imports CPP-EXECUTION-EXTENSIONS
endmodule
