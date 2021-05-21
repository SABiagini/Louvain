#!/bin/bash

ind=$1 # 2 column file (no header): SampleID\tLouvainCommunityCode
test=$2 # file.coef (from ibis)

awk 'NR == FNR{a[$1] = $2;next}; {print $1, $1 in a?a[$1]: "NA", $2" "a[$2]" "$3}' $ind $test | tail -n +1 > a.txt &&
perl -p -i -e 's/ /\t/g' a.txt &&
awk 'NR == FNR{a[$1] = $2;next}; {print $2, $1 in a?a[$2]: "NA", $1" "a[$1]" "$3}' $ind $test  | tail -n +1 > b.txt &&
perl -p -i -e 's/ /\t/g' b.txt &&
cat b.txt >> a.txt &&
perl -p -i -e 's/ /\t/g' a.txt &&
rm b.txt &&
datamash -s crosstab 1,4 --filler 0 < a.txt > c1.txt &&
head -n 1 c1.txt > d.txt &&
tail -n +2 c1.txt | sort -k1 > c.txt &&
rm c1.txt &&
awk 'BEGIN{FS=OFS=""} {print (NR>1?0:"ID\tCommunity"), $0}' d.txt > e.txt &&
join -1 1 -2 1 $ind c.txt > f.txt &&
sort f.txt -k 2 > g.txt &&
cat e.txt g.txt > SumMatrix.txt &&
rm a.txt c.txt d.txt e.txt f.txt g.txt &&
datamash -W -s groupby 2 count 2 --filler 0 < SumMatrix.txt | tail -n +2 | cut -f2 | datamash transpose | sed 'N;s/\n/ /' > count &&
sed 's/^/\tN\t/' count > count2 &&
rm count &&
cat count2 SumMatrix.txt > tmp1 &&
awk '{ if (NR==1) { n = split($0, a, "\t"); } for (i=3; i<n; i++) { printf("%.5f\t", ($i/a[i])); } printf("%.5f\n", ($n/a[n])); }' tmp1 | awk '{if(NR>2) print}' > tempmat &&
cut -f1,2 -d' ' tmp1 | cut -f1,2 -d' ' | tail -n +3 > tempcol &&
head -n2 tmp1 > temphead &&
paste tempcol tempmat > tmp2 &&
cat temphead tmp2 > PercMatrix.txt &&
rm count2 tmp1 tempmat tempcol temphead tmp2 
