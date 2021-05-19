library(psych)
library(igraph)
library(exactRankTests)
library(data.table)

community.significance.test <- function(graph, vs, ...) {
  if (is.directed(graph)) stop("This method requires an undirected graph")
  subgraph <- induced.subgraph(graph, vs)
  in.degrees <- degree(subgraph)
  out.degrees <- degree(graph, vs) - in.degrees
  return(wilcox.exact(in.degrees, out.degrees, ...)$p.value)
}

args = commandArgs(trailingOnly=TRUE)

data <- fread(args[1])
write(paste("Reading Input done."), stderr())
edges <- as.data.frame(data)
colnames(edges) <- c("from", "to", "weight")
g <- graph_from_data_frame(edges, directed = FALSE)
write(paste("Object igraph generated."), stderr())
write(paste("At level M the number of nodes is:"), stderr())
vcount(g)
write(paste("For a total number of edges (nodes' connections):"), stderr())
ecount(g)
clusterlouvain <- cluster_louvain(g)
write(paste("At this level, samples are distributed as follow:"), stderr())
sizes(clusterlouvain)
nclust<-length(clusterlouvain)
write(paste("Louvain level M done! It contains",nclust,"communities"), stderr())
IDs_cluster <- cbind(V(g)$name, clusterlouvain$membership)
df<-as.data.frame(IDs_cluster)
df$V2 <- as.numeric(as.character(df$V2))
sort<-df[order(df$V2),]
dir.create("M")
write.table(sort,"M/Community_M.txt",sep="\t",col.names =c("ID","Community"),row.names = F,quote = FALSE)
result=c()
for (i in 1:length(clusterlouvain)){
	vs = (membership(clusterlouvain)==i)
	result = c(result,community.significance.test(g,vs))
	# Print pvalues for level 1 in a dedicated file
	write(paste("Community M",i,":", result[i]),file="Community_M_pval.txt",append=TRUE)
}
x = 0
for(val in result){
	if(val<0.05){
		x=x+1
		Keep = (membership(clusterlouvain)==x)
		g2 = induced_subgraph(g, Keep)
		clusterlouvain2 = cluster_louvain(g2)
		sizes(clusterlouvain2)
		nclust2<-length(clusterlouvain2)
		IDs_cluster2 <- cbind(V(g2)$name, clusterlouvain2$membership)
		df2<-as.data.frame(IDs_cluster2)
		df2$V2 <- as.numeric(as.character(df2$V2))
		sort2<-df2[order(df2$V2),]
		dir.create("MD")
		write.table(sort2,paste("MD/Community_M",x,"D.txt",sep = ""),sep="\t",col.names =c("ID","Community"),row.names = F,quote = FALSE)
		result2=c()
			for (y in 1:length(clusterlouvain2)){
			vs2 = (membership(clusterlouvain2)==y)
			result2 = c(result2,community.significance.test(g2,vs2))
			write(paste("Community M",x,"D",y,": ", result2[y],sep=""),file=paste("Community_MD_pval.txt",sep=""),append=TRUE)
		}	
		p = 0
		for(val2 in result2){
			if(val2<0.05){
				p = p + 1
				Keep2 = (membership(clusterlouvain2)==p)
				g3 = induced_subgraph(g2, Keep2)
				clusterlouvain3 = cluster_louvain(g3)
				sizes(clusterlouvain3)
				nclust3<-length(clusterlouvain3)
				IDs_cluster3 <- cbind(V(g3)$name, clusterlouvain3$membership)
				df3<-as.data.frame(IDs_cluster3)
				df3$V2 <- as.numeric(as.character(df3$V2))
				sort3<-df3[order(df3$V2),]
				dir.create("MDD")
				write.table(sort3,paste("MDD/Community_M",x,"D",p,"D.txt",sep = ""),sep="\t",col.names =c("ID","Community"),row.names = F,quote = FALSE)	
				result3=c()
					for (z in 1:length(clusterlouvain3)){
					vs3 = (membership(clusterlouvain3)==z)
					result3 = c(result3,community.significance.test(g3,vs3))
					write(paste("Community M",x,"D",p,"D",z,": ", result3[z],sep=""),file=paste("Community_MDD_pval.txt",sep=""),append=TRUE)
				}		
				s = 0
				for(val3 in result3){
					if(val3<0.05){
						s = s + 1
						Keep3 = (membership(clusterlouvain3)==s)
						g4 = induced_subgraph(g3, Keep3)
						clusterlouvain4 = cluster_louvain(g4)
						sizes(clusterlouvain4)
						nclust4<-length(clusterlouvain4)
						IDs_cluster4 <- cbind(V(g4)$name, clusterlouvain4$membership)
						df4<-as.data.frame(IDs_cluster4)
						df4$V2 <- as.numeric(as.character(df4$V2))
						sort4<-df4[order(df4$V2),]
						dir.create("MDDD")
						write.table(sort4,paste("MDDD/Community_M",x,"D",p,"D",s,"D.txt",sep = ""),sep="\t",col.names =c("ID","Community"),row.names = F,quote = FALSE)
						result4=c()
						for (r in 1:length(clusterlouvain4)){
							vs4 = (membership(clusterlouvain4)==r)
							result4 = c(result4,community.significance.test(g4,vs4))
							write(paste("Community M",x,"D",p,"D",s,"D",r,": ",result4[r],sep=""),file=paste("Community_MDDD_pval.txt",sep=""),append=TRUE)
						}
						u = 0
						for(val4 in result4){
							if(val4<0.05){
							u = u + 1
							Keep4 = (membership(clusterlouvain4)==u)
							g5 = induced_subgraph(g4, Keep4)
							clusterlouvain5 = cluster_louvain(g5)
							IDs_cluster5 <- cbind(V(g5)$name, clusterlouvain5$membership)
							df5<-as.data.frame(IDs_cluster5)
							df5$V2 <- as.numeric(as.character(df5$V2))
							sort5<-df5[order(df5$V2),]
							dir.create("MDDDD")
							write.table(sort5,paste("MDDDD/Community_M",x,"D",p,"D",s,"D",u,"D.txt",sep = ""),sep="\t",col.names =c("ID","Community"),row.names = F,quote = FALSE)
							}
							else{
								u=u+1
							}
						}
					}
					else{
						s= s +1
					}
				}									
			}
			else{
				p= p +1
			}
		}					
	}
	else{
		x= x +1
	}
}							
write(paste("Done!"), stderr())												
