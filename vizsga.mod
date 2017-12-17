# Data

set Targyak;
set Napok:= 1..49;

param szabadIdo {Napok};
param tanulasIdo {Targyak};
param vizsgak {Napok, Targyak};
param kredit {Targyak};


# Variables

var tanul {Targyak, Napok} binary;
var nemTanul {Targyak, Napok} binary;
var vizsgazik {Napok, Targyak} binary;
var nemTanulLevizsgazott {Targyak, Napok} binary;
var tanultOrak {Targyak} >=0;
var kapottJegy {Targyak} >=0 integer <=5;
var atlag >=0;


# Constraints

# Csak vizsganapon lehet vizsgazni
s.t. Vizsganap {t in Targyak, n in Napok}:
	vizsgazik[n,t] <= 1 - 1*(1-vizsgak[n,t]);

# Egy tárgyból legfeljebb egyszer vizsgázom
s.t. EgyVizsga {t in Targyak}:
	sum {n in Napok}vizsgazik[n,t]=1;

# Miután vizsgáztam, a többi napon már nem tanulok az adott tárgyból
s.t. VizsgaUtanNemTanulokATargybol {t in Targyak, n in 2..49}:
	nemTanulLevizsgazott[t,n]>=vizsgazik[n-1,t];
s.t. NemTanulVizsgaUtan2 {t in Targyak, n in 2..49}:
	nemTanulLevizsgazott[t,n]>=nemTanulLevizsgazott[t,n-1];

# Egy nap csak egy tárgyból készülök, vagy vizsgázom
s.t. EgyNapEgyTargybolTanulasVagyVizsga {n in Napok, t in Targyak}:
	tanul[t,n]+vizsgazik[n,t]+nemTanulLevizsgazott[t,n]+nemTanul[t,n] = 1;

# Minden nap, vagy tanulok, vagy vizsgazom
s.t. MindenNapCsinalokValamit {n in Napok}:
	sum {t in Targyak} (tanul[t,n]+vizsgazik[n,t]) <= 1;

# Egy tárgyat max 2 egymást követõ napon tanulok
s.t. Valtozatossag {t in Targyak, n in 3..49}:
	tanul[t,n] <= 0 + 1*(2-tanul[t,n-1]-tanul[t,n-2]);

# Ha vizsgázok, akkor az nap nem tanulok (lehet nem kell az elsõ miatt)
s.t. HaVizsgazomNemTanulok {t in Targyak, n in Napok}:
	tanul[t,n] <= 0 + 1*(1-vizsgazik[n,t]);

# Tanult órák
s.t. TanultOrak {t in Targyak}:
	tanultOrak[t] = sum {n in Napok} tanul[t,n]*szabadIdo[n];

# Milyen jegyet kapok a vizsgán, a tanult órák alapján
s.t. KapottJegy {t in Targyak}:
	kapottJegy[t] <= tanultOrak[t]/tanulasIdo[t];

# Átlag (jegy*kredit/ossz kredit)
s.t. AtlagKiszamolas:
	atlag = (sum {t in Targyak} kapottJegy[t]*kredit[t])/(sum {t in Targyak}kredit[t]);


# Objective

# Minél jobb átlag elérése
maximize Atlag:
		atlag;

solve;

printf "\nVizsgaidõszak:\n---------------------------\n";
printf "Átlag: %.3f\n\n",atlag;
printf "Jegyek:\n";
for {t in Targyak: kapottJegy[t]>=0}
{
	printf "%s: %d (%.2f tanult óra)\n",t,kapottJegy[t], tanultOrak[t];
}

printf "\n";
for {n in Napok}
{
	printf "%d. napon:\n",n;
	for {t in Targyak: tanul[t,n]>0}
	{
		printf "Tanul: %s\n",t;
	}
	for {t in Targyak: vizsgazik[n,t]>0}
	{
		printf "Vizsgazik: %s\n",t;
	}
}


