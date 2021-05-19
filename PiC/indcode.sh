#!/bin/bash

awk '{if ($3=="NA") {$2="NA"} else {$2==$2}}1' Summary_Table.txt > filter1
awk '{if ($4=="NA") {$3="NA"} else {$3==$3}}1' filter1 > filter2
awk '{if ($5=="NA") {$4="NA"} else {$4==$4}}1' filter2 > filter3
awk '{if ($6=="NA") {$5="NA"} else {$5==$5 && $6="NA"}}1' filter3 > filter4
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' filter4 > indcode

sed -i 's/NA//g' indcode
sed -i 's/\-\-//g' indcode
sed -i 's/\-$//g' indcode

cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp 
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2
rm indcode tmp filter* 
mv indcode2 indcode
