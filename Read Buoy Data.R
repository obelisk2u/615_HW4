
library(dplyr)
library(lubridate)
library(tibble)


#=======================================================
get_url <- function(year) {
  paste0("https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h", year, ".txt.gz&dir=data/historical/stdmet/")
}

#=======================================================
#INITIATE DATAFRAME WITH 1985 DATA
year1<-"1985"
buoy<-read.table(get_url(year1), header = TRUE, sep = "", na.strings = "MM", fill = TRUE)

header=scan(get_url(year1),what= 'character',nlines=1)
colnames(buoy)<-header
buoy = buoy %>%
  add_column(mm = NA, .after = "hh") %>%
  add_column(TIDE = NA, .after = "VIS")

#========================================================
#HANDLE YEARS 1986-2006
years <- 1986:2006
for (i in years) {
  url <- get_url(i)
  temp_data <- read.table(get_url(i), header = TRUE, sep = "",fill = TRUE)
  temp_data = temp_data %>%
    add_column(mm = NA, .after = "hh") %>%
    add_column(TIDE = NA, .after = "VIS")
  buoy <- bind_rows(buoy, temp_data)
}
buoy$YY<-na.omit(c(buoy$YY, buoy$YYYY))
buoy <- buoy %>%
  select(-YYYY, -TIDE.1, -mm.1)
colnames(buoy)[colnames(buoy) == "YY"] <- "YYYY"
#=========================================================
#HANDLE YEARS 2007-2023
years<-2007:2023
for (i in years) {
  url <- get_url(i)
  temp_data <- (read.table(get_url(i), header = FALSE, sep = "",fill = TRUE, skip=1))
  header=scan(get_url(i),what= 'character',nlines=1)
  colnames(temp_data)<-header
  buoy <- bind_rows(buoy, temp_data)
}

buoy$YYYY<-na.omit(c(buoy$YYYY, buoy$`#YY`))
buoy$BAR<-na.omit(c(buoy$BAR, buoy$PRES))
buoy <- buoy %>%
  select(-`#YY`, -PRES)

buoy$WD<-na.omit(c(buoy$WD, buoy$WDIR))
buoy <- buoy %>%
  select(-WDIR)


buoy$YYYY <- ymd_h(paste(buoy$YYYY, buoy$MM, buoy$DD, buoy$hh, sep = "-"))






