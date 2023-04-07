library(data.table)
library(plyr)
library(ggplot2)
library(sandwich)
library(stringr)

confint_robust <- function(object, parm, clust_var,level = 0.95, 
                           HC_type="HC0",...){
  cf <- coef(object); pnames <- names(cf)
  if(missing(parm))
    parm <- pnames
  else if (is.numeric(parm))
    parm <- pnames[parm]
  
  a <- (1-level)/2; a <- c(a, 1-a)
  pct <- paste(format(100 * a, 
                      trim = TRUE, 
                      scientific = FALSE, 
                      digits = 3), 
               "%")
  fac <- qnorm(a)
  ci <- array(NA, 
              dim = c(length(parm), 2L), 
              dimnames = list(parm, pct))
  ses <- sqrt(diag(vcovCL(object, cluster=clust_var, type=HC_type, ...)))[parm]
  ci[] <- cf[parm] + ses %o% fac
  ci
}


gen_choice_plot_data <- function(fil){
  fname <- str_split_fixed(sub(".csv","",basename(fil)),"_",n=3)
  print(fil)
  print(fname)
  d <- fread(fil,stringsAsFactors = F)
  d$gender <- fname[1,3]
  d$model <- fname[1,2]
  d[, est := as.numeric(V2)]
  d[, lower := as.numeric(V4)]
  d[, upper := as.numeric(V5)]
  d[, gender := ifelse(gender == "WOMEN", "Female","Male")]
  return(d[4,.(model,est,lower,upper,gender)])
}

run_mod <- function(dat){
  mod <- glm(left_field~fab+stem_c, dat,family="binomial")
  cis <- confint_robust(mod,clust_var=dat$oid)[2,]
  return(data.table(est=coef(mod)[2],lower=cis[1],upper=cis[2]))
}

EXIT_DATA_DIR = "../../ORCID_trajectories/robustness_check_3/data/exit_data"
ENTRY_DATA_DIR = "../../ORCID_trajectories/robustness_check_3/data/entry_data"

mod_summary <- data.table()
for( fil in Sys.glob(file.path(EXIT_DATA_DIR,"stayleave*"))){
  base_name <- sub("stayleave_","",sub(EXIT_DATA_DIR, "",fil))
  base_name <- substr(base_name,2,nchar(base_name)-4)
  
  stayleave_data <- fread(fil)
  stayleave_data[, stem_c := (stem == "STEM") - mean(stem=="STEM")]
  fem <- run_mod(stayleave_data[is_fem_factor=="Female"])
  fem$gender<- "Female"
  male <- run_mod(stayleave_data[is_fem_factor=="Male"])
  male$gender<- "Male"
  mm <- rbind(fem, male)
  mm$model <- base_name
  mod_summary <- rbind(mod_summary,mm)
  print(base_name)
  ck_sig <- glm(left_field~(fab+stem_c)*is_fem_factor, stayleave_data,family="binomial")
}



choice_model_data <- rbindlist(lapply(Sys.glob(file.path(ENTRY_DATA_DIR,"*.csv")),  
                                      gen_choice_plot_data))

mod_summary$v <- "Exiting a Field"
choice_model_data$v <- "Entering a Field"
fin_plot <- rbind(mod_summary, choice_model_data)
fin_plot[, Model1 := mapvalues(model,
                       c("full",
                         "europe_from","Europe",
                         "north_america_from","NorthAm",
                         "lac_from","LatinAm",
                         "asia_from","Asia",
                         "from_phd","PhD",
                         "from_bach","bachelors",
                         "pre2000",
                         "post2000"),
                       c("Full Dataset",
                         rep("From European Institutions",2),
                         rep("From Northern American\nInstitutions (U.S. and Canada)",2),
                         rep("From Latin American and\nCaribbean Institutions",2),
                         rep("From Asian Institutions",2),
                         rep("From Bachelors/Masters\n/Postgraduate\nto Ph.D.",2),
                         rep("From Ph.D.\nto Postdoc/Professor",2),
                         "Occurring in\n2000 or Before",
                         "Occurring in\n2001 or After"))
]


fin_plot[, check_type := mapvalues(model,
                                      c("full",
                                        "europe_from","Europe",
                                        "north_america_from","NorthAm",
                                        "lac_from","LatinAm",
                                        "asia_from","Asia",
                                        "from_phd","PhD",
                                        "from_bach","bachelors",
                                        "pre2000",
                                        "post2000"),
                                  c("Full",
                                    rep("Location",8),
                                    rep("Career Stage",4),
                                    rep("Time",2)))
]
fin_plot[, check_type := factor(check_type,
                                   levels=c("Full","Location",
                                            "Career Stage","Time"))]

p <- ggplot(fin_plot, aes(Model1,
                                 exp(est),
                                 ymin=exp(lower),
                                 ymax=exp(upper),
                        color=gender)) + 
  coord_flip() + 
  xlab("Data Subset")+ ylab("Odds Ratio") + 
  geom_hline(yintercept = 1, color='darkgrey',size=1.2) + 
  theme_minimal(15)  + scale_y_log10(limits=c(0.1,5), 
                                     breaks=c(0.1,1,5),
                                     labels=c(".1","1","5")) + 
  facet_grid(check_type~v,scales="free_y",space = "free") + 
    geom_linerange(position=position_dodge(width=.4),size=1.3) +
    geom_point(position=position_dodge(width=.4),size=2.2) + 
    scale_color_manual(values = c("Male"="dodgerblue","Female"="red"))+
    theme(legend.position="none",
          panel.spacing = unit(2, "lines"),
          panel.background = element_rect(fill = NA, color = "black"))

ggsave("robustness_check_3.pdf", p, h=9, w=8)

