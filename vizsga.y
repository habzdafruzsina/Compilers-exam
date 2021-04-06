%baseclass-preinclude "semantics.h"

%lsp-needed

%union
{
    std::string *szoveg;
    kifejezes_leiro *kif;
    utasitas_leiro *utasitas;
}

%token <szoveg> VALOS_SZAMKONSTANS
%token <szoveg> SZAMKONSTANS
%token PROGRAM
%token VALTOZOK
%token UTASITASOK
%token PROGRAM_VEGE
%token HA
%token AKKOR
%token KULONBEN
%token HA_VEGE
%token CIKLUS
%token AMIG
%token CIKLUS_VEGE
%token BE
%token KI
%token EGESZ
%token VALOS
%token LOGIKAI
%token ERTEKADAS
%token BALZAROJEL
%token JOBBZAROJEL
%token <szoveg> AZONOSITO
%token IGAZ
%token HAMIS
%token SKIP
%token EGESZRESZ
%token TORTRESZ

%left VAGY
%left ES
%left NEM
%left EGYENLO
%left KISEBB NAGYOBB KISEBBEGYENLO NAGYOBBEGYENLO
%left PLUSZ MINUSZ
%left SZORZAS OSZTAS MARADEK

%type <kif> kifejezes
%type <utasitas> ertekadas
%type <utasitas> be
%type <utasitas> ki
%type <utasitas> elagazas
%type <utasitas> ciklus
%type <utasitas> utasitas
%type <utasitas> utasitasok
%type <utasitas> utasitaslista
%type <utasitas> deklaracio
%type <utasitas> deklaraciok
%type <utasitas> valtozolista
%type <utasitas> kezdes
%type <utasitas> befejezes

%%

start:
    kezdes deklaraciok utasitasok befejezes
    {
        delete $1;
        delete $2;
        delete $3;
        delete $4;
    }
;

kezdes:
    PROGRAM AZONOSITO
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
    }
;

befejezes:
    PROGRAM_VEGE
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
    }
;

deklaraciok:
    // ures
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
    }
|
    VALTOZOK valtozolista
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
        delete $2;
    }
;

valtozolista:
    deklaracio
|
    deklaracio valtozolista
    {
        $$ = new utasitas_leiro( $1->sor );
        delete $1;
        delete $2;
    }
;

deklaracio:
    EGESZ AZONOSITO
    {
        if( szimb_tabla.count(*$2) > 0 )
        {
            std::cerr << d_loc__.first_line << ".: A(z) '" << *$2 << "' valtozo mar definialva volt a "
            << szimb_tabla[*$2].def_sora << ". sorban." << std::endl;
            exit(1);
        }
        else
        {
            szimb_tabla[*$2] = valtozo_leiro(d_loc__.first_line,Egesz);
            $$ = new utasitas_leiro( d_loc__.first_line );
        }
        delete $2;
    }
|
    LOGIKAI AZONOSITO
    {
        if( szimb_tabla.count(*$2) > 0 )
        {
            std::cerr << d_loc__.first_line << ": A(z) '" << *$2 << "' valtozo mar definialva volt a "
            << szimb_tabla[*$2].def_sora << ". sorban." << std::endl;
            exit(1);
        }
        else
        {
            szimb_tabla[*$2] = valtozo_leiro(d_loc__.first_line,Logikai);
            $$ = new utasitas_leiro( d_loc__.first_line );
        }
        delete $2;
    }
|
    VALOS AZONOSITO
    {
        if( szimb_tabla.count(*$2) > 0 )
        {
            std::cerr << d_loc__.first_line << ": A(z) '" << *$2 << "' valtozo mar definialva volt a "
            << szimb_tabla[*$2].def_sora << ". sorban." << std::endl;
            exit(1);
        }
        else
        {
            szimb_tabla[*$2] = valtozo_leiro(d_loc__.first_line,Valos);
            $$ = new utasitas_leiro( d_loc__.first_line );
        }
        delete $2;
    }
;

utasitasok:
    UTASITASOK utasitas utasitaslista
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
        delete $2;
        delete $3;
    }
;

utasitaslista:
    // epsilon
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
    }
|
    utasitas utasitaslista
    {
        $$ = new utasitas_leiro( $1->sor );
        delete $1;
        delete $2;
    }
;

utasitas:
    SKIP
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
    }
|
    ertekadas
|
    be
|
    ki
|
    elagazas
|
    ciklus
;

ertekadas:
    AZONOSITO ERTEKADAS kifejezes
    {
        if( szimb_tabla.count( *$1 ) == 0 )
        {
            std::cerr << d_loc__.first_line << ": A(z) '" << *$1 << "' valtozo nincs deklaralva." << std::endl;
            exit(1);
        }
        else if( szimb_tabla[*$1].vtip != $3->ktip )
        {
            std::cerr << d_loc__.first_line << ": Az ertekadas jobb- es baloldalan kulonbozo tipusu kifejezesek allnak." << std::endl;
            exit(1);
        }
        else
        {
            $$ = new utasitas_leiro( d_loc__.first_line );
        }
        delete $3;
    }
;

be:
    BE AZONOSITO
    {
        if( szimb_tabla.count( *$2 ) == 0 )
        {
            std::cerr << d_loc__.first_line << ": A(z) '" << *$2 << "' valtozo nincs deklaralva." << std::endl;
            exit(1);
        }
        else
        {
            $$ = new utasitas_leiro( d_loc__.first_line );
        }
        delete $2;
    }
