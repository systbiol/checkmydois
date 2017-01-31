#install.packages("rorcid")
#install.packages("dplyr")
#install.packages("httr")
#setwd("/home/ross/Documents/test")
library(rorcid)
library(dplyr)
library(httr)

#Put your ORCID ID below
your.ORCID.ID <- "0000-0002-3520-2046"

#This gets your list of works with identifiers from ORCID
#Thanks to Scott Chamberlain for this step https://github.com/ropensci/rorcid/issues/31
out <- works(orcid_id(your.ORCID.ID))
ids <- dplyr::bind_rows(Filter(
  Negate(is.null),
  out$data$`work-external-identifiers.work-external-identifier`
))
doisonly <- ids[ids$`work-external-identifier-type` == "DOI", ]
doisonly$`work-external-identifier-id.value` <- gsub("^","http://doi.org/",doisonly$`work-external-identifier-id.value`)

#Write out a list of DOIs for all your ORCID registered works
write.table(doisonly$`work-external-identifier-id.value`,file="mydois.txt",row.names=F,col.names=F,quote=F)

#loop through your DOIs to check the HTTP status message with a simple for loop
#a better R coder probably wouldn't use a for loop here...
rm(vec)
vec <- vector("list",length(doisonly$`work-external-identifier-id.value`))
for (doi in (seq(1,length(doisonly$`work-external-identifier-id.value`)))){
  vec[doi] <- http_status(GET(doisonly$`work-external-identifier-id.value`[doi]))$message
}
#save the HTTP status messages for all your works with DOIs
table <- data.frame(matrix(unlist(vec)),doisonly$`work-external-identifier-id.value`)
table
names(table)[1] <- "HTTP.Status"
names(table)[2] <- "DOI"
datestamp <- paste(format(Sys.time(), "%Y-%m-%d-%I-%p"), "csv", sep = ".")
write.csv(table,file=datestamp,row.names = F)