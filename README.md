# Privacy-Utility Tradeoffs in Healthcare AI

**A comparative analysis of de-identification techniques on machine learning model performance**

Tai Chou-Kudu | MS in Data Science | CUNY School of Professional Studies | DATA 698 Capstone | Spring 2026

---

## Overview

Healthcare AI depends on patient data, and that data needs to be protected. The question this project tries to answer is practical: when you de-identify clinical data before training a machine learning model, how much performance do you actually lose, and does the answer depend on which de-identification technique you use?

This study compares k-anonymity and differential privacy applied to the MIMIC-III critical care database across two prediction tasks: 30-day hospital readmission and in-hospital mortality. The point is not to build the best model. It is to measure what you lose when you protect patient privacy, so that data scientists and compliance teams have real numbers to work with instead of defaults.

---

## Key Findings

- **K-anonymity** (age banding + ethnicity grouping) had minimal impact on model performance across all k values tested (k=5, 10, 25, 50), with AUROC remaining within 0.001 of baseline. Record compliance dropped from 99.7% at k=5 to 95.7% at k=50.
- **Differential privacy** caused substantial accuracy loss at strict privacy settings. Mortality AUROC dropped from 0.691 to 0.443 at epsilon=0.1, near or below chance level, and only partially recovered at epsilon=10 (0.662).
- **Both prediction tasks** responded nearly identically to both techniques. For admission-level feature sets, technique choice matters more than the clinical outcome being predicted.
- **Membership inference attack** results showed all DP configurations reduced attack accuracy relative to baseline, confirming DP provides model-level privacy protection, though at a steep utility cost.

---

## Decision Framework

| Organizational Priority | Recommended Technique | Expected AUROC Impact | Key Tradeoff |
|---|---|---|---|
| Regulatory compliance, auditability | K-anonymity (k=5-10) | Minimal (<0.001 drop) | Compliance drops from 99.7% to 95.7% as k increases |
| Model-level security against exploitation | Differential privacy (epsilon=10) | Moderate (~0.03-0.05 drop) | MI attack accuracy drops to 0.313 |
| Maximum privacy, utility secondary | Differential privacy (epsilon=0.1) | Severe (~0.25 drop) | Model likely not suitable for clinical use |

---

## Dataset

- **MIMIC-III** (Medical Information Mart for Intensive Care III) via Google BigQuery
- 48,180 adult admissions (ages 18-89)
- Access requires CITI training and a PhysioNet Data Use Agreement: [https://physionet.org/content/mimiciii/](https://physionet.org/content/mimiciii/)
- Features used: age at admission, gender, ethnicity, admission type, creatinine, BUN, bicarbonate, WBC, sodium

---

## Methods

**Prediction Tasks**
- In-hospital mortality (HOSPITAL_EXPIRE_FLAG): 10.86% positive rate
- 30-day readmission: 6.25% positive rate among surviving patients

**Model**
- Logistic regression (scikit-learn) with class_weight='balanced'
- 5-fold stratified cross-validation on full dataset
- Primary metric: AUROC (threshold-independent, robust to class imbalance)
- Secondary metric: F1 (reported for comparison across privacy conditions only)

**K-Anonymity**
- Age generalized into 10-year bands
- Ethnicity grouped from 41 distinct values into 6 broader categories (White, Black/African American, Hispanic/Latino, Asian, Other, Unknown)
- Same grouped encoding applied to baseline and all configurations for consistent comparison
- Compliance measured using pycanon
- k values tested: 5, 10, 25, 50

**Differential Privacy**
- IBM diffprivlib library
- Laplace noise injected into continuous features only
- epsilon values tested: 0.1, 1, 5, 10

**Privacy Assessment**
- K-anonymity: structural uniqueness check (proportion of records in non-compliant groups)
- Differential privacy: simplified membership inference attack (70/30 stratified train/test split)

---

## Repository Structure

```
healthcare_privacy_ml.ipynb     # All experiments: baseline, k-anonymity, differential privacy, membership inference
README.md          # This file
```

---

## How to Run

1. **Get MIMIC-III access** via PhysioNet (requires CITI training and a Data Use Agreement)
2. **Set up Google BigQuery** with your MIMIC-III project
3. **Open the notebook** in Google BigQuery Studio or Google Colab
4. **Update the project ID** in the BigQuery client call to match your own project
5. **Run cells in order**; all dependencies install inline with `!pip install`

**Dependencies**
```
google-cloud-bigquery
pandas
scikit-learn
diffprivlib
pycanon
```

---

## Limitations

- Only logistic regression evaluated; results may not generalize to more complex architectures
- Admission-level features only; longitudinal features not tested
- Simplified membership inference attack, not the shadow model approach (Shokri et al., 2017)
- Single institution dataset limits generalizability
- The two techniques are not fully symmetric: k-anonymity modifies both categorical and continuous features; differential privacy modifies continuous features only

---

## Future Work

- Extend to random forest, gradient boosting, XGBoost, and neural networks
- Incorporate cross-visit temporal features for readmission prediction
- Implement shadow model membership inference attack (Shokri et al., 2017)
- Test clinically meaningful age bands instead of uniform 10-year bins
- Compare with federated learning and synthetic data generation

---

## Citation

If you use this work, please cite:

> Chou-Kudu, T. (2026). Privacy-Utility Tradeoffs in Healthcare AI: A Comparative Analysis of De-Identification Techniques on Machine Learning Model Performance. MS Capstone, DATA 698, CUNY School of Professional Studies.

---

## Contact

Tai Chou-Kudu | [GitHub](https://github.com/tai-chou-kudu)
