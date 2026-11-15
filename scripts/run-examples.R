library(OpenTrialDesign)
nsim <- 1000L
seed <- 2026L
results <- vector("list", 30)
for (i in seq_len(30)) {
  id <- sprintf("TD-%03d", i)
  cat("\n", id, "seed", seed, "nsim", nsim, "\n")
  started <- proc.time()[[3]]
  x <- tryCatch(run_example(id, nsim = nsim, seed = seed), error = identity)
  ok <- !inherits(x, "error")
  if (ok) print(x) else cat(conditionMessage(x), "\n")
  results[[i]] <- data.frame(id = id, executed = TRUE, success = ok,
    seed = seed, nsim = nsim, elapsed_seconds = proc.time()[[3]]-started,
    method = if (ok) x$provenance$method else conditionMessage(x))
  if (ok) saveRDS(x, file.path("validation", paste0(id, ".rds")))
  flush.console()
}
utils::write.csv(do.call(rbind, results), "validation/example-execution.csv", row.names = FALSE)
print(sessionInfo())
if (!all(vapply(results, function(x) x$success, logical(1)))) stop("Example execution failed")
