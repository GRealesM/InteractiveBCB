---
title: "Help document"
output: html_document
#runtime: shiny_prerendered
---

[//]: # (This chunk is necessary to guarantee the app will rescale with different window sizes.)

<style type="text/css">
           body {          
           max-width:100%;
           padding:0;
           }
</style>


<br>

# Interactive Blood Cell Basis App



##  Introduction

Understanding the aetiological relationships between multiple (>2) complex diseases can provide insights into shared pathogenic themes which can then be used to inform therapeutic intervention. However, this has proved challenging for a number of reasons. In our paper [**'Genetic feature engineering enables characterisation of shared risk factors in immune-mediated diseases'**](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00797-4), we expanded on these challenges and described a novel approach *cupcake* that seeks to overcome them. In the paper we propose a statistical framework that allows the creation of a lower-dimensional basis that summarises the sharing of genetic risk across a set of clinically related diseases. Using publicly available GWAS summary stats we apply the framework to the study of immune-mediated disease (IMD) to create an IMD specific basis. 

One of the traits of interest for us are *Blood cell counts*, since blood cells play a crucial role in innate and acquired immune responses. Qualitative or quantitative abnormalities of blood cell formation, and of their physiological and functional properties, have been associated with predisposition to cancer and with many severe congenital disorders including anaemias, bleeding, and thrombotic disorders and immunodeficiencies. 
We built a 14-feature basis of blood cell levels, using data from [Astle et al., 2016](https://doi.org/10.1016/j.cell.2016.10.042), which comprises 36 GWAS datasets from blood cell-related traits on ~170,500 European individuals, on average. 

The Interactive Blood Cell Basis App (InteractiveBCB) aims to provide a visual and interactive presentation of the results of this project. We envisage three main scenarios where this might be useful:

1. You prefer interactive visualisation, or want to explore the basis beyond the results highlighted in the paper.
2. You want to understand if a trait of interest among the projected shares a common genetic risk component with Blood cell counts.
3. You want more information on the GWAS datasets used in the paper.

A manuscript describing the results is on the making.


## Methodology

A  detailed account of the methodology is available in the paper but here is a brief explanation aimed at broad audience. Assessing the shared genetic architecture for more than two traits is challenging, the number of variants assayed in a GWAS is often in the millions which quickly makes useful comparisons problematic. One approach is dimension reduction; here we make sure that effect sizes (odds ratios) for each disease are with respect to the same allele and then arrange them in a large matrix. We can then perform standard principal component analysis (PCA) on this matrix to create lower-dimensional summaries of the shared and distinct genetic architectures of the input diseases creating a object called a **basis**. Unfortunately this naive approach does not work, the relationships that we are interested in are obscured by other phenomena such as linkage disequillibrium, study heterogeneity (e.g. sample size)  and variant allele frequencies. To overcome this we adapt strategies from genetic fine mapping to train a Bayesian "lens" to focus our attention only on the disease-associated fraction of the genome. We can then apply the lens to matrix of disease variant effect sizes and use this perform PCA and successfully elucidate components of shared genetic risk. 

This lens can be applied to external GWAS datasets, and these reweighted effect sizes can be projected onto this **basis** and their location with basis-space observed. We developed a method to assess whether the location of a projected trait within basis-space is significantly different from what would be expected under the null, thus enabling the kinds of analyses detailed in the introduction.  

We applied **varimax rotation** to the PCA rotation matrix with the aim to make each factor relate to as few variables as possible (and vice versa). Thus, the varimax rotation simplifies the loadings of items by removing the middle ground and more specifically identifying the factor upon which data load. This has the desirable effect to increase high- and low-value loadings and reduce mid-value loadings, thus helping to characterise the different components.

Upon creating the basis, we projected onto it 10,000+ GWAS summary statistics from diverse traits, sources, and populations. Our main single source is [FinnGen](https://www.finngen.fi/en), a Finnish genomics consortium that releases GWAS summary statistics on thousands of traits periodically. Other sources include UKBB (Neale, and PanUKBB), but Astle datasets included UKBB individuals, so we avoided considering UKBB when possible to avoid the risk of overfitting.

We classified the traits into the following broad categories, according to our specific focus on immune biology:

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Symbol </th>
   <th style="text-align:left;"> Trait class </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> BC </td>
   <td style="text-align:left;"> Blood cell counts and related traits </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BMK </td>
   <td style="text-align:left;"> Biomarkers (eg. cytokines and growth factors) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> Cancer-related traits </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IMD </td>
   <td style="text-align:left;"> Immune-mediated diseases </td>
  </tr>
  <tr>
   <td style="text-align:left;"> INF </td>
   <td style="text-align:left;"> Infectious diseases and related traits </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PSD </td>
   <td style="text-align:left;"> Psychiatric and neurological diseases/disorders </td>
  </tr>
  <tr>
   <td style="text-align:left;"> OTH </td>
   <td style="text-align:left;"> Other traits (not included in any other category) </td>
  </tr>
</tbody>
</table>

We tested the null hypothesis of each projection being zero for each feature and overall. Then we applied an FDR 1% threshold on overall P-values by trait class, and FDR 1% and 5% on P-values for each projection, by Trait class and feature. From here, we considered only datasets that were significant overall at FDR 1%. These are contained in the **Dataset info** table.



## What's in the box

If you look at the left hand side menu, you'll see the different options available for visualisation, which we'll describe below:

### Single feature visualisation

This section will help you explore the **features** (or Principal components) in the basis one-by-one. 
You can click on 

- **Delta plots** to see how traits are distributed by their Delta value (eg. projection value - projection of a synthetic null GWAS, see [Burren et al., (2020)]((https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00797-4)) for more details), with 95% confidence intervals. Traits are colour-coded by trait class, with "Basis" traits corresponding to Astle trait projections, used here as placeholders. Mouse over to get projection info on each data point.

- **Projection table** to see extended information displayed in the plot (except for the basis traits), in table format. You can also copy and download the table.

You can use the **Feature / PC** slider bar below to switch among features, both for plots and tables.

Note that we removed projected traits of the Blood Cell category for this section to avoid cluttering.


### Multiple feature visualisation

In the **biplots** section, you'll be able to visualise two features at the same time. Use the two sliders below to select which features to show in the X and Y axes, respectively. 

Again, projections are colour-coded, but this time we used external, trans-ancestry datasets from [Chen et al., 2020](https://doi.org/10.1016/j.cell.2020.06.045) to represent basis projections. Chen datasets comprise 15 blood cell counts also contained in Astle, but from multiple world populations and larger sample sizes (see below).

In the **Heatmaps** section you'll be able to see projections and clustering of traits using all features at the same time. This is useful to see where a trait sits across the whole basis, as well as general patterns across features and traits. 

Points on each cell denote that the projection is significant at FDR 1% (full point, ???) or at FDR 5% (hollow point, ???) for that feature.



There are two options available:

- **Blood cells (Chen)**: This heatmap will show how independent, multi-ancestry blood cell dataset projections are distributed in the basis, using data from [Chen et al., 2020](https://doi.org/10.1016/j.cell.2020.06.045). Chen and colleagues published GWAS on 15 blood cell counts and related traits matching the basis' in 5 world populations (African, European, East Asian, South Asian and Hispanic/Latinos), as well as trans-ancestry meta-analyses, comprising over 500,000+ individuals. Here we show how matching traits mostly cluster together, demonstrating that the Blood cell basis captures true blood cell signal and it is robust to different LD structures derived from multiple ancestries (colour-coded on the right hand side panel). 

- **By trait class**: This heatmap offers a view of projections across all features by trait class. Use the selection menu below to select the trait class for visualisation.

Heatmaps are made using [heatmaply](https://cran.r-project.org/web/packages/heatmaply/vignettes/heatmaply.html), using default (hierarchical clustering) algorithm for clustering.

### Dataset info

A table with general information on each significant overall projected dataset.

---

## Citation

InteractiveBCB App accompanies a manuscript currenly being written, and so does not have an associated publication yet. However, like the [IMDbasisApp](https://grealesm.shinyapps.io/IMDbasisApp/), it relies on the method developed in the following publication:

- Burren OS *et al.* (2020) "Genetic feature engineering enables characterisation of shared risk factors in immune-mediated diseases" *Genome Med*. 12. 106. doi:[10.1186/s13073-020-00797-4](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00797-4).


## About

This software has been developed by Guillermo Reales (gr440 [at] cam [dot] ac [dot] uk) within the  [**Wallace Group**](https://chr1swallace.github.io) and funded by the **Wellcome Trust**.
