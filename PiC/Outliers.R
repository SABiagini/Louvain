directory <- getwd()
setwd(directory)
t<-read.table("PercMatrix.txt",h=T,check.names=FALSE)
split <- split(t, t$Community)
library(EnvStats)
library(outliers)
set.seed(10)
for (list in split){
  group<-as.character(list[1,2])
  tab<-list[c("ID","Community",group)]
  colnames(tab)[3] <- "intensity"
  output<-paste("output_",as.character(tab[1,2]),sep="")
  if(length(tab$intensity) >= 25){
    boxplot <- boxplot(tab$intensity)
    lower_bound<-boxplot$stats[1]
    outlier_ind <- which(tab$intensity < lower_bound)
    if (identical(outlier_ind, integer(0))!=TRUE){
      samples <- vector(mode = "numeric")
      k=length(outlier_ind)
      test <- rosnerTest(tab$intensity,k=k)
      inout <- as.character(test$all.stats$Outlier)
      pos <- as.character(test$all.stats$Obs.Num)
      for (i in pos) {
        id<-(as.character(tab[as.numeric(i),1]))
        samples[i] <- id
      }
      result <- as.data.frame(cbind(samples,inout))
      write.table(result,paste(output,"_rosner.txt",sep=""),sep="\t",col.names =FALSE,row.names = F,quote = FALSE)
    }
  } else if (length(tab$intensity) < 25){
    boxplot <- boxplot(tab$intensity)
    lower_bound<-boxplot$stats[1]
    outlier_ind <- which(tab$intensity < lower_bound)
    if (identical(outlier_ind, integer(0))!=TRUE){
      k=length(outlier_ind)
      for (i in 1:k){
        dix<-tab
        test <- dixon.test(dix$intensity)
        inout <- as.character(test$p.value)
        if (inout<0.05){
          inout<-as.character("TRUE")
        }
        else if (inout>=0.05){
          inout<-as.character("FALSE")
        }
        sample <- as.character(dix$ID[as.numeric(outlier_ind)][k])
        result <- as.data.frame(cbind(sample,inout))
        write.table(result,paste(output,"_dixon.txt",sep=""),sep="\t",row.names = F,quote = FALSE,append = TRUE, col.names = FALSE)
        remove_ind <- which.max(dix$intensity)
        dix <- dix[-remove_ind, ]
      }
    }
  }
}
