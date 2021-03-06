module CPP-TRANSLATION-NAME
     imports CPP-EXPR-NAME
     imports COLLECTIONS
     imports COMPAT-SYNTAX
     imports CPP-ABSTRACT-SYNTAX
     imports CPP-DECL-CLASS-SYNTAX
     imports CPP-DECL-TEMPLATE-SYNTAX
     imports CPP-TYPING-EXPR-SYNTAX
     imports CPP-OVERLOADING-SYNTAX

     rule CallExpr(Name(NoNNS(), X::CId), Args::StrictList) => argDependentNameLookup(X, Args, Args, nameLookup(X, NoTag()))
     rule <k> CallExpr((ExprLoc(L::CabsLoc, E::Expr) => E), Args::StrictList) ...</k>
          <curr-program-loc> _ => L </curr-program-loc>
     rule (.K => Name(N, X)) ~> CallExpr(Name(N::NNS, X::CId), _)
          requires N =/=K NoNNS()
     rule cSet(Y::Map) ~> CallExpr(Name(N::NNS, X::CId), Args::StrictList)
          => resolveOverload(cSet(Y), Args, Args, Args, X, operator())
          requires N =/=K NoNNS()

     syntax Bool ::= isQualifiedName(Expr)
     rule isQualifiedName(Name(N::NNS, _)) => true
          requires N =/=K NoNNS()
     rule isQualifiedName(_) => false [owise]

     rule Name(NoNNS(), X::CId) => resolveUniqueDecl(nameLookup(X, NoTag()), Name(NoNNS(), X))
     rule ElaboratedTypeSpecifier(T::Tag, X::CId, NoNNS()) => resolveElabSpecifier(T, nameLookup(X, T))
     requires T =/=K NoTag()
     rule ElaboratedTypeSpecifier(T::Tag, X::CId, NoNNS(), Args::List) => resolveElabSpecifier(nameLookup(X, T), list(Args))
     requires T =/=K NoTag()

     rule (.K => nsRef(GlobalNamespace())) ~> Name(GlobalNamespace(), _)
     rule (.K => nameLookup(X, NoTag())) ~> Name(NNS(X:CId), _)
     rule (.K => N) ~> Name(NNS(N:Name), _)

     rule nsRef(N::Namespace) ~> Name(_, X::CId) => qualifiedNameLookup(X, N)
     rule (T:CPPClassType => classNameLookup(X, T)) ~> Name(_, X::CId)

     syntax Expr ::= argDependentNameLookup(CId, StrictList, StrictList, Expr) [strict(4)]
                   | #argDependentNameLookup(CId, StrictList, List, Set, CandidateSet)
                   | qualifiedNameLookup(CId, Namespace)
                   | classNameLookup(CId, CPPClassType)
     syntax AType ::= resolveElabSpecifier(Tag, K) [strict(2)]
                    | resolveElabSpecifier(K, StrictList) [strict(1, 2), klabel(resolveElabSpecifier2)]
                    | specializeTypeTemplate(QualId, CPPType, List)

     // unqualified name lookup
     rule <k> nameLookup(X::CId, NoTag()) => cSet(S) ...</k>
          <env>... X |-> S::Map ...</env>

     rule <k> nameLookup(X::CId, NoTag()) => T ...</k>
          <types>... X |-> (_ |-> T::CPPType) ...</types>

     rule <k> nameLookup(X::CId, Tag::Tag) => T ...</k>
          <types>... X |-> (_ Tag |-> T::CPPType) ...</types>

     rule <k> nameLookup(X::CId, T::Tag) => nameLookupInNamespace(X, getInnermostNamespace(S), T) ...</k>
          <curr-scope> S::Scope </curr-scope>
          <env> Env::Map </env>
          <types> Types::Map </types>
          requires notBool X in_keys(Env) andBool notBool X in_keys(Types)

     rule <k> nameLookupInNamespace(X::CId, N::Namespace, NoTag()) => cSet(S) ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <ns-id> N </ns-id>
          <nenv>... X |-> S::Map ...</nenv>
          <templates> T::Map </templates>
          requires notBool N :: X in_keys(T)

     rule <k> nameLookupInNamespace(X::CId, N::Namespace, NoTag()) => cSet(T |-> I M) ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <nenv> NE::Map </nenv>
          <templates>... N :: X |-> (T:CPPFunctionTypeExpr |-> I::TemplateInfo M::Map) ...</templates>
          requires notBool X in_keys(NE)

     // arg dependent name lookup
     context argDependentNameLookup(_, _, (HOLE:StrictList => types(HOLE)), _)

     rule <k> (.K => isDependentName(X, Args, Types)) ~> argDependentNameLookup(X::CId, list(Args::List), krlist(Types::List), cSet(_)) ...</k>
          <curr-template-context> templateInfo(...) </curr-template-context>
     rule <k> (.K => false) ~> argDependentNameLookup(X::CId, list(Args::List), krlist(Types::List), cSet(_)) ...</k>
          <curr-template-context> noTemplate </curr-template-context>

     // TODO(dwightguth): class member stuff
     syntax KItem ::= isDependentName(CId, List, List)
     rule isDependentName(_, ListItem(PackExpansionExpr(_)) _, _) => true
     rule (.K => isTypeDependent(Arg, Type)) ~> isDependentName(_, (ListItem(Arg::Expr) => .List) _, (ListItem(Type::CPPTypeExpr) => .List) _)
     rule true ~> isDependentName(_, _, _) => true
     rule (false => .K) ~> isDependentName(_, _, _)
     rule isDependentName(_, .List, .List) => false
     syntax KItem ::= isTypeDependent(Expr, CPPTypeExpr)
     rule isTypeDependent(StringLiteral(_, _), _) => false
     rule (.K => nameLookup(X, NoTag())) ~> isTypeDependent(Name(NoNNS(), X::CId), _)
     rule cSet((T::CPPTypeExpr |-> _ => .Map) _) ~> isTypeDependent(Name(NoNNS(), _), _)
          requires notBool isDependentInScope(T)
     rule cSet(.Map) ~> isTypeDependent(Name(NoNNS(), _), _) => false

     rule <k> false ~> argDependentNameLookup(X::CId, Args::StrictList, Types::StrictList, cSet(Y::Map)) => resolveOverload(cSet(Y), Args, Types, Args, X, operator()) ...</k>
           <env> Env::Map </env>
           requires hasSpecialDeclInArgLookup(X, Y, Env)

     syntax Bool ::= hasSpecialDeclInArgLookup(CId, Map, Map) [function]
     // 3.4.2:3.2
     rule hasSpecialDeclInArgLookup(X::CId, _, _::Map (X |-> ((T:CPPFunctionTypeExpr |-> kpair(false, _)) _))) => true
     rule hasSpecialDeclInArgLookup(_, T::CPPType |-> _, _) => true
          requires notBool isCPPFunctionType(T)
     rule hasSpecialDeclInArgLookup(_, _, _) => false [owise]

     // associated namespaces
     rule <k> (.K => getFunctionAddressTypes(Args)) 
              ~> false ~> argDependentNameLookup(X::CId, list(Args::List), krlist(Types::List), cSet(Y::Map)) ...</k>
          <env> Env::Map </env>
          requires notBool hasSpecialDeclInArgLookup(X, Y, Env)

     // if the argument is the name or address of a set of overloaded functions
     // and/or function templates, its associated classes and namespaces are 
     // the union of those associated with each of the members of the set,
     // i.e., the classes and namespaces associated with its parameter types
     // and return type
     syntax KItem ::= getFunctionAddressTypes(List)
     rule (.K => nameLookup(X, NoTag())) ~> getFunctionAddressTypes((ListItem(Name(NoNNS(), X::CId)) => .List) _)
     rule (cSet(M::Map) => .K) ~> getFunctionAddressTypes(_) ~> false ~> argDependentNameLookup(_, _, krlist(_::List (.List => filterList(keys_list(M), #klabel(`isCPPFunctionType`)))), _)
     rule getFunctionAddressTypes((ListItem(N::Init) => .List) _)
          requires notBool isName(N) andBool notBool isAddressOfName(N)

     syntax Bool ::= isAddressOfName(Init) [function]
     rule isAddressOfName(& N:Name) => true
     rule isAddressOfName(_) => false [owise]

     rule <k> getFunctionAddressTypes(.List) ~> false ~> argDependentNameLookup(X::CId, Args::StrictList, krlist(Types::List), cSet(Y::Map)) => #argDependentNameLookup(X, Args, Types, getAssociatedNamespaces(Types, <namespaces> B </namespaces>), cSet(Y)) ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <namespaces> B::Bag </namespaces>

     syntax Set ::= getAssociatedNamespaces(List, NamespacesCell) [function]
                   | #getAssociatedNamespaces(Set, NamespacesCell) [function]
     syntax List ::= getAssociatedClasses(CPPTypeExpr) [function]
                   | #getAssociatedClasses(CPPTypeExpr, ClassInfo) [function]
                   | getTemplateArgTypes(TemplateParams) [function]

     // 3.4.2:2.1
     rule getAssociatedNamespaces((ListItem(T:CPPFundamentalType) => .List) _, _)
     rule getAssociatedNamespaces((ListItem(t(_, _, no-type)) => .List) _, _)
     // 3.4.2:2.2
     rule getAssociatedNamespaces(ListItem(t(Q::Quals, Mods::Set, classType(N::Namespace :: Class(Tag::Tag, X::CId, Args::TemplateParams)))) L::List, B::NamespacesCell)
          => getAssociatedNamespaces(getTemplateArgTypes(Args) L, B) #getAssociatedNamespaces(List2Set(mapList(getAssociatedClasses(t(Q, Mods, classType(N :: Class(Tag, X, Args)))), #klabel(`getInnermostNamespace1`))), B)
     // 3.4.2:2.4
     rule getAssociatedNamespaces(ListItem(T::CPPType => innerType(T)) _, _)
          requires isCPPPointerType(T) orBool isCPPArrayType(T)
     rule getAssociatedNamespaces(.List, _) => .Set

     // If an associated namespace is an inline namespace (7.3.1), its enclosing
     // namespace is also included in the set.
     // If an associated namespace directly contains inline namespaces, those
     // inline namespaces are also included in the set
     rule #getAssociatedNamespaces(SetItem(N::Namespace :: S::NamespaceSpecifier) _::Set (.Set => #if B #then SetItem(N) #else .Set #fi Set), 
          <namespaces>... 
            (<ns>... 
               <ns-id> N :: S </ns-id>
               <is-inline> B:Bool </is-inline>
               <inline-namespaces> Set::Set </inline-namespaces>
            ...</ns>)
            => .Bag
          ...</namespaces>)
     rule #getAssociatedNamespaces(S::Set, _) => S [owise]

     rule getAssociatedClasses(T::CPPClassType) => #getAssociatedClasses(T, getClassInfo(T))
     rule #getAssociatedClasses(t(_, _, classType(N:Namespace :: C::ClassSpecifier)), #incomplete) => ListItem(classScope(N :: C))

     rule getTemplateArgTypes(t(Q::Quals, Mods::Set, T::CPPSimpleTypeExpr), Ps::TemplateParams) => ListItem(t(Q, Mods, T)) getTemplateArgTypes(Ps)
     rule getTemplateArgTypes(.TemplateParams) => .List

     rule #argDependentNameLookup(X::CId, Args::StrictList, Types::List, .Set, cSet(Y::Map)) => resolveOverload(cSet(Y), Args, krlist(Types), Args, X, operator())
     rule (.K => qualifiedNameLookup(X, N)) ~> #argDependentNameLookup(X::CId, _, _, (SetItem(N::Namespace) => .Set) _, _)
     rule (cSet(M::Map) => .K) ~> #argDependentNameLookup(_, _, _, _, cSet(_::Map (.Map => M)))

     // qualified name lookup
     rule <k> qualifiedNameLookup(X::CId, N::Namespace) => T ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <ns-id> N </ns-id>
          <ntypes>... X |-> (_ |-> T:CPPTypeExpr) ...</ntypes>
          <templates> Templates::Map </templates>
          <inline-namespaces> .Set </inline-namespaces>
          requires notBool N :: X in_keys(Templates)

     rule <k> qualifiedNameLookup(X::CId, N::Namespace) => cSet(T |-> I M) ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <templates>... N :: X |-> (T:CPPFunctionTypeExpr |-> I::TemplateInfo M::Map) ...</templates>
          <inline-namespaces> .Set </inline-namespaces>

     rule <k> qualifiedNameLookup(X::CId, N::Namespace) => cSet(M) ...</k>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <ns-id> N </ns-id>
          <inline-namespaces> .Set </inline-namespaces>
          <nenv>... X |-> M::Map ...</nenv>

     // class name lookup
     rule <k> classNameLookup(X::CId, t(... st: classType(C::Class))) ~> N:Name => le(N, noTrace, T) ...</k>
          <class-id> C </class-id>
          <cenv>... X |-> (T::CPPType |-> _) ...</cenv>

     // elaborated type specifiers
     rule resolveElabSpecifier(_, T:CPPTypeExpr) => T
     rule resolveElabSpecifier(T:ClassKey, notFound(X::CId)) => declareClassName(T, X, false)

     rule resolveElabSpecifier(templateRef(Q::QualId, T::CPPClassType), krlist(Args::List)) => specializeTypeTemplate(Q, T, Args)
     rule <k> specializeTypeTemplate(X::QualId, t(Q::Quals, Mods::Set, classType(N::Namespace :: Class(Tag::Tag, C::CId, .TemplateArgs))), Args::List) => t(Q, Mods, classType(N :: Class(Tag, C, toTemplateArgs(Args)))) ...</k>
 
endmodule
