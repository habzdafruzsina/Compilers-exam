#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include "Parser.h"

using namespace std;

void input_handler( ifstream& in, int argc, char* argv[] );

int main( int argc, char* argv[] )
{
    ifstream in;
    input_handler( in, argc, argv );
    Parser pars( in );
    pars.parse();
    return 0;
}

void input_handler( ifstream& in, int argc, char* argv[] )
{
    if( argc < 2 )
    {
        cerr << "A forditando fajl nevet parancssori parameterben kell megadni." << endl;
        exit(1);
    }
    in.open( argv[1] );
    if( !in )
    {
        cerr << "A " << argv[1] << "fajlt nem sikerult megnyitni." << endl;
        exit(1);
    }
}
