
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mskcc.oncotree

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/mskcc.oncotree)](https://CRAN.R-project.org/package=mskcc.oncotree)
<!-- badges: end -->

The goal of `{mskcc.oncotree}` is to facilitate access to the [OncoTree
API](http://oncotree.mskcc.org/).

The OncoTree is an open-source ontology that was developed at Memorial
Sloan Kettering Cancer Center (MSK) for standardizing cancer type
diagnosis from a clinical perspective by assigning each diagnosis a
unique OncoTree code.

Currently, the functionality provided is the retrieval of tumor types
and the mapping of tumor type codes across a few tumor type
classification systems.

## Installation

Install `{mskcc.oncotree}` from CRAN:

``` r
install.packages("mskcc.oncotree")
```

You can install the development version of `{mskcc.oncotree}` with:

``` r
# install.packages("remotes")
remotes::install_github("maialab/mskcc.oncotree")
```

## OncoTree tumor types

Get the tumor types defined by OncoTree in their latest release:

``` r
library(mskcc.oncotree)

(tumor_types <- get_tumor_types())
#> # A tibble: 885 × 13
#>    oncotree_version  oncotree_code oncotree_name   oncotree_main_t… tissue level
#>    <chr>             <chr>         <chr>           <chr>            <chr>  <int>
#>  1 oncotree_latest_… MMB           Medullomyoblas… Embryonal Tumor  CNS/B…     3
#>  2 oncotree_latest_… GCB           Germinal Cente… Mature B-Cell N… Lymph…     6
#>  3 oncotree_latest_… SBLU          Splenic B-Cell… Mature B-Cell N… Lymph…     5
#>  4 oncotree_latest_… OHNCA         Head and Neck … Head and Neck C… Head …     2
#>  5 oncotree_latest_… PAOS          Parosteal Oste… Bone Cancer      Bone       3
#>  6 oncotree_latest_… TMDS          Therapy-Relate… Leukemia         Myelo…     5
#>  7 oncotree_latest_… ARMS          Alveolar Rhabd… Soft Tissue Sar… Soft …     3
#>  8 oncotree_latest_… SCST          Sex Cord Strom… Sex Cord Stroma… Ovary…     2
#>  9 oncotree_latest_… ITLPDGI       Indolent T-Cel… Mature T and NK… Lymph…     5
#> 10 oncotree_latest_… MBC           Metaplastic Br… Breast Cancer    Breast     2
#> # … with 875 more rows, and 7 more variables: parent <chr>, umls_code <list>,
#> #   nci_code <list>, history <list>, revocations <list>, precursors <list>,
#> #   color <chr>
```

The mapping to the corresponding tumor type identifier(s) in the Uniﬁed
Medical Language System (UMLS) and in the National Cancer Institute
(NCI) Thesaurus classification systems is provided in columns
`umls_code` and `nci_code`.

``` r
tumor_types[c('oncotree_code', 'umls_code', 'nci_code')]
#> # A tibble: 885 × 3
#>    oncotree_code umls_code nci_code 
#>    <chr>         <list>    <list>   
#>  1 MMB           <chr [1]> <chr [1]>
#>  2 GCB           <NULL>    <NULL>   
#>  3 SBLU          <NULL>    <NULL>   
#>  4 OHNCA         <NULL>    <NULL>   
#>  5 PAOS          <chr [1]> <chr [1]>
#>  6 TMDS          <NULL>    <NULL>   
#>  7 ARMS          <chr [1]> <chr [1]>
#>  8 SCST          <chr [1]> <chr [1]>
#>  9 ITLPDGI       <NULL>    <NULL>   
#> 10 MBC           <chr [1]> <chr [1]>
#> # … with 875 more rows
```

`umls_code` and `nci_code` are list-columns because the mapping can be
one-to-many.

If you want, you may convert these columns to type `character` by
unnesting with `tidyr::unnest()`. This will have the side effect of
creating more than one row per tumor type for cases where the mapping is
one-to-many.

``` r
tumor_types[c('oncotree_code', 'umls_code')] %>%
  tidyr::unnest(cols = 'umls_code', keep_empty = TRUE)
#> # A tibble: 886 × 2
#>    oncotree_code umls_code
#>    <chr>         <chr>    
#>  1 MMB           C0205833 
#>  2 GCB           <NA>     
#>  3 SBLU          <NA>     
#>  4 OHNCA         <NA>     
#>  5 PAOS          C0206642 
#>  6 TMDS          <NA>     
#>  7 ARMS          C0206655 
#>  8 SCST          C0600113 
#>  9 ITLPDGI       <NA>     
#> 10 MBC           C1334708 
#> # … with 876 more rows
```

## OncoTree versions

The data provided by OncoTree is versioned. You may list the released
versions so far with `get_versions()`:

``` r
get_versions()
#> # A tibble: 28 × 4
#>    oncotree_version           description                   visible release_date
#>    <chr>                      <chr>                         <lgl>   <chr>       
#>  1 oncotree_development       Latest OncoTree under develo… TRUE    2021-11-04  
#>  2 oncotree_candidate_release This version of the OncoTree… TRUE    2021-11-03  
#>  3 oncotree_2021_11_02        Stable OncoTree released on … FALSE   2021-11-02  
#>  4 oncotree_latest_stable     This is the latest approved … TRUE    2021-11-02  
#>  5 oncotree_2020_10_01        Stable OncoTree released on … FALSE   2020-10-01  
#>  6 oncotree_2020_04_01        Stable OncoTree released on … FALSE   2020-04-01  
#>  7 oncotree_2020_02_06        Stable OncoTree released on … FALSE   2020-02-06  
#>  8 oncotree_2020_02_01        Stable OncoTree released on … FALSE   2020-02-01  
#>  9 oncotree_2019_12_01        Stable OncoTree released on … FALSE   2019-12-01  
#> 10 oncotree_2019_08_01        Stable OncoTree released on … FALSE   2019-08-01  
#> # … with 18 more rows
```

The function `get_tumor_types()` accepts a release version, allowing to
get data for past versions of OncoTree:

``` r
get_tumor_types(oncotree_version = 'oncotree_2019_08_01')
#> # A tibble: 863 × 13
#>    oncotree_version    oncotree_code oncotree_name oncotree_main_t… tissue level
#>    <chr>               <chr>         <chr>         <chr>            <chr>  <int>
#>  1 oncotree_2019_08_01 MMB           Medullomyobl… Embryonal Tumor  CNS/B…     3
#>  2 oncotree_2019_08_01 GCB           Germinal Cen… Mature B-Cell N… Lymph…     6
#>  3 oncotree_2019_08_01 SBLU          Splenic B-Ce… Mature B-Cell N… Lymph…     5
#>  4 oncotree_2019_08_01 OHNCA         Head and Nec… Head and Neck C… Head …     2
#>  5 oncotree_2019_08_01 PAOS          Parosteal Os… Bone Cancer      Bone       3
#>  6 oncotree_2019_08_01 TMDS          Therapy-Rela… Leukemia         Myelo…     5
#>  7 oncotree_2019_08_01 ARMS          Alveolar Rha… Soft Tissue Sar… Soft …     3
#>  8 oncotree_2019_08_01 SCST          Sex Cord Str… Sex Cord Stroma… Ovary…     2
#>  9 oncotree_2019_08_01 ITLPDGI       Indolent T-C… Mature T and NK… Lymph…     5
#> 10 oncotree_2019_08_01 MBC           Metaplastic … Breast Cancer    Breast     2
#> # … with 853 more rows, and 7 more variables: parent <chr>, umls_code <list>,
#> #   nci_code <list>, history <list>, revocations <list>, precursors <list>,
#> #   color <chr>
```

## Mapping of tumor type codes

### UMLS and NCIt

OncoTree provides a few mappings between their identifiers (codes) and
other tumor classification systems. Currently, through their web API,
only mappings between OncoTree codes and Uniﬁed Medical Language System
(UMLS) and National Cancer Institute (NCI) Thesaurus (NCIt) codes are
provided.

From `{mskcc.oncotree}` we provide four functions:

| Function             | Description                |
|----------------------|----------------------------|
| `oncotree_to_nci()`  | Map OncoTree to NCIt codes |
| `nci_to_oncotree()`  | Map NCIt to OncoTree codes |
| `oncotree_to_umls()` | Map OncoTree to UMLS codes |
| `umls_to_oncotree()` | Map UMLS to OncoTree codes |

### From and to NCIt

``` r
oncotree_to_nci(c('MMB', 'PAOS'), expand = TRUE)
#> # A tibble: 2 × 2
#>   oncotree_code nci_code
#>   <chr>         <chr>   
#> 1 MMB           C3706   
#> 2 PAOS          C8969

nci_to_oncotree(c('C3706', 'C8969'), expand = TRUE)
#> # A tibble: 2 × 2
#>   nci_code oncotree_code
#>   <chr>    <chr>        
#> 1 C3706    MMB          
#> 2 C8969    PAOS
```

### From and to UMLS

``` r
oncotree_to_umls(c('MMB', 'PAOS'), expand = TRUE)
#> # A tibble: 2 × 2
#>   oncotree_code umls_code
#>   <chr>         <chr>    
#> 1 MMB           C0205833 
#> 2 PAOS          C0206642

umls_to_oncotree(c('C0205833', 'C0206642', 'C1334708'), expand = TRUE)
#> # A tibble: 3 × 2
#>   umls_code oncotree_code
#>   <chr>     <chr>        
#> 1 C0205833  MMB          
#> 2 C0206642  PAOS         
#> 3 C1334708  MBC
```

### Other mappings

Besides UMLS and NCIt, you may also map OncoTree codes to
[ICD-O](https://en.wikipedia.org/wiki/International_Classification_of_Diseases_for_Oncology)
topography and morphology, and [HemeOnc](https://hemonc.org/) codes.
This functionality is based on the file
[ontology_mappings.txt.](https://github.com/cBioPortal/oncotree/blob/master/scripts/ontology_to_ontology_mapping_tool/ontology_mappings.txt)
provided by OncoTree at their GitHub repository.

In OncoTree’s discussion forum the developers have warned that this data
can’t be expected to be neither accurate nor complete. However, it might
still be useful for some users, and hence we also provide access to
these mappings with the function `map_ontology_code()`.

Here are some usage examples `map_ontology_code()`:

``` r
# Simple example
map_ontology_code(code = 'MMB', from = 'oncotree_code', to = 'nci_code')
#> # A tibble: 1 × 2
#>   oncotree_code nci_code
#>   <chr>         <chr>   
#> 1 MMB           C3706

# Omit the `code` argument to get all possible mappings. Note that
# one-to-many mappings will generate more than one row per `from` code.
map_ontology_code(from = 'oncotree_code', to = 'nci_code')
#> # A tibble: 855 × 2
#>    oncotree_code nci_code
#>    <chr>         <chr>   
#>  1 MMB           C3706   
#>  2 AIS           C4123   
#>  3 AASTR         C9477   
#>  4 FL            C3209   
#>  5 VIMT          C4286   
#>  6 KIDNEY        C12415  
#>  7 MDEP          C4327   
#>  8 PAOS          C8969   
#>  9 PRSCC         C6766   
#> 10 DSTAD         C9159   
#> # … with 845 more rows

# Some mappings are one-to-many, e.g. "SRCCR", which means repeated rows for
# the same input code.
map_ontology_code(code = 'SRCCR', from = 'oncotree_code', to = 'nci_code')
#> # A tibble: 2 × 2
#>   oncotree_code nci_code
#>   <chr>         <chr>   
#> 1 SRCCR         C9168   
#> 2 SRCCR         C7967

# Using the `collapse` argument to "collapse" one-to-many mappings makes sure
# that the output has as many rows as the `from` vector.
map_ontology_code(code = 'SRCCR',
                  from = 'oncotree_code',
                  to = 'nci_code',
                  collapse = toString)
#> # A tibble: 1 × 2
#>   oncotree_code nci_code    
#>   <chr>         <chr>       
#> 1 SRCCR         C9168, C7967

map_ontology_code(code = 'SRCCR',
                  from = 'oncotree_code',
                  to = 'nci_code',
                  collapse = list)
#> # A tibble: 1 × 2
#>   oncotree_code nci_code 
#>   <chr>         <list>   
#> 1 SRCCR         <chr [2]>

map_ontology_code(
  code = 'SRCCR',
  from = 'oncotree_code',
  to = 'nci_code',
  collapse = \(x) paste(x, collapse = ' ')
)
#> # A tibble: 1 × 2
#>   oncotree_code nci_code   
#>   <chr>         <chr>      
#> 1 SRCCR         C9168 C7967

# `map_ontology_code()` is vectorized over `code`
map_ontology_code(code = c('AASTR', 'MDEP'), from = 'oncotree_code', to = 'nci_code')
#> # A tibble: 2 × 2
#>   oncotree_code nci_code
#>   <chr>         <chr>   
#> 1 AASTR         C9477   
#> 2 MDEP          C4327

# Map from ICDO topography to ICDO morphology codes
map_ontology_code(code = 'C72.9', from = 'icdo_topography_code', to = 'icdo_morphology_code')
#> # A tibble: 65 × 2
#>    icdo_topography_code icdo_morphology_code
#>    <chr>                <chr>               
#>  1 C72.9                9401/3              
#>  2 C72.9                9501/3              
#>  3 C72.9                9390/1              
#>  4 C72.9                8000/3              
#>  5 C72.9                9424/3              
#>  6 C72.9                9391/3              
#>  7 C72.9                9425/3              
#>  8 C72.9                9383/1              
#>  9 C72.9                9100/3              
#> 10 C72.9                9522/3              
#> # … with 55 more rows
```
