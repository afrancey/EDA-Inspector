#post-hoc
# independent t-tests
mydata <- read.table("C:/Users/alzfr/Desktop/expt 3 data/movement_posthoc.csv", header=TRUE,sep=",")

stand = mydata$stand
wave = mydata$wave
walk = mydata$walk

# stand, wave
ystand = c(stand, wave)
groupstand = factor(c(rep(1,20),rep(2,20)))
ltest = leveneTest(ystand~groupstand, center = mean)
ltest
#standtest = t.test(stand, wave,var.equal = TRUE)
standtest = t.test(stand, wave,paired = TRUE)


# stand, walk
ywalk = c(stand, walk)
groupwalk = factor(c(rep(1,20),rep(2,20)))
ltestwalk = leveneTest(ywalk~groupwalk, center = mean)
ltestwalk
#walktest = t.test(stand, walk,var.equal = TRUE)
walktest = t.test(stand, walk,paired = TRUE)

# walk, wave
ywave = c(walk, wave)
groupwave = factor(c(rep(1,20),rep(2,20)))
ltestwave = leveneTest(ywave~groupwave, center = mean)
ltestwave
#wavetest = t.test(walk, wave,var.equal = TRUE)
wavetest = t.test(walk, wave,paired = TRUE)

standtest
walktest
wavetest
mean(stand)
mean(wave)
mean(walk)
sd(stand)
sd(wave)
sd(walk)