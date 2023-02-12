SSMethod.TA1.8 <-
function(fit,type,fleet,part=0:2,pick.gender=0:3,plotit=T)
    ## Uses method TA1.8 (described in Appendix A of Francis 2011) to do
    ## stage-2 weighting of composition data from a Stock Synthesis model.
    ##
    ## Outputs a mutiplier, w, so that N2y = w x N1y, where N1y and
    ## N2y are the stage-1 and stage-2 multinomial sample sizes for
    ## the data set in year y.
    ##
    ## Reference:
    ## Francis, R.I.C.C. (2011). Data weighting in statistical
    ## fisheries stock assessment models. Canadian Journal of
    ## Fisheries and Aquatic Sciences 68: 1124-1138.
    ##
    ## fit - Stock Synthesis output as read by r4SS function SS_output
    ## type - either 'len' (for length composition data), 'age'
    ##        (for age composition data), or 'con' (for conditional age
    ##       at length data)
    ## fleet - vector of one or more fleet numbers whose data are to
    ##       be analysed simultaneously (the output N multiplier applies
    ##       to all fleets combined)
    ## part - vector of one or more partition values; analysis is restricted
    ##        to composition data with one of these partition values.
    ##        Default is to include all partition values (0, 1, 2).
    ## pick.gender - vector of one or more values for Pick_gender; analysis is
    ##        restricted to composition data with one of these
    ##        Pick_gender values.  Ignored if type=='con'
    ## plotit - if T, make an illustrative plot like one
    ##       panel of Fig. 4 in the above paper
    ##
{
    is.in <- function (x, y)!is.na(match(x, y))
    if(!is.in(type,c('age','len','con')))stop('Illegal value for type')
    else if(sum(!is.in(pick.gender,c(0:3)))>0)
        stop('Unrecognised value for pick.gender')
    gender.flag <- type!='con' & length(pick.gender)>1
    dbase <- fit[[paste(type,'dbase',sep='')]]
    sel <- is.in(dbase$Fleet,fleet) & is.in(dbase$Part,part)
    if(type!='con')sel <- sel & is.in(dbase$'Pick_gender',pick.gender)
    if(sum(sel)==0)stop('No data to analyse')
    dbase <- dbase[sel,]
    indx <- paste(dbase$Fleet,dbase$Yr,if(type=='con')dbase$'Lbin_lo' else
                  '')
    if(gender.flag)indx <- paste(indx,dbase$'Pick_gender')
    uindx <- unique(indx)
    if(length(uindx)==1)stop('Only one point to plot')
    pldat <- matrix(0,length(uindx),7,dimnames=list(uindx,
                    c('Obsmn','Obslo','Obshi','Expmn','Std.res','Fleet','Yr')))
    if(type=='con')pldat <- cbind(pldat,Lbin=0)
    if(gender.flag)pldat <- cbind(pldat,pick.gender=0)
    for(i in 1:length(uindx)){
        subdbase <- dbase[indx==uindx[i],]
        xvar <- subdbase$Bin
        pldat[i,'Obsmn'] <- sum(subdbase$Obs*xvar)/sum(subdbase$Obs)
        pldat[i,'Expmn'] <- sum(subdbase$Exp*xvar)/sum(subdbase$Exp)
        semn <- sqrt((sum(subdbase$Exp*xvar^2)/sum(subdbase$Exp)-
                      pldat[i,'Expmn']^2)/
            mean(subdbase$N))
        pldat[i,'Obslo'] <- pldat[i,'Obsmn']-2*semn
        pldat[i,'Obshi'] <- pldat[i,'Obsmn']+2*semn
        pldat[i,'Std.res'] <- (pldat[i,'Obsmn']-pldat[i,'Expmn'])/semn
        pldat[i,'Fleet'] <- mean(subdbase$Fleet)
        pldat[i,'Yr'] <- mean(subdbase$Yr)
        if(type=='con')pldat[i,'Lbin'] <- mean(subdbase$'Lbin_lo')
        if(gender.flag)
            pldat[i,'pick.gender'] <- mean(subdbase$'Pick_gender')
        }
    Nfleet <- length(unique(pldat[,'Fleet']))
    if(plotit){
        plindx <- if(type=='con')
            paste(pldat[,'Fleet'],pldat[,'Yr']) else pldat[,'Fleet']
        if(gender.flag)plindx <- paste(plindx,pldat[,'Fleet'],
                                                 pldat[,'pick.gender'])
        uplindx <- unique(plindx)
        Npanel <- length(uplindx)
        Nr <- ceiling(sqrt(Npanel))
        Nc <- ceiling(Npanel/Nr)
        par(mfrow=c(Nr,Nc),mar=c(2,2,1,1)+0.1,mgp=c(0,0.5,0),oma=c(1.2,1.2,0,0),
            las=1)
        par(cex=1)
        for(i in 1:Npanel){
            subpldat <- pldat[plindx==uplindx[i],]
            x <- subpldat[,ifelse(type=='con','Lbin','Yr')]
            plot(x,subpldat[,'Obsmn'],pch='-',
                 ylim=range(subpldat[,c('Obslo','Obshi')]),xlab='',ylab='')
            points(x,subpldat[,'Obsmn'],pch='-')
            segments(x,subpldat[,'Obslo'],x,subpldat[,'Obshi'])
            ord <- order(x)
            lines(x[ord],subpldat[ord,'Expmn'])
            fl <- fit$FleetNames[subpldat[1,'Fleet']]
            yr <- paste(subpldat[1,'Yr'])
            lab <- if(type=='con')ifelse(Nfleet>1,paste(yr,fl),yr) else fl
            if(gender.flag)lab <-
                paste(lab,ifelse(subpldat[1,'pick.gender']==0,'comb','sex'))
            mtext(lab,3,at=mean(x))
        }
        mtext(paste('Mean',ifelse(type=='len','length','age')),2,out=T)
        mtext(ifelse(type=='con','Length','Year'),1,out=T)
    }
    Nmult <- 1/var(pldat[,'Std.res'],na.rm=T)
    tmp <- matrix(sample(pldat[,'Std.res'],1000*nrow(pldat),repl=T),nrow(pldat))
    confint <- quantile(apply(tmp,2,function(x)1/var(x,na.rm=T)),
                        c(0.025,0.975))
    c(w=Nmult,lo=confint[1],hi=confint[2])
}
