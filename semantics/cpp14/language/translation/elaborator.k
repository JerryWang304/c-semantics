module CPP-ELABORATOR-SYNTAX
     imports BASIC-K

     syntax KItem ::= elaborate(K) [klabel(elaborate1)]
                    | elaborate(K, K)
                    | elaborateDone(K) [klabel(elaborateDone1)]
                    | elaborateDone(K, K)
                    | elaborateTemplateBody(K)

     syntax KItem ::= runInit(K) [strict]
endmodule

module CPP-ELABORATOR
     imports CPP-ELABORATOR-SYNTAX
     imports C-CONFIGURATION

     syntax KItem ::= elabFrame(K, K)
                    | elabTemplateFrame(K, K, TemplateInfo)

     rule <k> elaborate(K:K) ~> Cont:K => K </k>
          <elab> OldElab:K => .K </elab>
          <elab-stack>
               .List => ListItem(elabFrame(Cont, OldElab))
          ...</elab-stack>
     rule <k> .K => elaborateDone(K) ~> Cont </k>
          <elab> K:K => OldElab </elab>
          <elab-stack>
               ListItem(elabFrame(Cont:K, OldElab:K)) => .List
          ...</elab-stack>

     rule <k> elaborateTemplateBody(K:K) ~> Cont:K => K </k>
          <curr-template-context> I::TemplateInfo => noTemplate </curr-template-context>
          <elab> OldElab:K => .K </elab>
          <elab-stack>
               .List => ListItem(elabTemplateFrame(Cont, OldElab, I))
          ...</elab-stack>
     rule <k> .K => elaborateDone(K) ~> Cont </k>
          <curr-template-context> _ => I </curr-template-context>
          <elab> K:K => OldElab </elab>
          <elab-stack>
               ListItem(elabTemplateFrame(Cont:K, OldElab:K, I::TemplateInfo)) => .List
          ...</elab-stack>

     rule runInit(V:Val) => .K

     rule elaborate(K1:K, K2:K) => elaborate(K1) ~> elaborate(K2)
     rule elaborateDone(K1:K) ~> elaborate(K2:K)
          => elaborate(K2) ~> elaborateDone(K1)
     rule elaborateDone(K2:K) ~> elaborateDone(K1:K)
          => elaborateDone(K1:K, K2:K)

endmodule
