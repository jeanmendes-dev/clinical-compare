# 🧪 clinical-compare

![R](https://img.shields.io/badge/R-4.0%2B-blue?logo=r)
![License](https://img.shields.io/badge/license-MIT-green)

An automated R solution for comparative group analysis in clinical or epidemiological studies. It generates a Table 1, professional visualizations, and adjusted statistical models — all in minutes.

Ideal for randomized clinical trials, cohort studies, efficacy evaluations, or any analysis requiring baseline characterization with statistical rigor.

---

## 🔍 What This Project Offers

- 📊 **Publication-ready Table 1**  
  Automatically compares demographic and clinical variables between groups (continuous and categorical), using appropriate statistical tests..
  
- 📈 **Professional Visualizations**  
  Boxplots, bar charts, and density plots for visual exploration of group differences — styled for clinical reports and stakeholder presentations.*.

- 📉 **Advanced Statistical Analysis**  
  Adjusted logistic regression to estimate the effect of group assignment (e.g., treatment vs. control) after controlling for confounding covariates..

- 🧪 **Built-in Example Data**  
  A simulated Excel file (dados_exemplo.xlsx) is included to test the full workflow without requiring real clinical data.

---

## 🖼️ Example Output

### Table 1: Baseline Characteristics by Treatment Group

![Tabela 1 gerada pelo clinical-compare](tabela1.png)

> The table is generated using gtsummary + gt, featuring elegant formatting, proper alignment, bold p-values when significant, and output ready for inclusion in reports or manuscripts..

### Group Comparison Plots

![Gráficos de comparação entre grupos](comparacao_grupos.png)

Boxplots, bar charts, and density plots facilitate intuitive interpretation of between-group differences..

---
## 📉 Adjusted Logistic Regression Results

![Resultado da regressão logística](regressao_resultado.png)

After adjusting for age, sex, BMI, and diabetes, the treatment effect was estimated as:

```text
Adjusted OR for 'Treatment' (vs Control): 0.66
95% Confidence Interval: 0.32 – 1.32; p = 0.241

---

## 🚀 How to Use

1. Clone or download this repository:
   ```bash
   git clone https://github.com/seu-usuario/clinical-compare.git
