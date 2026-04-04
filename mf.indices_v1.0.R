


# mf.indices
#
# Marco Del Giudice (2024). Version 1.0. Contact: marco.delgiudice@units.it
#
# An R function that calculates four alternative masculinity-femininity (M-F) indices from a set of variables, and draws summary plots if desired. The four indices are: sex-directionality (mf.D), sex-typicality (mf.T), sex-probability (mf.P), and sex-centrality (mf.C). All indices are computed from standardized variables (based on the pooled SD), and use the pooled correlation matrix when relevant. For background and details see Del Giudice (2024).
#
# Alternative methods: the function can calculate sex-typicality and sex-probability indices with two methods: linear discriminant analysis (LDA, the default) or logistic regression. The methods are structurally similar and usually yield almost identical results; unlike LDA, logistic regression does not assume multivariate normality in the data. 
#
# Measurement error correction: if desired, the function performs data matrix disattenuation (DMD; Del Giudice, 2023) separately on the male and female data, to correct measurement error before calculating M-F indices. To perform DMD, the user must provide a vector of reliabilities for the variables in the set.
#
#
# References
# 
# Del Giudice, M. (2024). Statistical indices of masculinity-femininity: A theoretical and practical framework. Behavior Research Mthods.
# Del Giudice, M. (2023). Data matrix disattenuation: A simple, effective method for correcting measurement error in multivariate datasets. PsyArXiv.






# function mf.indices (m, f, method = "lda", reliability = NULL, draw.plot = TRUE, points.cex = 0.7, points.alpha = 0.5, colors = "pinkblue")
#
#
#
# Arguments
#   
# m, f				two data frames or matrices containing the data used to calculate the M-F indices, separately for males and females (note: m and f must contain the same variables). The data must contain only complete cases; the function returns an error message if NAs are detected.
#
# method			if "lda" (default), sex-typicality and sex-probability scores are calculated with linear discriminant analysis. If method is set to "lr", logistic regression is employed instead.
#
# reliability 		if a vector of reliabilities is provided, the function uses it to correct measurement error with the DMD method. If NULL, no error correction is performed.
#
# draw.plot			if TRUE, the function draws a summary plot of the results.
#
# points.cex		the expansion parameter (default is 0.7) that determines the size of the points in the scatterplots. With large datasets, smaller values help increase the clarity of the plots.
#
# points.alpha		the transparency parameter (default is 0.5) for the points in the scatterplots. With large datasets, lower values help increase the clarity of the plots.
#
# colors			the color scheme for the plots. The default ("pinkblue") uses light blue for males and pink for females. The alternative scheme "redblue" uses blue for males and red for females.
#
#
#
# Value
#
# Returns a list containing:
#
# indices.m			a data frame containing the values of the four indices (mf.D, mf.T, mf.P, mf.C) in the male subsample.
#
# indices.f			a data frame containing the values of the four indices (mf.D, mf.T, mf.P, mf.C) in the female subsample. 
#
# indices			a data frame containing the values of the four indices (mf.D, mf.T, mf.P, mf.C) in the entire sample. The last variable (sex.m) identifies the sex of each case (0 = female, 1 = male).
#
#
#
# Plots
#
# A plot showing the distributions of the four indices by sex (on the diagonal); scatterplots between pairs of indices, with different colors in males and females (below the diagonal); and correlations between pairs of indices (above the diagonal), both in the whole sample (r) and with sex partialed out (r_p).




library(whitening)
library(Matrix)



