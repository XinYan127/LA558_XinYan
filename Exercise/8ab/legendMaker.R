# Leaflet mapping: Make a legend graphic
# 
# March 7, 2023
# Chris Seeger

install.packages("tidyverse")
library(tidyverse)


coul <- brewer.pal(8, "Reds") 
p <- plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("topleft", legend =c('0-2', '2-4', '4-6', '6-8', '8-10', '10-12', '12-14', '14+'), 
       pch=15, pt.cex=3, cex=1.5, bty='n', col = coul)
mtext("  Student Count", at=0.1, cex=2)
