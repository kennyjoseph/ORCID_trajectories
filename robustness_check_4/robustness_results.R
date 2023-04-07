library(data.table)
theme_set(theme_light(20))

run_sim <- function(trans_file){
  trans <- fread(trans_file)
  trans <- melt(trans, id =c("from_matched_field","to_matched_field"))
  full_trans <- rbindlist(apply(trans, 1,function(m){data.table(from_matched_field=rep(m[1],m[4]),
                                                   to_matched_field=rep(m[2],m[4]), 
                                                   is_fem=rep(ifelse(m[3] == "n_female",1,0),m[4]))}))
  
  cov <- fread(sub("transitions","covariates",trans_file))
  print(ncol(cov))
  full_trans <- merge(full_trans, cov, by.x="from_matched_field", by.y="field")
  setnames(full_trans, "covariate","from_fab")
  full_trans <- merge(full_trans, cov, by.x="to_matched_field", by.y="field")
  setnames(full_trans, "covariate","to_fab")
  full_trans[, fab := to_fab - from_fab]
  res <-glm(is_fem ~ 1+fab + from_matched_field , data=full_trans,family="binomial")
  return(as.vector(coef(res)[2]))
}

all_trans_files <- Sys.glob("synthetic/*transitions.tsv")

results <- sapply(all_trans_files,run_sim)

res <- data.table(filename=names(results),beta=as.vector(results))
res[, filename := sub("synthetic/","", filename)]
res[, filename := sub("_transitions.tsv","", filename)]
write.csv(res,"synthetic/simchallenge_results_3.csv",row.names=F)
