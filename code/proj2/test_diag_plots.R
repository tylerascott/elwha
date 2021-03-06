require(statnet)
require(ggplot2)
require(ggmcmc)
require(grid)
library(ergm)
library(reshape2)
library(plyr)
library(dplyr)


setwd('/homes/tscott1/')
rm(list=ls())
load('mosix_basemod.RData')
setwd('/homes/tscott1/win/user/elwha/PSJ_Submission/Version3/min_versions/')
#setwd('//Users/TScott/Google Drive/elwha/PSJ_Submission/Version3')
#load('only_model_results.RData')

#load('result_base_nll.RData')
#load('result_base2_nll.RData')
temp<-ggs(mod_base.01$sample)

temp3<-(merge(temp2,mod_base$target.stats))



levels(temp2$Parameter)<-c("Sum","Mutual","Transitive Weights",
                           "Number Resp.","Number Groups", 'Mean Years', 'Org. Type')



# 
# testdu<-simulate.ergm(mod_base,nsim=1000,seed=24,response="TVAL",
#                       reference=~DiscUnif(0,3),
#                       statsonly=TRUE,
#                       monitor=~nonzero+transitiveties,control=
#                         control.simulate.ergm(
#                                               MCMC.interval=1000,MCMC.burnin=10000,parallel=4,parallel.version.check=TRUE))

ggdu = ggplot(data=temp,aes(colour=as.character(Chain),x=Iteration,y=value))+
  geom_line(aes(),size=.10,alpha=.75)+
  facet_wrap(~Parameter,scales="free")+
  scale_colour_brewer(type="qual",palette='Set1',guide=guide_legend(title="MCMC Chain", label.position="bottom",nrow=2,override.aes=list(size=1.5,alpha=1)))+
  scale_x_continuous("Iteration",expand=c(0,0),breaks = c(10000,20000),labels=c('10000','20000'))+
  scale_y_continuous("Parameter Value")+
  theme_bw()+
  theme(axis.text=element_text(size=10),
        axis.title = element_text(size=12),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position=c(.85,.15),legend.text.align=.5,
        axis.text=element_text(size=6),legend.title.align=.5, legend.key.size=unit(.5,'cm'),
        legend.background = element_rect(colour = "black"))
plot(ggdu)
ggsave(ggdu,filename="traceplotdu.png")
rm(ggdu)


ggdudens = ggplot(data=temp,aes(colour=as.character(Chain),x=value))+
  geom_density(aes(),size=.5,trim=TRUE,adjust=2)+ 
  facet_wrap(~Parameter,scales="free")+
  scale_colour_brewer(type="qual",palette='Set1',
                      guide=guide_legend(title="MCMC Chain", label.position="bottom",nrow=2,
                                         override.aes=list(size=.5,alpha=1)))+
  scale_x_continuous("Parameter Value",expand=c(0,0))+
  scale_y_continuous("Density") +
  theme_bw()+
  theme(axis.text=element_text(size=10),
        axis.title = element_text(size=12),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position=c(.85,.15),legend.text.align=.5, 
        legend.title.align=.5, legend.key.size=unit(.5,'cm'),
        axis.text=element_text(size=6),
        legend.background = element_rect(colour = "black"))
plot(ggdudens)
ggsave(ggdudens,filename="densityplotdu.png")
rm(ggdudens)
# 
# 

sim2 = simulate.ergm(mod_base.01,nsim = 50000,statsonly=TRUE,#sequential=FALSE,
                     control=control.simulate.ergm(MCMC.burnin=15000,
                                                   MCMC.interval=1500,
                                                   MCMC.prop.args=list(p0=0.5), 
                                                                                       parallel=8,
                                                                                       parallel.type='PSOCK'
                                                                                       ))
sim.dat2 = melt(sim2,id.vars=nrow(sim2))



    
    net.obs <- data.frame(summary(mod_base.01$formula,
                              response="TVAL",reference=~DiscUnif(0,3)))

names(net.obs)[1] = 'Observed.Value'
net.obs[,2] = rownames(net.obs)
names(net.obs)[2] = 'Var2'

sim.dat= join(sim.dat2,net.obs)

levels(sim.dat$Var2) = c('Sum','Mutual','Transitive Weights','Number Resp.','Number Groups','Mean Years','Org. Type')

sim.plot = ggplot(sim.dat) + geom_density(aes(x=value),adjust=1.5,colour='black',trim=TRUE) + facet_wrap(~Var2,scales='free') + 
  geom_vline(aes(xintercept=Observed.Value,linetype = "expected"),show_guide = TRUE,lwd=1.25)+
  theme_bw()  + ylab('Density') + xlab('Simulated Value') + 
  theme(panel.background=element_blank(),
        panel.grid = element_blank(),
        axis.title = element_text(size=12),
        strip.text = element_text(size=12),
        axis.text = element_text(size=10),
        legend.position=c(.7,.2),
        legend.key.height = unit(2,'cm'),
       # legend.title = element_blank(),
        legend.text = element_text(size=12))+
  scale_linetype_manual(name='',values = 2,labels='Observed value')
plot(sim.plot)
summary(mod_base)
ggsave(sim.plot,filename="simulationplot.png",dpi=500)
rm(sim.plot)



