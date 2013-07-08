See INSTALL.md for installation instructions and LICENSE for licensing
information.

## Usage
      
### Quick overview
- `kcc` is meant to to act a lot like `gcc`.  You use it and run programs the
  same way.
- The programs kcc generates act like normal programs.  Both the output to
  stdio (e.g., printf), as well as the return value of the program should be
  what you expect.  In terms of operational behavior, a correct program
  compiled with kcc should act the same as one compiled with `gcc`.
- Take a look at `kcc -h` for some compile-time options.  For most programs,
  you only need to run `kcc program.c` and everything will work.  Caveats
  below.
- After compiling a program and generating an output file `a.out`, running
  `HELP=1 ./a.out` will display some runtime options, including `SEARCH`, 
  `PROFILE`, and `LTLMC`.
- If you try to run a program that is undefined (or one for which we are
  missing semantics), the program will get stuck. The message should tell you
  where it got stuck and may give a hint as to why. If you want help
  deciphering the output, or help understanding why the program is defined,
  please send your `.kdump` file to us.
      
### Runtime features

Once `kcc` has been run on C source files, it should produce an executable
script, called `a.out` by default.

#### Searching the state space of non-deterministic expression sequencing

Running "SEARCH=1 ./a.out" will exhaustively search the state space resulting
from a non-deterministic expression evaluation order (as allowed by the
standard) and generate a .pdf and .ps of the space (if you installed
Graphviz). This is the only way to check all possible evaluation orders of a
program to find undefined behavior.

#### Searching the state space of non-deterministic thread interleavings

Likewise, running "THREADSEARCH=1 ./a.out" will exhaustively search the state
space resulting from non-deterministic interleaving of threads as described in
the standard. Very experimental.

#### LTL model checking

We currently support LTL model checking of the version of our semantics
with non-deterministic expression sequencing.

For example, consider the C program at `examples/ltlmc/bad.c`:
<pre>
int x, y;
int main(void) {
      y = x + (x=1);
      return 0;
}
</pre>

This program contains undefined behavior because `x` is both read and written
to between sequence points. But our `kcc` tool does not catch this without
searching the state space of possible expression evaluation orders. 

Now we could also catch this using model checking:
<pre>
$ kcc bad.c -o bad
$ LTLMC="[]Ltl ~Ltl __error" ./bad
</pre>

We might also wish to check the value of `y`:
<pre>
$ LTLMC="<>Ltl y == 2" ./bad
</pre>
Both of these checks should fail, producing a counter-example (which will be
huge -- consider using the `-s` flag with `kcc`, at least).

Compare these results with model checking the same LTL propositions on the C
program at `examples/ltlmc/good.c`:
<pre>
int x, y;
int main(void) {
      y = 1 + (x=1);
      return 0;
}
</pre>
For this program, no counter-example will be found for either proposition and
the only result should be `true`.

The syntax of LTL formulas is given by the following grammar:
<pre>
LTL ::= "~Ltl" LTL
      | "OLtl" LTL
      | "<>Ltl" LTL
      | "[]Ltl" LTL
      | LTL "/\Ltl" LTL
      | LTL "\/Ltl" LTL
      | LTL "ULtl" LTL
      | LTL "RLtl" LTL
      | LTL "WLtl" LTL
      | LTL "|->Ltl" LTL
      | LTL "->Ltl" LTL 
      | LTL "<->Ltl" LTL
      | LTL "=>Ltl" LTL 
      | LTL "<=>Ltl" LTL
</pre>

Additionally, we support a subset of the C expression syntax and we resolve
symbols in the global scope of the program being checked. We support two other
special atomic propositions: `__running` and `__error`. The first holds after
main has been called, becoming false when main returns. The second holds when
the semantics detects some runtime error that would result in undefined
behavior.

#### Profiling the semantics

Running `PROFILE=1 ./a.out` will record which rules of the semantics are
exercised during the evaluation of the program. The program executes as
normal, but this additional information is recorded in a SQLite database
`maudeProfileDBfile.sqlite` in your current directory. You can access the
information by running queries against the database. Some sample queries are
provided in the dist directory, and can be tried by running, e.g., 
<pre>
$ cat dist/profile-executiveSummaryByProgram.sql | perl dist/accessProfiling.pl
</pre>
You can look at the provided queries and construct your own, or access the
database using your own programs.  Different runs of the tool are kept
distinct in the database, so you can run a bunch of programs and then analyze
the collective data. You can simply delete "maudeProfileDBfile.sqlite" file
to start another series of tests with a fresh database.

#### Testing the semantics

The `tests` directory includes many of the tests we've used to build confidence
in the correctness of our semantics. For example, to run tests from the GCC
torture test suite, use the following command from the `tests/` directory:
<pre>
$ make torture
</pre>

### Caveats and miscellanea

- If you are only using one of the standard library functions that we directly
  give semantics to (printf being the most important), you can prevent the tool
  from linking in the standard library with the -s option. This can speed up
  the execution time of your program. If the program needs the standard
  library and you use the -s option, it will simply get stuck and you will see
  it trying to call that missing function at the top of the computation.

## Understanding the semantics

Links to help understand K:
- http://code.google.com/p/k-framework/
- http://k-framework.org/ 
- See particularly:
    - Traian Serbanuta's thesis defense slides
      (http://fsl.cs.uiuc.edu/pubs/serbanuta-2010-thesis-slides.pdf) for a high
      level overview 
    - "An Overview of the K Semantic Framework" from the Journal of Logic and
      Algebraic Programming
      (http://fsl.cs.uiuc.edu/pubs/rosu-serbanuta-2010-jlap.pdf) for a detailed
      explanation.

See `semantics/README.md` for more details.
