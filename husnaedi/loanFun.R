calcJafnarGreidslur <- function(P_init, r, n, innborgun){
  P <- P_init
  G <- P_init*(r*(1+r)^n)/((1+r)^n -1)
  resData <- list()
  for(i in 1:n){
    VG <- P*r
    P <- P-(G-VG) - innborgun
    nLeft <- n-i
    if(P<0){
      innborgun <- innborgun + P
      P <- 0
      resData[[i]] <- data.frame(HofudstollEftir = P, greidsla = G+innborgun, 
                                 vaxtaGreidsla = VG, afborgun = G-VG, innborgun = innborgun, t = i)
      return(resData %>% bind_rows())
    }
    resData[[i]] <- data.frame(HofudstollEftir = P, greidsla = G + innborgun, 
                               vaxtaGreidsla = VG, afborgun = G-VG, innborgun = innborgun, t = i)
    G <- P*(r*(1+r)^nLeft)/((1+r)^nLeft -1)
  }
  return(resData %>% bind_rows())
}
calcJafnarAfborganir <- function(P_init, r, n, innborgun){
  P <- P_init
  resData <- list()
  for(i in 1:n){
    VG <- P*r
    A <- P/(n-i+1)
    P <- P-A-innborgun
    resData[[i]] <- data.frame(HofudstollEftir = P, greidsla = VG + A + innborgun, 
                               vaxtaGreidsla = VG, afborgun = A, innborgun = innborgun, t = i)
  }
  return(resData %>% bind_rows())
}

plotHofudStoll <- function(data){
  p <- ggplotly(
    data %>% 
      mutate(text = paste("Ár:", round(t/12,2)), Höfuðstóll = paste(round(HofudstollEftir/1000000,2))) %>% 
      ggplot() + 
      geom_line(mapping = aes(x = t/12, y = HofudstollEftir/1000000, text = text, Höfuðstóll = Höfuðstóll, group = 1)) + 
      scale_y_continuous(name = "Höfuðstóll [m.ISK]") + 
      scale_x_continuous(name = "Tími [Ár]", breaks = seq(0,max(data$t/12),1)) + 
      theme_bw(),
    tooltip = c("text","Höfuðstóll")
  )
  return(p)
}
plotGreidslur <- function(data){
  p <- ggplotly(
    data %>% select(t, Vextir = vaxtaGreidsla, Afborgun = afborgun) %>% 
      gather(key = type, value = fjarhaed, Vextir, Afborgun) %>% 
      mutate(Ár = paste(round(t/12,2)), Höfuðstóll = paste0(type,": " ,round(fjarhaed/1000,2))) %>% 
      ggplot(aes(t/12,fjarhaed/1000, col = type, text = Höfuðstóll, Ár = Ár, group = type)) + 
      geom_line() + 
      scale_y_continuous(limits = c(0,NA), breaks = seq(0,1000,50),name = "Greiðsla [þ.ISK]") + 
      scale_x_continuous(name = "Tími [Ár]", breaks = seq(0,max(data$t/12),1)) + 
      scale_color_discrete(name = "") + 
      theme_bw(),
    tooltip = c("text","Ár")
  )
  return(p)
}
