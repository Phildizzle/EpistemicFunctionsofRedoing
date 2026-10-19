# Codebook: `survey_public.csv`

67 respondents who completed the survey and kept their consent (online survey, SoSci Survey). One row per respondent. Rows are shuffled, and `id` is a new identifier with no link to the survey platform.

**Missing values:** empty cell. In the rating items, `-1` = "don't know" and `-9` = not answered; `R/01_data_import.R` treats both as missing.

## Demographics

| Variable | Question | Coding |
|---|---|---|
| `DM02` | Gender | 1 male, 2 female, 3 non-binary/other, -1 prefer not to say |
| `DM04` | Highest degree | 2 Master's, 3 Doctorate, 4 other |
| `DM06` | Career stage | 1 Master student, 2 PhD researcher, 3 Postdoc, 4 Research scientist, 5 Assistant professor, 6 Associate professor, 7 Full professor, 8 other |
| `DM07` | Primary affiliation | 1 University, 2 Research institute, 3 Government agency, 4 NGO, 5 Industry/private, 6 other |
| `DM13` | Employment | 1 permanent, 2 temporary/fixed-term, 3 other |
| `age` | Age in years (2026 minus year of birth) | empty = not provided |
| `country` | Country | country name; `Prefer not to say` |
| `ER02` | Prior reproduction or replication experience (filter question) | 1 has attempted, 2 has not attempted |

## Epistemic functions (rating scale 1 = not relevant to 5 = extremely relevant)

| Variable | Function | Stage | Item |
|---|---|---|---|
| `PS04_01` | Robustness | Theoretical | Testing whether the original theoretical explanation still accounts for the findings when reassessed with new data or alternative approaches |
| `PS04_06` | Precision | Theoretical | Ensuring close alignment between research questions, theoretical constructs, and operational definitions |
| `PS04_02` | Boundary | Theoretical | Clarifying or empirically identifying the boundary conditions and scope of the original claims |
| `PS04_03` | Extension | Theoretical | Examining whether findings hold when theory is refined, extended, or newly contextualized |
| `PS01_10` | Robustness | Sampling | Testing findings across different groups or segments (e.g., age, media use, political orientation, cultural/national background) |
| `PS01_09` | Precision | Sampling | Including a more diverse sample than the original study to increase representativeness |
| `PS01_15` | Boundary | Sampling | Revisiting the study after time has passed to assess change over time |
| `PS01_13` | Extension | Sampling | Considering societal, technological, or environmental changes relevant to the study (e.g., political climate, media landscape) |
| `PS02_02` | Robustness | Methodological | Applying different statistical techniques to assess robustness (e.g., alternative models or estimation strategies) |
| `PS02_01` | Precision | Methodological | Using improved or updated measurement instruments (e.g., more reliable survey items, refined coding schemes) |
| `PS02_03` | Boundary | Methodological | Re-examining key design or analytical decisions from the original study (e.g., exclusion criteria, preprocessing, modeling choices) |
| `PS02_04` | Extension | Methodological | Employing innovative or more rigorous methods to generate novel insights |
| `PS03_02` | Robustness | Success evaluation | Ensuring results are consistent with the original study (patterns, effect sizes, direction) and stable across tests, methods, or subgroups |
| `PS03_03` | Precision | Success evaluation | Interpreting any differences in results to identify clear reasons (e.g., context, sample, methods) |
| `PS03_04` | Boundary | Success evaluation | Assessing whether findings remain consistent across time, populations, or contexts beyond the original study |
| `PS03_01` | Extension | Success evaluation | Producing meaningful new insights or extending the study in novel ways |

Item wording as fielded, identical to the variable labels in the survey export and to the full questionnaire.

## Attitudes, subjective norms, perceived behavioural control (agreement scale 1 = strongly disagree to 5 = strongly agree; -1 = don't know)

| Variable | Construct | Item |
|---|---|---|
| `PB02_01` | Attitude | Enhancing reproducibility and/or replicability is important in Communication Science. |
| `PB02_02` | Attitude | Ensuring reproducibility/replicability in my research can enhance my academic recognition. |
| `PB02_03` | Attitude | Reproduction and replication attempts add value even if the original findings are not replicated. |
| `PB02_04` | Attitude | I am willing to put in extra effort to make my research reproducible. |
| `PB03_05` | Subjective norm | Most researchers in the field of Communication Science aim to conduct reproducible and/or replicable studies. |
| `PB03_06` | Subjective norm | Most researchers in the field of Communication Science would expect me to conduct reproducible and/or replicable studies. |
| `PB03_07` | Subjective norm | I believe that producing reproducible and/or replicable work is valued in my research community. |
| `PB03_08` | Subjective norm | The journals and conferences that I submit to expect reproducible and/or replicable research. |
| `PB03_09` | Subjective norm | My university or research institute expects reproducible and/or replicable research. |
| `PB03_10` | Subjective norm | The funding bodies I apply to expect research to be reproducible and/or replicable. |
| `PB04_03` | PBC | I am confident that, if I wanted to, I would be capable of making my research reproducible and/or replicable for others. |
| `PB04_02` | PBC (reversed in analysis) | I find it difficult to document and share my code in a reproducible and/or replicable way. |
| `PB04_06` | PBC (reversed in analysis) | I find it difficult to document and share my data in a reproducible and/or replicable way. |
| `PB04_04` | PBC | I have the knowledge necessary to make my research reproducible and/or replicable. |

## Replication landscape (slider, percent 0 to 100)

Values are percentages (0 to 100). The survey platform stores slider positions as 1 to 101; this was converted before publication. `-9` = not answered.

| Variable | Item |
|---|---|
| `RC03_01` | Percentage of the published communication science literature the respondent would like to see replicated |
| `RC04_01` | Percentage the respondent expects will actually be replicated in the next ten years |
