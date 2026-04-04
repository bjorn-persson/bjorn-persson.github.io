# Verification: compare R mf.indices() against JS-equivalent formulas
# on the same generated MVN data.

library(MASS)

source("C:/Users/perss/Documents/Projekt/personal_website/bjorn-persson.github.io/mf.indices_v1.0.R")

set.seed(42)

# --- Parameters matching JS "Realistic Big 5" preset ---
P <- 5
N <- 500  # per group
d_true <- c(0, -0.50, -0.15, -0.40, 0.10)
avg_r <- 0.15
alpha <- 0.80

# Build true correlation matrix (compound symmetry)
R_true <- matrix(avg_r, P, P)
diag(R_true) <- 1

# Observed correlation (attenuated by reliability)
R_obs <- R_true
R_obs[R_obs != 1] <- R_obs[R_obs != 1] * alpha

# Observed d (attenuated)
d_obs <- d_true * sqrt(alpha)

# Generate data: females at 0, males at d_obs
mu_f <- rep(0, P)
mu_m <- d_obs

data_f <- mvrnorm(N, mu_f, R_obs)
data_m <- mvrnorm(N, mu_m, R_obs)

colnames(data_f) <- colnames(data_m) <- paste0("V", 1:P)

# ============================================================
# 1. Run the R mf.indices() function
# ============================================================
cat("=== Running mf.indices() ===\n")
result_R <- mf.indices(as.data.frame(data_m), as.data.frame(data_f),
                       method = "lda", draw.plot = FALSE)

# Extract R-function indices (females first, then males — matches R's internal order)
R_mfD <- result_R$indices$mf.D
R_mfT <- result_R$indices$mf.T
R_mfP <- result_R$indices$mf.P
R_mfC <- result_R$indices$mf.C
R_sex <- result_R$indices$sex.m

# ============================================================
# 2. Compute indices using JS-equivalent formulas
# ============================================================

# Sample statistics
means_m <- colMeans(data_m)
means_f <- colMeans(data_f)
n_m <- nrow(data_m)
n_f <- nrow(data_f)

# Pooled covariance (JS approach)
cov_m <- cov(data_m)
cov_f <- cov(data_f)
pooled_cov <- ((n_m - 1) * cov_m + (n_f - 1) * cov_f) / (n_m + n_f - 2)

# JS: correlation from pooled covariance
pooled_sd <- sqrt(diag(pooled_cov))
pooled_cor_JS <- pooled_cov / outer(pooled_sd, pooled_sd)

# R function: weighted average of correlation matrices
pooled_cor_R <- (cor(data_m) * (n_m - 1) + cor(data_f) * (n_f - 1)) / (n_m + n_f - 2)

cat("\n=== Pooled correlation comparison ===\n")
cat("Max |R_cor - JS_cor|:", max(abs(pooled_cor_R - pooled_cor_JS)), "\n")

# Standardize data (JS approach): center on unweighted centroid mean, scale by pooled SD
grand_mean <- (means_m + means_f) / 2
all_data <- rbind(data_f, data_m)  # females first, then males
all_z <- sweep(all_data, 2, grand_mean)
all_z <- sweep(all_z, 2, pooled_sd, "/")

# Sample d-vector from standardized data
cent_f <- colMeans(all_z[1:n_f, ])
cent_m <- colMeans(all_z[(n_f + 1):(n_f + n_m), ])
d_sample <- cent_m - cent_f

# Sex vector
sex_vec <- c(rep(0, n_f), rep(1, n_m))

# --- Use JS-style pooled correlation for JS formulas ---
R_pool <- pooled_cor_JS
R_inv <- solve(R_pool)

# Mahalanobis D
D2 <- as.numeric(t(d_sample) %*% R_inv %*% d_sample)
DM <- sqrt(max(0, D2))
DM_corr <- sqrt(max(0, D2 * (n_m + n_f - P - 3) / (n_m + n_f - 2) - P * (n_m + n_f) / (n_m * n_f)))

