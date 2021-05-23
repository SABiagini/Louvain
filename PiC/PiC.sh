#!/bin/bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pwd=$PWD

exists()
{ 
  [ -e "$1" ]
}

sed 's/://g' $pwd/Community_M_pval.txt | cut -d' ' -f3,5 | awk '$2>0.05'| cut -d' ' -f1 > $pwd/M_rem && fgrep -wvf $pwd/M_rem $pwd/M/Community_M.txt > $pwd/M/Community_M_tmp && fgrep -wvf $pwd/M/Community_M_tmp $pwd/M/Community_M.txt | cut -f1 > $pwd/REM && rm $pwd/M/Community_M.txt && mv $pwd/M/Community_M_tmp $pwd/M/Community_M.txt && fgrep -vwf REM *.coef > M/filt.coef && rm REM &&

for i in $pwd/*/*.txt
do
LINECOUNT=`wc -l $i | cut -f1 -d' '`

if [[ $LINECOUNT == 1 ]]; then
   rm -f $i
fi
done

rm $pwd/*_rem &&

#
## Level Mother
###

cd $pwd/M &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/M/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list && sed -i 's/^/M\t/g' list &&

Rscript $scripts/summary.R list &&

tail -n +2 Summary_Table.txt > indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode filt.coef &&

sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  

cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* Rplots.pdf &&

cat $pwd/M/remove >  $pwd/MD/REMOVE &&
cat $pwd/M/remove >  $pwd/MDD/REMOVE &&
cat $pwd/M/remove >  $pwd/MDDD/REMOVE &&

fgrep -wvf remove Community_M.txt > Community_M_filtered.txt &&
fgrep -wvf remove filt.coef > coef.${PWD##*/} &&
rm filt.coef Community_M.txt && mv Community_M_filtered.txt Community_M.txt

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/M/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list && sed -i 's/^/M\t/g' list &&

Rscript $scripts/summary.R list &&

awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode coef.* 

else 

