# pass arguments to a function
1:3 %>>% mean()

# pass arguments using "."
TRUE %>>% mean(c(1,NA,3), na.rm = .)

# pass arguments to an expression, using "."
1:3 %>>% { 3 * .}

# in a more complicated expression, return "." explicitly
women %>>% { .$height <- 2*.$height; . }



