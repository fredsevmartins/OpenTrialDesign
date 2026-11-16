for (i in 1:30) {
  local({
    id <- sprintf("TD-%03d", i)
    test_that(paste(id, "executes independently with provenance"), {
      if (i %in% c(9,10,13,14,16:19)) skip_if_not_installed("gsDesign")
      if (i %in% c(11,12,15,20:24)) skip_if_not_installed("rpact")
      if (i %in% 25:27) skip_if_not_installed("simsurv")
      x <- run_example(id, nsim = 20, seed = 2026)
      expect_s3_class(x, "otd_result")
      expect_true(nzchar(x$provenance$method))
      expect_gt(length(x$provenance$versions), 0)
    })
  })
}
