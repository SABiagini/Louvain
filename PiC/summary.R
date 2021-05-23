suppressMessages(library(reshape))

args = commandArgs(trailingOnly=TRUE)

tab<-read.table(args[1]) # file "list"
colnames(tab)<-c("Community","ID","val")
table<-cast(tab, ID ~ Community, mean, value = 'val',fill="NA")
write.table(table,"Summary_Table.txt",row.names=FALSE,sep="\t", quote = FALSE)