;

ki:
    KI kifejezes
    {
        $$ = new utasitas_leiro( d_loc__.first_line );
        delete $2;
    }
;

elagazas:
    HA kifejezes AKKOR utasitas utasitaslista HA_VEGE
    {
        if( $2->ktip != Logikai )
        {
            std::cerr << d_loc__.first_line << ": Nem logikai tipusu az elagazas feltetele." << std::endl;
            exit(1);
        }
        else
        {
            $$ = new utasitas_leiro( $2->sor );
        }
        delete $2;
        delete $4;
        delete $5;
    }
|
    HA kifejezes AKKOR utasitas utasitaslista KULONBEN utasitas utasitaslista HA_VEGE
    {
        if( $2->ktip != Logikai )
        {
            std::cerr << d_loc__.first_line << ": Nem logikai tipusu az elagazas feltetele." << std::endl;
            exit(1);
        }
        else
        {
            $$ = new utasitas_leiro( $2->sor );
        }
        delete $2;
        delete $4;
        delete $5;
        delete $7;
        delete $8;
    }
;

ciklus:
    CIKLUS AMIG kifejezes utasitas utasitaslista CIKLUS_VEGE
    {
        if( $3->ktip != Logikai )
        {
            std::cerr << d_loc__.first_line << ": Nem logikai tipusu a ciklus feltetele." << std::endl;
            exit(1);
        }
        else
        {
            $$ = new utasitas_leiro( $3->sor );
        }
        delete $3;
        delete $4;
        delete $5;
    }
;

kifejezes:
    SZAMKONSTANS
    {
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
    }
|
    VALOS_SZAMKONSTANS
    {
        $$ = new kifejezes_leiro( d_loc__.first_line, Valos );
        delete $1;
    }
|
    IGAZ
    {
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
    }
|
    HAMIS
    {
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
    }
|
    AZONOSITO
    {
        if( szimb_tabla.count( *$1 ) == 0 )
        {
            std::cerr << d_loc__.first_line << ": A(z) '" << *$1 << "' valtozo nincs deklaralva." << std::endl;
            exit(1);
        }
        else
        {
            valtozo_leiro vl = szimb_tabla[*$1];
            $$ = new kifejezes_leiro( vl.def_sora, vl.vtip );
            delete $1;
        }
    }
|
    kifejezes PLUSZ kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '+' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '+' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
        delete $3;
    }
|
    kifejezes MINUSZ kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '-' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '-' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
        delete $3;
    }
|
    kifejezes SZORZAS kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '*' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '*' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
        delete $3;
    }
|
    kifejezes OSZTAS kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '/' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '/' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
        delete $3;
    }
|
    kifejezes MARADEK kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '%' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '%' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Egesz );
        delete $1;
        delete $3;
    }
|
    kifejezes KISEBB kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '<' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '<' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes NAGYOBB kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '>' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '>' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes KISEBBEGYENLO kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '<=' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '<=' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes NAGYOBBEGYENLO kifejezes
    {
        if( $1->ktip != Egesz )
        {
            std::cerr << $1->sor << ": A '>=' operator baloldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Egesz )
        {
            std::cerr << $3->sor << ": A '>=' operator jobboldalan nem egesz tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes EGYENLO kifejezes
    {
        if( $1->ktip != $3->ktip )
        {
            std::cerr << $1->sor << ": Az '=' operator jobb- es baloldalan kulonbozo tipusu kifejezesek allnak." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes ES kifejezes
    {
        if( $1->ktip != Logikai )
        {
            std::cerr << $1->sor << ": Az 'ES' operator baloldalan nem logikai tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Logikai )
        {
            std::cerr << $3->sor << ": Az 'ES' operator jobboldalan nem logikai tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    kifejezes VAGY kifejezes
    {
        if( $1->ktip != Logikai )
        {
            std::cerr << $1->sor << ": A 'VAGY' operator baloldalan nem logikai tipusu kifejezes all." << std::endl;
            exit(1);
        }
        if( $3->ktip != Logikai )
        {
            std::cerr << $3->sor << ": A 'VAGY' operator jobboldalan nem logikai tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $1;
        delete $3;
    }
|
    NEM kifejezes
    {
        if( $2->ktip != Logikai )
        {
            std::cerr << $2->sor << ": A 'NEM' operator utan nem logikai tipusu kifejezes all." << std::endl;
            exit(1);
        }
        $$ = new kifejezes_leiro( d_loc__.first_line, Logikai );
        delete $2;
    }
|
    BALZAROJEL kifejezes JOBBZAROJEL
    {
        $$ = $2;
    }
|
    EGESZRESZ BALZAROJEL kifejezes JOBBZAROJEL
    {
        if( $3->ktip != Valos )
        {
            std::cerr << $3->sor << ": Az egeszresz fuggveny parameterul csak valos tipusu erteket kaphat." << std::endl;
            exit(1);
        }
	$$ = new kifejezes_leiro( d_loc__.first_line, Egesz);
        delete $3;
    }
|
    TORTRESZ BALZAROJEL kifejezes JOBBZAROJEL
    {
        if( $3->ktip != Valos )
        {
            std::cerr << $3->sor << ": A tortresz fuggveny parameterul csak valos tipusu erteket kaphat." << std::endl;
            exit(1);
        }
	$$ = new kifejezes_leiro( d_loc__.first_line, Egesz);
        delete $3;
    }
;
