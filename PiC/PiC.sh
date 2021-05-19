#!/bin/bash

scripts="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pwd=$PWD

cd $pwd/M

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list && sed -i 's/^/M\t/g' list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode ../*.coef &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* &&
fgrep -wvf remove Community_M.txt > Community_M_filtered.txt &&
fgrep -wvf remove ../*.coef > coef.${PWD##*/} &&

echo -e "Leaving level M\n"

cd $pwd/MD

for i in ./*.txt; do fgrep -wvf ../M/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
cp ../M/Community_M_filtered.txt . && mv Community_M_filtered.txt Community_M.txt &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode ../M/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* &&
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove ../M/coef.* > coef.${PWD##*/} &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

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

cd $pwd/MDD

for i in ./*.txt; do fgrep -wvf ../M/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
cp ../MD/Community_M* . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode ../MD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* &&
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove ../MD/coef.* > coef.${PWD##*/} &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 4 &&
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

cd $pwd/MDDD

for i in ./*.txt; do fgrep -wvf ../M/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MDD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
cp ../MDD/Community_M* . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode ../MDD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* &&
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove ../MDD/coef.* > coef.${PWD##*/} &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 5 &&
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

cd $pwd/MDDDD

for i in ./*.txt; do fgrep -wvf ../M/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MDD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
for i in ./*.txt; do fgrep -wvf ../MDDD/remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
cp ../MDDD/Community_M* . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode.sh &&
sh $scripts/SumMatrix.sh indcode ../MDDD/coef.* &&
sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* &&
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove ../MDDD/coef.* > coef.${PWD##*/} &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
sh $scripts/indcode_II.sh 6 &&
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

