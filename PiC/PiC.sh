#!/bin/bash

scripts="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
pwd=$PWD

exists()
{ 
  [ -e "$1" ]
}

#
## Level Mother
###

cd $pwd/M

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/M/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list && sed -i 's/^/M\t/g' list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode $pwd/*.coef &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* 
else 
rm list indcode Perc* Sum* 
fi

if [ -s remove ]
then 
fgrep -wvf remove Community_M.txt > Community_M_filtered.txt &&
fgrep -wvf remove ../*.coef > coef.${PWD##*/} &&
echo -e "Leaving level M\n"
cd $pwd/MD
for i in ./*.txt; do fgrep -wvf $pwd/M/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done 
else 
cp Community_M.txt Community_M_filtered.txt &&
cp ../*.coef  coef.${PWD##*/} &&
echo -e "Leaving level M\n"
cd $pwd/MD
fi

#
## Level Daughter I
###

cp $pwd/M/Community_M_filtered.txt . && mv Community_M_filtered.txt Community_M.txt &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode $pwd/M/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* 
else 
rm list indcode Perc* Sum* 
fi

if [ -s remove ]
then 
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove $pwd/M/coef.* > coef.${PWD##*/} 
else 
cp ../M/coef.*  coef.${PWD##*/} 
fi

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 3 &&
sh $scripts/SumMatrix.sh indcode coef.* &&
tail -n +3 PercMatrix.txt | cut -f 1 > alpha &&
cut -f2- PercMatrix.txt | tail -n +3 > main &&
head -n1 PercMatrix.txt > header1 &&
head -n2 PercMatrix.txt | tail -n1 > header2 &&
sed -i 's/ /\t/g' alpha && 
perl $scripts/alphaConv.pl alpha &&
paste indcode_alpha main > main2 &&
rm main alpha indcode_alpha &&
tr '\t' '\n' < header2 > header2_tr &&
sed -i 's/^/fakeID\t/g' header2_tr &&
perl $scripts/alphaConv.pl header2_tr &&
echo -e "ID\nCommunity" > header3 | cut -f2 indcode_alpha | sed -r '/^\s*$/d' >> header3 &&
tr '\n' '\t' < header3 > header3_tr &&
echo "" >> header3_tr &&
cat header1 header3_tr main2 > PercMatrix_alpha.txt &&
rm header1 header2 main2 header2_tr header3 indcode_alpha header3_tr &&
echo -e "Leaving level MD\n"

#
## Level Daughter II
###

cd $pwd/MDD
cat $pwd/*/remove >  $pwd/MDD/REMOVE

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MDD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done 
fi

cp $pwd/MD/Community_M.txt . &&
while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode $pwd/MD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* 
else 
rm list indcode Perc* Sum* 
fi

if [ -s remove ]
then 
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove $pwd/MD/coef.* > coef.${PWD##*/} 
else 
cp ../MD/coef.*  coef.${PWD##*/} 
fi

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 3 &&
sh $scripts/SumMatrix.sh indcode coef.* &&
tail -n +3 PercMatrix.txt | cut -f 1 > alpha &&
cut -f2- PercMatrix.txt | tail -n +3 > main &&
head -n1 PercMatrix.txt > header1 &&
head -n2 PercMatrix.txt | tail -n1 > header2 &&
sed -i 's/ /\t/g' alpha && 
perl $scripts/alphaConv.pl alpha &&
paste indcode_alpha main > main2 &&
rm main alpha indcode_alpha &&
tr '\t' '\n' < header2 > header2_tr &&
sed -i 's/^/fakeID\t/g' header2_tr &&
perl $scripts/alphaConv.pl header2_tr &&
echo -e "ID\nCommunity" > header3 | cut -f2 indcode_alpha | sed -r '/^\s*$/d' >> header3 &&
tr '\n' '\t' < header3 > header3_tr &&
echo "" >> header3_tr &&
cat header1 header3_tr main2 > PercMatrix_alpha.txt &&
rm header1 header2 main2 header2_tr header3 indcode_alpha header3_tr &&

echo -e "Leaving level MDD\n"

#
## Level Daughter III
###

cd $pwd/MDDD
cat $pwd/*/remove > $pwd/MDDD/REMOVE

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MDDD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done 
fi

cp $pwd/MDD/Community_M.txt . &&
while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode $pwd/MDD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* 
else 
rm list indcode Perc* Sum* 
fi

if [ -s remove ]
then 
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove $pwd/MDD/coef.* > coef.${PWD##*/} 
else 
cp ../MDD/coef.*  coef.${PWD##*/} 
fi

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&
Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 3 &&
sh $scripts/SumMatrix.sh indcode coef.* &&
tail -n +3 PercMatrix.txt | cut -f 1 > alpha &&
cut -f2- PercMatrix.txt | tail -n +3 > main &&
head -n1 PercMatrix.txt > header1 &&
head -n2 PercMatrix.txt | tail -n1 > header2 &&
sed -i 's/ /\t/g' alpha && 
perl $scripts/alphaConv.pl alpha &&
paste indcode_alpha main > main2 &&
rm main alpha indcode_alpha &&
tr '\t' '\n' < header2 > header2_tr &&
sed -i 's/^/fakeID\t/g' header2_tr &&
perl $scripts/alphaConv.pl header2_tr &&
echo -e "ID\nCommunity" > header3 | cut -f2 indcode_alpha | sed -r '/^\s*$/d' >> header3 &&
tr '\n' '\t' < header3 > header3_tr &&
echo "" >> header3_tr &&
cat header1 header3_tr main2 > PercMatrix_alpha.txt &&
rm header1 header2 main2 header2_tr header3 indcode_alpha header3_tr &&
echo -e "Leaving level MDDD\n"

#
## Level Daughter IV
###

cd $pwd/MDDDD
cat $pwd/*/remove > $pwd/MDDDD/REMOVE

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MDDDD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done 
fi

cp $pwd/MDDD/Community_M.txt . &&
while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode $pwd/MDDD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* 
else 
rm list indcode Perc* Sum* 
fi

if [ -s remove ]
then 
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove $pwd/MDDD/coef.* > coef.${PWD##*/} 
else 
cp ../MDDD/coef.*  coef.${PWD##*/} 
fi

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 3 &&
sh $scripts/SumMatrix.sh indcode coef.* &&
tail -n +3 PercMatrix.txt | cut -f 1 > alpha &&
cut -f2- PercMatrix.txt | tail -n +3 > main &&
head -n1 PercMatrix.txt > header1 &&
head -n2 PercMatrix.txt | tail -n1 > header2 &&
sed -i 's/ /\t/g' alpha && 
perl $scripts/alphaConv.pl alpha &&
paste indcode_alpha main > main2 &&
rm main alpha indcode_alpha &&
tr '\t' '\n' < header2 > header2_tr &&
sed -i 's/^/fakeID\t/g' header2_tr &&
perl $scripts/alphaConv.pl header2_tr &&
echo -e "ID\nCommunity" > header3 | cut -f2 indcode_alpha | sed -r '/^\s*$/d' >> header3 &&
tr '\n' '\t' < header3 > header3_tr &&
echo "" >> header3_tr &&
cat header1 header3_tr main2 > PercMatrix_alpha.txt &&
rm header1 header2 main2 header2_tr header3 indcode_alpha header3_tr &&

echo -e "Leaving level MDDDD\n"

cd ..

echo -e "Done!\n"
