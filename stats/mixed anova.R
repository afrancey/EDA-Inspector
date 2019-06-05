# import libraries
library(tidyr) # for gather() function
library(lme4) # for lmer() function
library(car)
library(nlme) # lme()
library(ez)
library(ggplot2)

#options(contrasts=c("contr.sum","contr.poly"))

# read data and fill variables
mydata <- read.table("C:/Users/alzfr/Desktop/expt 3 data/final data/means_all.csv", header=TRUE,sep=";")
group = mydata$group
a = mydata$T1
b = mydata$T2
c = mydata$T3
d = mydata$T4
e = mydata$T5
f = mydata$T6
g = mydata$T7
h = mydata$T8
i = mydata$T9
j = mydata$T10

# turn it into a data frame
df = data.frame(id=factor(mydata$Subject), group, a,b,c,d,e,f,g,h,i,j)
#head(df)

# create long format data frame for use in 
dflong = gather(df, key=interval, value=score, a:j)
dflong

# Mixed-design ANOVA
# between variable: group
# within variable: interval
# gives weird analysis of deviance table
#lmeModel = lmer(score ~ group*interval + (1|id), data=dflong)
#Anova(lmeModel)

# agrees with ezANOVA
anovaModelRM = aov(score ~ group*interval + Error(id), data = dflong)
summary(anovaModelRM)

# check for balance
#replications(score ~ group*interval + Error(id), data = dflong)

#!is.list(replications(score ~ group*interval + Error(id), data = dflong))

#lmeModel2 = lme(score ~ interval, data=dflong, random = ~group|id)
#Anova(lmeModel2)

mixed = ezANOVA(
    data = dflong
    , dv = .(score)
    , wid = .(id)
    , between = .(group)
    , within = .(interval)
    , type = 3
)
mixed

interaction.plot(dflong$interval, dflong$group, dflong$score, 
ylab = "mean standardized SCL", xlab = "time interval", trace.label = "group",
xtick = TRUE)

#motion=c("stand","wave","walk")
#df<-data.frame(motion=c("stand","wave","walk"),extrema=c(6.185,9.736,6.957))
#g<-ggplot(df,aes(motion,extrema), ylab = "mean # of extrema")+geom_bar(stat="identity", fill="#F88379", colour="black")
#g+geom_path(x=c(1,1,1.9),y=c(10,10.5,10.5))+
#  geom_path(x=c(1.9,1.9,1.9),y=c(10.5,10,10))+
#  geom_path(x=c(2.1,2.1,3),y=c(10,10.5,10.5))+
#  geom_path(x=c(3,3,3),y=c(10.5,10,10.5))+
#  annotate("text",x=1.5,y=11,label="P < .001")+
#  annotate("text",x=2.5,y=11,label="P = .002") + scale_x_discrete(limits = motion)
