library(dplyr)
library(ggplot2)
library(corrplot)
library(factoextra)

coffee_theme <- theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(face = "bold")
  )
knitr::opts_chunk$set(echo = TRUE)

species_palette <- c("Arabica" = "#1f77b4", "Robusta" = "#d62728")
coffee <- read.csv("merged_data_cleaned.csv")

sensory_vars <- coffee %>%
  select(Aroma, Flavor, Aftertaste, Acidity, Body, Balance,
         Uniformity, Clean.Cup, Sweetness,
         Cupper.Points, Total.Cup.Points, Moisture)
species <- coffee$Species
sensory_scaled <- scale(sensory_vars)

cor_matrix <- cor(sensory_scaled)

corrplot(cor_matrix,
         method = "color",
         type = "upper",
         tl.cex = 0.7,
         tl.col = "black",
         order = "hclust")

pca_model <- prcomp(sensory_scaled, center = FALSE, scale. = FALSE)

summary(pca_model)
pca_model$rotation

#Scree Plot
fviz_eig(pca_model, addlabels = TRUE) +
  coffee_theme +
  labs(
    title = "Scree Plot",
    x = "Principal Component",
    y = "Explained Variance (%)"
  )

#Loading Plot
fviz_pca_var(pca_model, repel = TRUE) +
  coffee_theme +
  labs(
    title = "PCA Variable Loadings",
    subtitle = "Directions indicate how sensory attributes contribute to components"
  )

#PCA Scores
pca_scores <- as.data.frame(pca_model$x)
pca_scores$Species <- species

ggplot(pca_scores, aes(PC1, PC2, color = Species, fill = Species)) +
  geom_point(alpha = 0.55, size = 2) +
  stat_ellipse(type = "norm", level = 0.95, geom = "polygon", alpha = 0.12, color = NA) +
  stat_ellipse(type = "norm", level = 0.95, linewidth = 0.7) +
  scale_color_manual(values = species_palette, na.value = "grey50") +
  scale_fill_manual(values = species_palette, na.value = "grey50") +
  coffee_theme +
  labs(
    title = "PCA Projection of Coffee Sensory Data",
    subtitle = "Ellipses show 95% concentration by Species",
    x = "PC1",
    y = "PC2"
  )

dist_matrix <- dist(sensory_scaled, method = "euclidean")
mds_model <- cmdscale(dist_matrix, k = 2, eig = TRUE)
mds_scores <- as.data.frame(mds_model$points)
colnames(mds_scores) <- c("Dim1", "Dim2")
mds_scores$Species <- species

ggplot(mds_scores, aes(Dim1, Dim2, color = Species, fill = Species)) +
  geom_point(alpha = 0.55, size = 2) +
  stat_ellipse(type = "norm", level = 0.95, geom = "polygon", alpha = 0.12, color = NA) +
  stat_ellipse(type = "norm", level = 0.95, linewidth = 0.7) +
  scale_color_manual(values = species_palette, na.value = "grey50") +
  scale_fill_manual(values = species_palette, na.value = "grey50") +
  coffee_theme +
  labs(
    title = "Euclidean MDS",
    x = "Dimension 1",
    y = "Dimension 2"
  )

dist_matrix_manhattan <- dist(sensory_scaled, method = "manhattan")
mds_model_manhattan <- cmdscale(dist_matrix_manhattan, k = 2)

mds_scores_manhattan <- as.data.frame(mds_model_manhattan)
colnames(mds_scores_manhattan) <- c("Dim1", "Dim2")
mds_scores_manhattan$Species <- species

ggplot(mds_scores_manhattan, aes(Dim1, Dim2, color = Species, fill = Species)) +
  geom_point(alpha = 0.55, size = 2) +
  stat_ellipse(type = "norm", level = 0.95, geom = "polygon", alpha = 0.12, color = NA) +
  stat_ellipse(type = "norm", level = 0.95, linewidth = 0.7) +
  scale_color_manual(values = species_palette, na.value = "grey50") +
  scale_fill_manual(values = species_palette, na.value = "grey50") +
  coffee_theme +
  labs(
    title = "Manhattan MDS",
    x = "Dimension 1",
    y = "Dimension 2"
  )