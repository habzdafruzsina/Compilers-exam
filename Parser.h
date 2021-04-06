#ifndef Parser_h_included
#define Parser_h_included

#include <map>
#include <string>
#include <FlexLexer.h>
#include "Parserbase.h"
#include "semantics.h"

#undef Parser
class Parser: public ParserBase
{
        
    public:
        Parser(std::istream& inFile) : lexer( &inFile, &std::cerr ) {}
        int parse();

    private:
        yyFlexLexer lexer;
        void error(char const *msg);    // called on (syntax) errors
        int lex();                      // returns the next token from the
                                        // lexical scanner. 
        void print();                   // use, e.g., d_token, d_loc
		std::map<std::string,valtozo_leiro> szimb_tabla;
		int sorszam;

    // support functions for parse():
        void executeAction(int ruleNr);
        void errorRecovery();
        int lookup(bool recovery);
        void nextToken();
        void print__();
        void exceptionHandler__(std::exception const &exc);
};


#endif
