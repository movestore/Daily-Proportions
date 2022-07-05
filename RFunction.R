library('move')
library('foreach')
library('data.table')
library('ggplot2')

rFunction <- function(data,variab,rel,valu,time=FALSE)
{
  Sys.setenv(tz="UTC")
  
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
          
          datum <- as.Date(timestamps(datai))
          datumi <- unique(datum)
          perc_pts <- perc_dur <- numeric(length(datumi))
          
          for (i in seq(along=as.character(datumi)))
          {
            ix_d <- which(datum==datumi[i])
            dataid <- datai[ix_d]
            if (length(datai)>max(ix_d)) dataidp <- datai[unique(c(ix_d,ix_d+1))] else dataidp <- dataid
            
            perc_pts[i] <- length(which(dataid@data[[variab]] %in% valus))/length(dataid)
            
            dur <- timeLag(dataidp,units="hours") 
            if (length(datai)<=max(ix_d)) dur <- c(dur,NA)
            perc_dur[i] <- sum(dur[which(dataid@data[[variab]] %in% valus)],na.rm=TRUE)/24 #not correct if flight detection in data collection
          }
          perc_seli <- data.frame("trackId"=rep(idi[1],length(datumi)),"date"=datumi,"n.pts"=as.numeric(table(datum)),perc_pts,perc_dur)
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
          
          datum <- as.Date(timestamps(datai))
          datumi <- unique(datum)
          perc_pts <- perc_dur <- numeric(length(datumi))
          
          for (i in seq(along=as.character(datumi)))
          {
            ix_d <- which(datum==datumi[i])
            dataid <- datai[ix_d]
            if (length(datai)>max(ix_d)) dataidp <- datai[unique(c(ix_d,ix_d+1))] else dataidp <- dataid
            
            perc_pts[i] <- eval(parse(text=paste0("length(which(dataid@data$",variab,rel,valu,"))/length(dataid)")))
            
            dur <- timeLag(dataidp,units="hours") 
            if (length(datai)<=max(ix_d)) dur <- c(dur,NA)
            perc_dur[i] <- eval(parse(text=paste0("sum(dur[which(dataid@data$",variab,rel,valu,")],na.rm=TRUE)/24"))) #not correct if flight detection in data collection
          }
          perc_seli <- data.frame("trackId"=rep(idi[1],length(datumi)),"date"=datumi,"n.pts"=as.numeric(table(datum)),perc_pts,perc_dur)
        }
        perc_sel <- data.frame(rbindlist(perc_sel_list))
        
      } else logger.info("None of your data fulfill the required property. Go back and reconfigure the App.")

    }
  } else logger.info("You selected variable is not available in the data set. Go back and reconfigure the App.")

  
  if (exists("perc_sel")) #if calculations have been made
  {
    dates <- unique(perc_sel$date)
    n.ids <- as.numeric(table(perc_sel$date))
    perc_pts_avg <- apply(matrix(dates),1,function(x) mean(perc_sel$perc_pts[perc_sel$date==x]))
    perc_dur_avg <- apply(matrix(dates),1,function(x) mean(perc_sel$perc_dur[perc_sel$date==x]))
    
    perc_sel_avg <- data.frame("trackId"="avg","date"=dates,"n.pts"=n.ids,"perc_pts"=perc_pts_avg,"perc_dur"=perc_dur_avg) 
    perc_sel_list <- c(perc_sel_list,list(perc_sel_avg))
    perc_sel <- rbind(perc_sel,perc_sel_avg)
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

  
  
  
  
  
  
  
  
  
  
