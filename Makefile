COMPILERNAME=plang--
SCANNERTEST=scantest

all: $(COMPILERNAME)
	-

compiler: $(COMPILERNAME)
	-

scanner: lex.yy.cc
	-

parser: parse.cc
	-

clean:
	rm -rf $(COMPILERNAME) $(SCANNERTEST) lex.yy.cc Parserbase.h parse.cc *~

lex.yy.cc: $(COMPILERNAME).l
	flex $(COMPILERNAME).l

parse.cc: $(COMPILERNAME).y
	bisonc++ $(COMPILERNAME).y

$(COMPILERNAME): $(COMPILERNAME).cc lex.yy.cc parse.cc
	g++ -o$(COMPILERNAME) $(COMPILERNAME).cc parse.cc lex.yy.cc

$(SCANNERTEST): $(SCANNERTEST).cc lex.yy.cc
	g++ -o$(SCANNERTEST) $(SCANNERTEST).cc lex.yy.cc
