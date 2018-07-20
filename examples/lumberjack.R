# pass arguments to a function
1:3 %L>% mean()

# pass arguments using "."
TRUE %L>% mean(c(1,NA,3), na.rm = .)

# pass arguments to an expression, using "."
1:3 %L>% { 3 * .}

# in a more complicated expression, return "." explicitly
women %L>% { .$height <- 2*.$height; . }