cat("\n=== Mahalanobis D ===\n")
# Also compute D from R-function's pooled.cor for comparison
D2_Rmethod <- as.numeric(t(d_sample) %*% solve(pooled_cor_R) %*% d_sample)
DM_Rmethod <- sqrt(max(0, D2_Rmethod))
cat("D (JS pooled cor):", round(DM, 4), "\n")
cat("D (R pooled cor):", round(DM_Rmethod, 4), "\n")

# Discriminant coefficients
a_vec <- R_inv %*% d_sample
a_Ra <- as.numeric(t(a_vec) %*% R_pool %*% a_vec)
norm_factor <- sqrt(max(1e-10, a_Ra))

# Compute indices for each individual
nTotal <- n_f + n_m
d_norm <- sqrt(sum(d_sample^2))

JS_mfD <- numeric(nTotal)
JS_mfT <- numeric(nTotal)
JS_mfP <- numeric(nTotal)
JS_mfC <- numeric(nTotal)

for (i in 1:nTotal) {
  z <- all_z[i, ]

  # M-F_D
  JS_mfD[i] <- sum(z * d_sample) / d_norm

  # M-F_T
  disc_score <- sum(z * a_vec)
  JS_mfT[i] <- disc_score / norm_factor

  # M-F_P (un-normalized score)
  clamped <- max(-30, min(30, disc_score))
  JS_mfP[i] <- 1 / (1 + exp(-clamped))

  # M-F_C
  diff_f <- z - cent_f
  diff_m <- z - cent_m
  dist_f <- sqrt(max(0, as.numeric(t(diff_f) %*% R_inv %*% diff_f)))
  dist_m <- sqrt(max(0, as.numeric(t(diff_m) %*% R_inv %*% diff_m)))
  JS_mfC[i] <- (dist_f - dist_m) / DM
}

# ============================================================
# 3. Compare R-function vs JS-formula
# ============================================================
cat("\n=== Index comparison: R function vs JS formulas ===\n")
cat("(Applied to the SAME data; difference is pooled cor method)\n\n")

compare <- function(name, r_vals, js_vals) {
  r_corr <- cor(r_vals, js_vals)
  max_diff <- max(abs(r_vals - js_vals))
  mean_diff <- mean(abs(r_vals - js_vals))
  cat(sprintf("%-6s  r = %.6f  max|diff| = %.6f  mean|diff| = %.6f\n",
              name, r_corr, max_diff, mean_diff))
}

compare("mf.D", R_mfD, JS_mfD)
compare("mf.T", R_mfT, JS_mfT)
compare("mf.P", R_mfP, JS_mfP)
compare("mf.C", R_mfC, JS_mfC)

cat("\n=== Summary statistics by sex ===\n\n")

for (idx_name in c("mf.D", "mf.T", "mf.P", "mf.C")) {
  r_vals <- switch(idx_name, mf.D = R_mfD, mf.T = R_mfT, mf.P = R_mfP, mf.C = R_mfC)
  js_vals <- switch(idx_name, mf.D = JS_mfD, mf.T = JS_mfT, mf.P = JS_mfP, mf.C = JS_mfC)

  cat(sprintf("--- %s ---\n", idx_name))
  cat(sprintf("  R:  mean(M)=%6.3f  mean(F)=%6.3f  sd(pool)=%5.3f\n",
              mean(r_vals[sex_vec == 1]), mean(r_vals[sex_vec == 0]),
              (sd(r_vals[sex_vec == 1]) + sd(r_vals[sex_vec == 0])) / 2))
  cat(sprintf("  JS: mean(M)=%6.3f  mean(F)=%6.3f  sd(pool)=%5.3f\n",
              mean(js_vals[sex_vec == 1]), mean(js_vals[sex_vec == 0]),
              (sd(js_vals[sex_vec == 1]) + sd(js_vals[sex_vec == 0])) / 2))
}

# Discordant proportion
disc_R <- sum(R_mfD * R_mfT < 0) / nTotal
disc_JS <- sum(JS_mfD * JS_mfT < 0) / nTotal
cat(sprintf("\nDiscordant %%: R = %.1f%%  JS = %.1f%%\n", disc_R * 100, disc_JS * 100))

cat("\nDone.\n")
