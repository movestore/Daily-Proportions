library('move')
library('foreach')
library('data.table')
library('ggplot2')

rFunction <- function(data,variab,rel,valu,time=FALSE,midnight_adapt=0,gap_adapt=FALSE)
{
  Sys.setenv(tz="UTC")
  
  if (gap_adapt==TRUE) TL <- "timelag2" else TL <- "timelag"
  
  if (is.null(variab) | is.null(rel) | is.null(valu)) logger.info("One of your parameters has not been set. This will lead to an error.")
  
  if (variab %in% names(data))
  {

    if (rel=="%in%") #works for numeric or character values
    {
      valus <- strsplit(as.character(valu),",")[[1]]
      
      if (any(data@data[[variab]] %in% valus))
      {
        data.split <- move::split(data)
        
        perc_sel_list <- foreach(datai = data.split) %do% {
          idi <- namesIndiv(datai)
          logger.info(idi)
          
          datum <- as.Date(timestamps(datai) + midnight_adapt*3600) #shifts midnight by use definition, works for positive and negative values (but must be in unit "hours")
          datumi <- unique(datum)
          perc_pts <- perc_dur <- track_dur <- numeric(length(datumi))
          
          for (i in seq(along=as.character(datumi)))
          {
            ix_d <- which(datum==datumi[i])
            dataid <- datai[ix_d]
            # these are all locations during the day with timelag durations. durations that are accounted for by locations of the previous day are not included here. As high resolution is expected, that should not make a big differences.
            
            perc_pts[i] <- length(which(dataid@data[[variab]] %in% valus))/length(dataid)
            
            dur <- dataid@data[,TL]

            perc_dur[i] <- sum(dur[which(dataid@data[[variab]] %in% valus)],na.rm=TRUE)/sum(dur,na.rm=TRUE) #adapted to proportion of tracking time per day
            track_dur[i] <- sum(dur,na.rm=TRUE) # tracking time per day (sum of timelags TL, same unit)
          }
          perc_seli <- data.frame("trackId"=rep(idi[1],length(datumi)),"date"=datumi,"n.pts"=as.numeric(table(datum)),perc_pts,perc_dur,track_dur)
        }
        perc_sel <- data.frame(rbindlist(perc_sel_list))

      } else logger.info("None of your data fulfill the required property. Go back and reconfigure the App.")
      
    } else
    {
      if (time==TRUE) fullrel <- eval(parse(text=paste0("as.POSIXct(data@data$",variab,") ",rel," as.POSIXct('",valu,"')"))) else fullrel <- eval(parse(text=paste0("data@data$",variab," ",rel," '",valu,"'")))

      if (any(fullrel)) #only do calculations if any locations fulfill the relation
      {
        data.split <- move::split(data)
        
        perc_sel_list <- foreach(datai = data.split) %do% {
          idi <- namesIndiv(datai)
          logger.info(idi)
          
          datum <- as.Date(timestamps(datai) + midnight_adapt*3600) #shifts midnight by user definition
          datumi <- unique(datum)
          perc_pts <- perc_dur <- track_dur <- numeric(length(datumi))
          
          for (i in seq(along=as.character(datumi)))
          {
            ix_d <- which(datum==datumi[i])
            dataid <- datai[ix_d]
            # these are all locations during the day with timelag durations. durations that are accounted for by locations of the previous day are not included here. As high resolution is expected, that should not make a big differences.
            
            perc_pts[i] <- eval(parse(text=paste0("length(which(dataid@data$",variab,rel,valu,"))/length(dataid)")))
            
            dur <- dataid@data[,TL]
            
            perc_dur[i] <- eval(parse(text=paste0("sum(dur[which(dataid@data$",variab,rel,valu,")],na.rm=TRUE)/sum(dur,na.rm=TRUE)"))) #changed so that in relation to daily tracked time
            track_dur[i] <- sum(dur,na.rm=TRUE) # tracking time per day (sum of timelags TL, same unit)
          }
          perc_seli <- data.frame("trackId"=rep(idi[1],length(datumi)),"date"=datumi,"n.pts"=as.numeric(table(datum)),perc_pts,perc_dur,track_dur)
        }
        perc_sel <- data.frame(rbindlist(perc_sel_list))
        
      } else logger.info("None of your data fulfill the required property. Go back and reconfigure the App.")

    }
  } else logger.info("You selected variable is not available in the data set. Go back and reconfigure the App.")

  
  if (exists("perc_sel")) #if calculations have been made
  {
    idvs <- unique(perc_sel$trackId)
    n.ids <- as.numeric(table(perc_sel$trackId))
    perc_pts_avg <- apply(matrix(idvs),1,function(x) mean(perc_sel$perc_pts[perc_sel$trackId==x],na.rm=TRUE))
    perc_dur_avg <- apply(matrix(idvs),1,function(x) mean(perc_sel$perc_dur[perc_sel$trackId==x],na.rm=TRUE))
    track_dur_avg <- apply(matrix(idvs),1,function(x) mean(perc_sel$track_dur[perc_sel$trackId==x],na.rm=TRUE))
    
    perc_pts_mean <- mean(perc_sel$perc_pts,na.rm=TRUE)
    perc_pts_sd <- sd(perc_sel$perc_pts,na.rm=TRUE)
    perc_dur_mean <- mean(perc_sel$perc_dur,na.rm=TRUE)
    perc_dur_sd <- sd(perc_sel$perc_dur,na.rm=TRUE)
    track_dur_mean <- mean(perc_sel$track_dur,na.rm=TRUE)
    track_dur_sd <- sd(perc_sel$track_dur,na.rm=TRUE)
    
    perc_sel_avg <- data.frame("trackId"=idvs,"date"="avg","n.pts"=n.ids,"perc_pts"=perc_pts_avg,"perc_dur"=perc_dur_avg,"track_dur"=track_dur_avg) 
    perc_sel_meansd <- data.frame("trackId"=c("mean","sd"),"date"="avg","n.pts"=rep(dim(perc_sel)[1],2),"perc_pts"=c(perc_pts_mean,perc_pts_sd),"perc_dur"=c(perc_dur_mean,perc_dur_sd),"track_dur"=c(track_dur_mean,track_dur_sd))
    perc_sel_list <- c(perc_sel_list,list(perc_sel_avg),list(perc_sel_meansd))
    perc_sel$date <- as.character(perc_sel$date)
    
    perc_sel <- rbind(perc_sel,perc_sel_avg,perc_sel_meansd)
    write.csv(perc_sel,file=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "Daily_Proportions.csv"),row.names=FALSE)
    
    pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "Daily_Proportions.pdf"),width=12,height=8)
    lapply(perc_sel_list, function(z){
      plot_percpts <- ggplot(z,aes(date,perc_pts))+
        geom_line(color="red")+
        geom_point()+
        facet_grid(~trackId)+
        theme_bw()+
        labs(x="", y="Daily Proportion - Points")
      print(plot_percpts)
    })
    lapply(perc_sel_list, function(z){
      plot_percdur <- ggplot(z,aes(date,perc_dur))+
        geom_line(color="blue")+
        geom_point()+
        facet_grid(~trackId)+
        theme_bw()+
        labs(x="", y="Daily Proportion - Duration")
      print(plot_percdur)
    })
    dev.off()
  }
  
  result <- data #return full data set
  return(result)
}

  
  
  
  
  
  
  
  
  
  
