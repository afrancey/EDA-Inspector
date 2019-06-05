# MOVEMENT
library(car)
mydata <- read.table("C:/Users/alzfr/Desktop/expt 3 data/movement_data.csv", header=TRUE,sep=",")
pnum = mydata$pnum
stim = mydata$stim
movement = mydata$movement
area = mydata$area
extrema = mydata$extrema

areamodel = aov(area ~ stim*movement)
areaano = Anova(areamodel, type = "III")
areaano

extremamodel = aov(extrema ~ stim*movement)
extremaano = Anova(extremamodel, type = "III")
#extremaano
#extremaano[4,1]

area_stat = ezANOVA(
    data = mydata
    , dv = .(area)
    , wid = .(pnum)
    , within = .(stim,movement)
    , type = 2
)
area_stat

# matches extremeano if "between" instead of "within"
extrema_stat = ezANOVA(
    data = mydata
    , dv = .(extrema)
    , wid = .(pnum)
    , within = .(stim,movement)
    , type = 3
)
extrema_stat