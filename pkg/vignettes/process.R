
# read data
data(women) 

start_log(women, logger = simple$new(verbose=TRUE))

# transform inches to m
women$height <- women$height * 0.0254
# transform pounds to kg
women$weight <- women$weight * 0.453592
# add body-mass index column
women$bmi <- women$weight/(women$height^2)
# write data
outfile <- tempfile(fileext=".csv")
write.csv(women, file=outfile, row.names=FALSE)

dump_log(file="women_simple.csv")

