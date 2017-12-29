# Data

set Targyak;
param napokSzama;
set Napok:= 1..napokSzama;

param szabadIdo {Napok};
param tanulasIdo {Targyak};
param vizsgak {Napok, Targyak};
param kredit {Targyak};


# Variables

var tanul {Targyak, Napok} binary;
var vizsgazik {Napok, Targyak} binary;
var tanultOrak {Targyak} >=0;
var kapottJegy {Targyak} >=0 integer <=5;
var atlag >=0;


# Constraints

# Csak vizsganapon lehet vizsgazni
s.t. Vizsganap {t in Targyak, n in Napok}:
	vizsgazik[n,t] <= vizsgak[n,t];

# Egy targybol egyszer vizsgazom
s.t. EgyVizsga {t in Targyak}:
	sum {n in Napok}vizsgazik[n,t] = 1;

# Miutan vizsgaztam, a tobbi napon mar nem tanulok az adott targybol
s.t. VizsgaUtanNemTanulokATargybol {t in Targyak, n in Napok, n1 in Napok : n1 >= n}:
	tanul[t,n1] <= 1-vizsgazik[n,t];

# Egy nap csak egy targybol keszulok, vagy vizsgazom
s.t. EgyNapEgyTargybolTanulasVagyVizsga {n in Napok, t in Targyak}:
	tanul[t,n]+vizsgazik[n,t] <= 1;

# Minden nap, vagy tanulok, vagy vizsgazom
s.t. MindenNapCsinalokValamit {n in Napok}:
	sum {t in Targyak} (tanul[t,n]+vizsgazik[n,t]) <= 1;

# Egy targyat max 2 egymast koveto napon tanulok
s.t. Valtozatossag {t in Targyak, n in Napok : n>=3}:
	tanul[t,n]+tanul[t,n-1]+tanul[t,n-2] <= 2;

# Ha vizsgazok, akkor az nap nem tanulok (lehet nem kell az elso miatt)
s.t. HaVizsgazomNemTanulok {t in Targyak, n in Napok}:
	tanul[t,n] <= 1-vizsgazik[n,t];

# Tanult orak
s.t. TanultOrak {t in Targyak}:
	tanultOrak[t] = sum {n in Napok} tanul[t,n]*szabadIdo[n];

# Milyen jegyet kapok a vizsgan, a tanult orak alapjan
s.t. KapottJegy {t in Targyak}:
	kapottJegy[t] <= tanultOrak[t]/tanulasIdo[t];

# Atlag (jegy*kredit/ossz kredit)
s.t. AtlagKiszamolas:
	atlag = (sum {t in Targyak} kapottJegy[t]*kredit[t])/(sum {t in Targyak}kredit[t]);


# Objective

# Minel jobb atlag elerese
maximize Atlag:
		atlag;

solve;

printf "\nVizsgaidoszak:\n---------------------------\n";
printf "Atlag: %.3f\n\n",atlag;
printf "Jegyek:\n";
for {t in Targyak: kapottJegy[t]>=0}
{
	printf "%s: %d (%.2f tanult ora)\n",t,kapottJegy[t], tanultOrak[t];
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
