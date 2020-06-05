# R and Google Analytics Use Cases

## Introduction

Your web analytics data is trapped! Google Analytics provides you with a handful of built-in reports and features, but your data has so much more potential. Fortunately, the data-oriented programming language R, can easily connect to Google Analytics and produce results that go far beyond the features in GA (or even Data Studio). With R you can:

- Create high-quality charts & graphs not accessible in the Google Analytics interface
- Run statistical tests to compare tests or segments
- Join your web data with other data sources (CRM, offline sales, server-side data, etc)  
- Run machine learning algorithms such as forecasting, clustering, and market basket analysis
- Work with unsampled data

## Examples

- Quantifying the impact of events on time series data using the CausalImpact library: [Tutorial](https://adamribaudo.github.io/R-Google-Analytics-Examples/Tutorial-Causal-Impact.nb.html) / [Code](Tutorial-Causal-Impact.Rmd)
- Google Analytics audits via scripted R Markdown file: [Output](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-Audit-Tool.html) / [Code](GA-Audit-Tool.Rmd)
- Recreating the Google Analytics explorer graph & table in R: [Output](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-explorer-in-R.nb.html) / [Code](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-explorer-in-R.Rmd)
- Exploring GA segment overlap with Venn diagrams: [Output](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-segment-overlap.html) / [Code](GA-segment-overlap.Rmd)
- Running Market Basket Analysis with GA data: [Blog Post](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-Market-Basket-Analysis.html) / [Code](GA-Market-Basket-Analysis.Rmd)
- Pulling Google's [web vital metrics](https://web.dev/vitals/) from GA: [Output](https://adamribaudo.github.io/R-Google-Analytics-Examples/GA-Web-Vitals.html) / [Code](GA-Web-Vitals.Rmd). Assumes that these metrics exist in GA using the process described in [this blog post](https://www.noisetosignal.io/2020/05/add-web-vitals-to-google-analytics/)