mf.indices <- function(m, f, method = "lda", reliability = NULL, draw.plot = TRUE, points.cex = 0.7, points.alpha = 0.5, colors = "pinkblue") {

warn = getOption("warn")
options(warn=-1) # suppress warnings

############ Check for NAs

if (sum(is.na(m)) > 0 | sum(is.na(f)) > 0) stop("ERROR: NAs detected (data must contain only complete cases)")


############ Graphical device check for Windows

if (.Platform$OS.type=="windows") quartz<-function(...) windows(...)


############ Accessory plotting functions (for "pairs")

panel.density.sex <- function(x, sex.m, sex.colors, ...) {  # plot showing density by sex 
	
	usr <- par("usr")
    on.exit(par(usr))
    par(usr = c(usr[1], usr[2], 0, 1.5))
	density.m = density(x[sex.m==1], adjust=1.2)
	density.f = density(x[sex.m==0], adjust=1.2)
	density.values = c(density.m$y, density.f$y)
	polygon(density.f$x, density.f$y/max(density.values), col=adjustcolor(sex.colors[2], alpha.f=0.10), border=adjustcolor(sex.colors[2], alpha.f=0.85) , lwd=1.5, ylim=c(0, max(density.values)))
	polygon(density.m$x, density.m$y/max(density.values), col=adjustcolor(sex.colors[1], alpha.f=0.10), border=adjustcolor(sex.colors[1], alpha.f=0.85) , lwd=1.5, ylim=c(0, max(density.values)))
}


panel.pcor.sex <- function(x, y, sex.m, ...) {  # plot showing correlations and partial correlations (controlling for sex)

	usr <- par("usr")
    on.exit(par(usr))
    par(usr = c(0, 1, 0, 1))
    r = cor(x,y)
	rp = as.numeric((cor(x, y) - cor(x, sex.m)*cor(y, sex.m))/sqrt((1-cor(x, sex.m)^2)*(1-cor(y, sex.m)^2))) # partial correlation controlling for sex
	txt.r = as.character(round(r, 2))
	txt.rp = as.character(round(rp, 2))
	text(0.5, 0.62, bquote(paste(r, " = ", .(txt.r))), cex = 1.6)
	text(0.5, 0.38, bquote(paste(r[p], " = ", .(txt.rp))), cex = 1.6)
}


panel.points.sex <- function(x, y, sex.m, points.alpha, points.cex, sex.colors, ...) {  # scatterplot with point colors by sex 

	if (min(x) < 0 & min(y) < 0) {  # identifies the plot with M-F_D vs. M-F_T or M-F_C
		
		if (sum((x*y)<0) > 0) {
		
		rect(1.05*min(x), 1.03*max(y), 0, 0, border=NA, col="grey94")
		rect(0, 0, 1.03*max(x), 1.05*min(y), border=NA, col="grey94")
		abline(h=0, v=0, col="grey45", lty=3, lwd=1)
		}
	}
	
	if (min(x) < 0 & min(y) >= 0) { # identifies the plot with M-F_D vs. M-F_P
		
		if (sum((x*(y-0.5))<0) > 0) {
		
		rect(1.05*min(x), 1.02*max(y), 0, 0.5, border=NA, col="grey94")
		rect(0, 0.5, 1.03*max(x), min(y)-0.02, border=NA, col="grey94")
		abline(h=0.5, v=0, col="grey45", lty=3, lwd=1)
		}
	}
	
	points.colors = c(adjustcolor(sex.colors[1], alpha.f=points.alpha), adjustcolor(sex.colors[2], alpha.f=points.alpha))
	scramble = sample(1:length(as.vector(x)), length(as.vector(x)), replace=FALSE) # data are scrambled to reduce overplotting
	x.scrambled = as.vector(x)[scramble]
	y.scrambled = as.vector(y)[scramble]
	sex.m.scrambled = t(as.vector(sex.m))[scramble]
	colors.scrambled = points.colors[1 + 1*(sex.m.scrambled==0)]
	points(x.scrambled, y.scrambled, pch=20, col=colors.scrambled, cex=points.cex)
}


############ Data

n.m = as.numeric(nrow(m))
n.f = as.numeric(nrow(f))

k = ncol(m)

sex.m = c(rep(0, n.f), rep(1, n.m)) # grouping vector (0 = female, 1 = male)


############ Measurement error correction with DMD

if (is.null(reliability) == FALSE) {
	
	means.m = colMeans(m)
	means.f = colMeans(f)
	vars.m = diag(var(m))
	vars.f = diag(var(f))
	
	m = scale(m)
	f = scale(f)
	
	cor.obs.m = cor(m)
	cor.obs.f = cor(f)
	
	rel.matrix = sqrt(crossprod(t(reliability), t(reliability)))
	diag(rel.matrix) = 1
	
	cor.c.m = cor.obs.m/rel.matrix  # disattenuate the correlation matrix
	cor.c.f = cor.obs.f/rel.matrix
	
	if (sum(eigen(cor.c.m)$values < 0) > 0) cor.c.m = as.matrix(nearPD(cor.c.m, corr=TRUE)$mat) #### check if the matrix is indefinite; if so, find the nearest positive definite matrix
	if (sum(eigen(cor.c.f)$values < 0) > 0) cor.c.f = as.matrix(nearPD(cor.c.f, corr=TRUE)$mat)
	
	coloring.matrix.m = solve(whiteningMatrix(cor.c.m, method="ZCA-cor")) # coloring matrix based on the disattenuated correlation matrix
	coloring.matrix.f = solve(whiteningMatrix(cor.c.f, method="ZCA-cor"))
	
	m = as.data.frame(t( coloring.matrix.m %*% t(whiten(as.matrix(m), center=TRUE, method="ZCA-cor")) )) # whiten then color the data
	f = as.data.frame(t( coloring.matrix.f %*% t(whiten(as.matrix(f), center=TRUE, method="ZCA-cor")) ))
	
	m = scale(m, center = FALSE, scale=1/sqrt(vars.m*reliability))
	m = scale(m, center = -means.m, scale=FALSE)
	f = scale(f, center = FALSE, scale=1/sqrt(vars.f*reliability))
	f = scale(f, center = -means.f, scale=FALSE)
}



############ Preliminary computations

pooled.variances = ((n.m-1)*diag(var(m))+(n.f-1)*diag(var(f)))/(n.m+n.f-2)
d.values = (colMeans(m)-colMeans(f))/sqrt(pooled.variances)
pooled.cor = (cor(m)*(n.m-1)+cor(f)*(n.f-1))/(n.m+n.f-2) 
DM.centroids = sqrt(mahalanobis(d.values, cov=pooled.cor, center=FALSE))  # Mahalanobis distance between the male and female  centroids

data = as.data.frame(rbind(f,m)) 
data = as.data.frame(scale(data, center=(colMeans(data[1:n.f,]) + colMeans(data[(n.f+1):(n.f+n.m),]))/2, scale=sqrt(pooled.variances) )) # center the data on the unweighted centroid mean, standardize by the pooled SD

centroid.f = colMeans(data[1:n.f,]) # new male and female centroids for standardized and centered data
centroid.m = colMeans(data[(n.f+1):(n.f+n.m),])


############ Calculate sex-directionality scores
 
mf.D = drop(as.matrix(data)%*%d.values)/sqrt(sum(d.values^2))

indices = data.frame(mf.D = mf.D)

############ Calculate sex-typicality and sex-probability scores

if (method == "lda") {
	
	### sex-typicality scores with LDA
	
	discrim.coeff = solve(pooled.cor)%*%d.values
	normalization.factor = drop(sqrt(t(discrim.coeff)%*%pooled.cor%*%discrim.coeff))
	discrim.scores = drop(as.matrix(data)%*%discrim.coeff)
	indices$mf.T = discrim.scores/normalization.factor
	
	### sex-probability scores with LDA
	
	indices$mf.P = exp(discrim.scores)/(1+exp(discrim.scores))
}

if (method == "lr") { 

	### sex-typicality scores with logistic regression
	
	formula.string = paste("sex.m ~ data$", names(data)[1], sep="")
	for (index in 2:ncol(data)) formula.string = paste(formula.string, " + data$", names(data)[index], sep="")
	lr.model = glm(as.formula(formula.string), family=binomial)
	normalization.factor = drop(sqrt(t(as.vector(lr.model$coefficients[2:(ncol(data)+1)]))%*%pooled.cor%*%as.vector(lr.model$coefficients[2:(ncol(data)+1)])))
	linear.pred.scores = (lr.model$linear.predictors-lr.model$coefficients[1]) # subtract the intercept to correct for unequal proportions of males and females in the sample
	indices$mf.T = linear.pred.scores/normalization.factor # the normalization factor puts the scores on the same scale as those calculated with LDA
	
	### sex-probability scores with logistic regression
	
	indices$mf.P = exp(linear.pred.scores)/(1+exp(linear.pred.scores))
}


############ Calculate sex-centrality scores (using the pooled correlation matrix)

distance.M = sqrt(mahalanobis(data, center=centroid.m, cov=pooled.cor))
distance.F = sqrt(mahalanobis(data, center=centroid.f, cov=pooled.cor))
indices$mf.C = (distance.F - distance.M)/DM.centroids

indices$sex.m = sex.m

############ Draw plot

if (colors == "pinkblue") sex.colors=c(rgb(45, 140, 237, maxColorValue=255), rgb(235, 88, 185, maxColorValue=255))
if (colors == "redblue") sex.colors=c(rgb(78, 68, 229, maxColorValue=255), rgb(215, 40, 37, maxColorValue=255))


if (draw.plot == TRUE) {
	
	quartz()
	 
	pairs(indices[,1:4], labels=c(expression("M-F"["D"]), expression("M-F"["T"]), expression("M-F"["P"]), expression("M-F"["C"])), diag.panel=panel.density.sex, upper.panel=panel.pcor.sex, lower.panel=panel.points.sex, sex.m=indices[,5], points.alpha=points.alpha, points.cex=points.cex, sex.colors = sex.colors, cex.labels=1.7)
}


############ Output

prop.discordant = sum(indices$mf.T*indices$mf.D < 0) / nrow(data)

if (is.null(reliability) == FALSE) cat("\nNOTE: The data have been corrected for measurement error (DMD method)\n")
cat("\nMahalanobis distance between centroids: ", round(DM.centroids, 2), "; bias-corrected estimate: ", round(sqrt(max(0,((DM.centroids^2)*(n.m+n.f-k-3)/(n.m+n.f-2)-k*(n.m+n.f)/(n.m*n.f)))),2), "\n", sep="")
cat("Proportion of discordant profiles: ", round(prop.discordant*100, 1), "%\n\n", sep="")

### Results by sex

indices.m = indices[(n.f+1):(n.f+n.m), 1:4]
rownames(indices.m) = 1:nrow(indices.m)

indices.f = indices[1:n.f, 1:4]
rownames(indices.f) = 1:nrow(indices.f)

### Return output list

return(list(indices.m=indices.m, indices.f=indices.f, indices=indices))

options(warn=warn) # re-enable warnings

### end
}

