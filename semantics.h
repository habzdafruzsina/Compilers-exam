#ifndef SEMANTICS_H
#define SEMANTICS_H

#include <string>
#include <iostream>
#include <sstream>

enum tipus { Egesz, Logikai, Valos };

struct valtozo_leiro
{
	int def_sora;
	tipus vtip;
	valtozo_leiro( int s = 0, tipus t = Egesz )
		: def_sora(s), vtip(t)
	{}
};

struct kifejezes_leiro
{
	int sor;
	tipus ktip;
	kifejezes_leiro( int s, tipus t )
		: sor(s), ktip(t)
    {}
};

struct utasitas_leiro
{
	int sor;
	utasitas_leiro( int s )
		: sor(s)
    {}
};


#endif //SEMANTICS_H
