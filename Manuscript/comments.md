# Reviewer 1

The authors made an effort in improving the paper. It reads very well. I have no major concerns. I have however some very minor wording suggestions:

- p.2, line 7: "In that case, imputation would be substantially more efficient than the ubiquitous complete case analysis." I think this does not hold in general and depends on the assumption of a correct parametric imputation model and congeniality with the analysis model. Consider rephrasing the sentence.
**We make a less general statement in the revised manuscript.**

- p.2, line 47: "we exclude the evaluation of imputation methodology for prediction or causal inference". You don't exclude causal inference: CI is statistical inference plus additional structural assumptions. A nice summary is given in A. Schuler's online book: https://alejandroschuler.github.io/mci/68dc1d5a1ab94ba59c77ae70ec8ca0d8.html; a quick fix would be to say that you exclude detailed aspects of causal inference (i.e. where we state the missingness mechanism as an actual mechanism in a structural model, rather than generically as a property of the observed [not intervened] data distribution) and refer to those at the bottom of the paragraph (i.e. the Mohan/Pearl reference).
**We adopted the suggestion.**

- p.4 top: you list two options two generate data. There may be more. For example, for some estimands, we can approximate the DGP of the actual (observed) data using machine learning techniques and then use those techniques for sampling, see for example Section 3.3.2 of Li et al. (Evaluating the robustness of targeted maximum likelihood estimators via realistic simulations in nutrition intervention trials). I suggest to add at least a third item "among others" with references.
**Thank you for the suggestion, which we have implemented in the revised manuscript.**


