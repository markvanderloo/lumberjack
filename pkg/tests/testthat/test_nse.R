

context("NSE helper functions")
test_that("symbol replacement works",{
  
  expect_identical(
    replace(expression(x + y)[[1]],quote(x),quote(z))
    , expression(z + y)[[1]])
  
  expect_identical(
    replace(expression(x + y*y)[[1]],quote(y),quote(z))
    , expression(x + z*z)[[1]])

  expect_identical(
    replace(expression(x + f(y*y))[[1]],quote(y),quote(z))
    , expression(x + f(z*z))[[1]])
})

context("The pipe")


test_that("The pipe function",{
  expect_identical(1:3 %>>% mean(), mean(1:3))
  expect_identical(1:3 %>>% mean(na.rm=TRUE), mean(1:3, na.rm=TRUE))
  expect_identical(1:3 %>>% mean(.), 2)
  expect_identical(1:3 %>>% mean(.,na.rm=TRUE), 2)
  g <- 1:3
  expect_identical(g %>>% mean(), mean(g))
  
  expect_identical( 3 %>>% {2 * .}, 6)
  expect_identical( 3 %>>% (2 * .), 6)  
  expect_identical(
    mean(c(1,NA,3),na.rm=TRUE)
    , TRUE %>>% mean(c(1,NA,3),na.rm=.)
    
  )
  
  expect_equal(
    coefficients(lm(height ~ weight,data=women)) 
    , women %>>% lm(height ~ weight, data=.) %>>% coefficients()
  )
})






