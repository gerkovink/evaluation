# Reviewer 1

The authors made an effort in improving the paper. It reads very well. I have no major concerns. I have however some very minor wording suggestions:

- p.2, line 7: "In that case, imputation would be substantially more efficient than the ubiquitous complete case analysis." I think this does not hold in general and depends on the assumption of a correct parametric imputation model and congeniality with the analysis model. Consider rephrasing the sentence.
**We make a less general statement in the revised manuscript.**

- p.2, line 47: "we exclude the evaluation of imputation methodology for prediction or causal inference". You don't exclude causal inference: CI is statistical inference plus additional structural assumptions. A nice summary is given in A. Schuler's online book: https://alejandroschuler.github.io/mci/68dc1d5a1ab94ba59c77ae70ec8ca0d8.html; a quick fix would be to say that you exclude detailed aspects of causal inference (i.e. where we state the missingness mechanism as an actual mechanism in a structural model, rather than generically as a property of the observed [not intervened] data distribution) and refer to those at the bottom of the paragraph (i.e. the Mohan/Pearl reference).
**We adopted the suggestion.**

- p.4 top: you list two options two generate data. There may be more. For example, for some estimands, we can approximate the DGP of the actual (observed) data using machine learning techniques and then use those techniques for sampling, see for example Section 3.3.2 of Li et al. (Evaluating the robustness of targeted maximum likelihood estimators via realistic simulations in nutrition intervention trials). I suggest to add at least a third item "among others" with references.
**Thank you for the suggestion, which we have implemented in the revised manuscript.**


Reviewer 2

Thanks to the authors for addressing my comments on the first submission.

The authors choose to focus on the first option that I listed at the previous review: Incomplete covariate values in observational studies with focus on unbiased, efficient parameter estimation. This seems a sensible decision. This authors be made explicit in the title and abstract, both of which promise to be far more general.

- I noted a problem with a specific suggestion in section 2.1, which is to remove sampling variation by fixing the complete data and only simulating missing values. The authors have partially addressed this but I don’t think been clear enough. There are two important points that I think readers would miss:

  1. The suitability of this approach depends on the performance measures to be used. Specifically, any that involve sampling variation are of no interest (i.e. it’s only ok if you are only evaluating bias). The problem can be
  2. This approach is restricted to using a selection-model factorisation when generating data. If using a pattern-mixture approach, you cannot do this. Perhaps this point is obvious but it’s not explicit.

- In section 2.2, I like the recommendation to explore MNAR even if something is primarily intended to work with MAR. However, I think there may be two points to add. First, explicitly say that this is a way of understanding robustness: method A may perform ok under MAR and some MNAR mechanisms, while method B performs well under MAR but very poorly under any MNAR mechanism. In this case we may favour A over B. Second, this issue is IMO applicable to ‘late-phase’ methodological research (see Heinze et al. https://arxiv.org/abs/2209.13358); in early-phase work, I think it's perfectly acceptable to say 'this method works well in the setting it's intended to work well in'.

- It took a while to get my head around figure 1, and I’d suggest a little more explanation. The ‘MCAR’ and ‘Right-tailed MAR (ρ=0.8)’ panels are clear, but the ‘Right-tailed MAR (ρ=0)’ is not. First, I cannot see what is ‘right-tailed’ about it. Second, while I agree that MCAR requires an identical probability of missingness for each individual, how is this realised in a simulation study involving repetitions? The right panel of figure 1 seems to be ‘MAR given individual’. Are notional ‘individuals’ retained for each repetition? I don’t know the answer here, but two points:
1. fixing something across repetitions vs. drawing it each time can make a difference (e.g. comment above about only simulating missing data).
2. If you choose not to fix this ‘MAR’ mechanism across reps, it becomes operationally indistinguishable from MCAR.

- I like the properties suggested in section 2.4. Two comments:
1. It would be good to note that these properties are for an estimand of interest rather than just any parameter in the analysis model
2. (Root) mean squared error is arguably not for predictive accuracy, which you have said is not the target here, but a trade-off between bias and variance when a biased procedure has lower variance than an unbiased procedure.

- In table 1, I wondered about adding a point under methods for ‘how SEs and confidence intervals are to be constructed’. Rubin’s rules are likely the default but people might use Robins & Wang’s rules, Reiter’s rules, Efron’s full-mechanism bootstrap, von Hippel and Bartlett’s bootstrap…

- The point about validity of imputations is interesting. Rubin makes the point that the aim of MI is validity of inference, not of imputations,  Do the authors have examples of how to assess the validity of imputations? I broadly agree with this as a useful diagnostic but ideas of how to operationalise it in simulation studies would be useful.

MISC./MINOR COMMENTS
- The introduction says ‘The idea behind imputation is to impute (fill in) missing values, to obtain a valid estimate of what could have been.’ This is behind some imputation but certainly not multiple imputation. Rubin explicitly talks about the idea as being valid inference, not to recreate the missing values.

- The statement ‘Real-life data hardly ever follow a known theoretical distribution’ seems impossible to falsify. Perhaps safer to describe this as ‘We cannot know so safer not to pretend we do’.

- Since reviewing the first submission, I’ve seen some simulation studies where people have MAR and positivity vs. MAR and non-positivity (or near non-positivity). No pressure but I think it might be worth mentioning this in section 2.3.