sh $scripts/SumMatrix.sh indcode filt.coef &&
rm list indcode Rplots.pdf 
mv filt.coef coef.${PWD##*/} 
fi

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

echo -e "First Level done! Leaving Level M.."

#
## Level Daughter I
###

cd $pwd

echo -e '#!/bin/bash' > MD_rem && sed 's/://g' Community_MD_pval.txt | cut -d' ' -f2,3 | sed 's/M//' | sed 's/D/-/g' | awk '$2>0.05'| cut -d' ' -f1 | sed 's/\-/ /g' - | sed 's/^/Community_M/g' - | sed 's/ /D\.txt /g' - | awk '{print "fgrep -wv",$2,"MD/"$1" >","MD/"$1$2"_tmp && fgrep -wvf MD/"$1$2"_tmp","MD/"$1,"| cut -f1 >> REM","&& rm MD/"$1,"&& mv MD/"$1$2"_tmp","MD/"$1,"&&"}' >> MD_rem &&  echo "exit" >> MD_rem && sh MD_rem && fgrep -vwf REM M/coef.M > MD/filt.coef && rm REM &&

cd $pwd/MD

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
rm $pwd/MD/REMOVE
fi

cp $pwd/M/Community_M.txt . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode filt.coef &&

sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  

cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* Rplots.pdf &&

cat $pwd/MD/remove >>  $pwd/MDD/REMOVE &&
cat $pwd/MD/remove >>  $pwd/MDDD/REMOVE &&

for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&

fgrep -wvf remove filt.coef > coef.${PWD##*/} &&
rm filt.coef &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode coef.* 

else 
sh $scripts/SumMatrix.sh indcode $pwd/M/coef.* &&
rm list indcode Rplots.pdf &&
mv filt.coef coef.${PWD##*/} 
fi

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

echo -e "Second Level done! Leaving Level MD.."

#
## Level Daughter II
###

cd $pwd && 

echo -e '#!/bin/bash' > MDD_rem && sed 's/://g' Community_MDD_pval.txt | cut -d' ' -f2,3 | sed 's/M//' | sed 's/D/-/g' | awk '$2>0.05'| cut -d' ' -f1 | sed 's/\-/ /g' - | sed 's/^/Community_M/g' - | sed 's/ /D /g' - | awk '{print $1$2".txt",$3}' | awk '{print "fgrep -wv",$2,"MDD/"$1" >","MDD/"$1$2"_tmp && fgrep -wvf MDD/"$1$2"_tmp","MDD/"$1,"| cut -f1 >> REM","&& rm MDD/"$1,"&& mv MDD/"$1$2"_tmp","MDD/"$1,"&&"}' >> MDD_rem &&  echo "exit" >> MDD_rem && sh MDD_rem && fgrep -vwf REM MD/coef.MD > MDD/filt.coef && rm REM &&

cd $pwd/MDD

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MDD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
rm $pwd/MDD/REMOVE 
fi

cp $pwd/MD/Community* . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode filt.coef &&

sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  

cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* Rplots.pdf 

cat $pwd/MDD/remove >>  $pwd/MDDD/REMOVE &&

for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove filt.coef > coef.${PWD##*/} &&
rm filt.coef  &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode coef.* 

else 

sh $scripts/SumMatrix.sh indcode filt.coef &&
rm list indcode Rplots.pdf &&
mv filt.coef coef.${PWD##*/} 
fi

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

echo -e "Third Level done! Leaving Level MDD.."

#
## Level Daughter III
###

cd $pwd

echo -e '#!/bin/bash' > MDDD_rem && sed 's/://g' Community_MDDD_pval.txt | cut -d' ' -f2,3 | sed 's/M//' | sed 's/D/-/g' | awk '$2>0.05'| cut -d' ' -f1 | sed 's/\-/ /g' - | sed 's/^/Community_M/g' - | sed 's/ /D /g' - | awk '{print $1$2$3".txt",$4}' | awk '{print "fgrep -wv",$2,"MDDD/"$1" >","MDDD/"$1$2"_tmp && fgrep -wvf MDDD/"$1$2"_tmp","MDDD/"$1,"| cut -f1 >> REM","&& rm MDDD/"$1,"&& mv MDDD/"$1$2"_tmp","MDDD/"$1,"&&"}' >> MDDD_rem &&  echo "exit" >> MDDD_rem && sh MDDD_rem && fgrep -vwf REM MDD/coef.MDD > MDDD/filt.coef && rm REM &&

cd $pwd/MDDD 

if [ -s REMOVE ]
then
for i in ./*.txt; do fgrep -wvf $pwd/MDDD/REMOVE $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
rm $pwd/MDDD/REMOVE 
fi

cp $pwd/MDD/Community* . &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode filt.coef &&

sed -i 1d PercMatrix.txt &&
Rscript $scripts/Outliers.R &&

if exists output_*
then  
cut -f1,2 output_* | grep TRUE | cut -f1 | sed -r '/^\s*$/d' > remove &&
rm output_* list indcode Perc* Sum* Rplots.pdf 
for i in ./*.txt; do fgrep -wvf remove $i > ${i%.*}_filtered.txt && rm $i && mv ${i%.*}_filtered.txt $i; done &&
fgrep -wvf remove filt.coef > coef.${PWD##*/} &&
rm filt.coef &&

while IFS=$'\t' read -r id m; do grep $id ./*txt;done< $pwd/MDDD/Community_M.txt | grep -Pv 'ID\tCommunity' | sed 's/\.\/Community_//g' | sed 's/\.txt//g' | sed 's/\:/\t/g' | sed 's/M[0-9]\+D\t/MD\t/g' | sed 's/M[0-9]\+D[0-9]\+D\t/MDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDD\t/g' | sed 's/M[0-9]\+D[0-9]\+D[0-9]\+D[0-9]\+D\t/MDDDD\t/g' > list &&

Rscript $scripts/summary.R list &&

awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' Summary_Table.txt > indcode &&
sed -i 's/\-NA/ /g' indcode &&
sed -i 's/\-\-//g' indcode &&
sed -i 's/\-$//g' indcode &&
sed -i 's/\- \-//g' indcode &&
sed -i 's/\- \- \-//g' indcode &&
sed -i 's/\- \- \- \-//g' indcode &&
sed -i 's/\- \- \- \- \-//g' indcode &&
cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp &&
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2 &&
rm indcode tmp &&
mv indcode2 indcode &&

sh $scripts/SumMatrix.sh indcode coef.* 

else 
sh $scripts/SumMatrix.sh indcode $pwd/MDD/coef.* &&
rm list indcode Rplots.pdf &&
mv filt.coef coef.${PWD##*/} 
fi

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

echo -e "Fourth Level done! Leaving Level MDDD.."

cd $pwd

rm *rem */Summary_Table.txt */remove */list */indcode 

echo -e "Done!"
