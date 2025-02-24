*Khoa Vu*

### Overall Grade: 261/280

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline? Take 10 pts off per day for late submission.  

-   Is the final report in a human readable format html? 

-   Is the report prepared as a dynamic document (Quarto) for better reproducibility?

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how results are produced by just reading the report? Take some points off if the solutions are too succinct to grasp, or there are too many typos/grammar. 

### Completeness, correctness and efficiency of solution: 225/230

- Q1 (50/50)
  
    - Q1.1 (25/25) 
    
    - Q1.2 (25/25)

- Q2 (10/10)

    - Q2.1 (5/5)
    
    - Q2.2 (5/5) A bar plot of similar suffices.
    
- Q3 (25/25)    
    
    - Q3.1 (5/5)
    
    - Q3.2 (20/20) Student must explain patterns in admission hour, admission minute, and length of hospital display. Just describing the pattern is not enough. There are no wrong or correct explanations; any explanation suffices. 

      By the way, there are unusual observations with negative length of stay, which should be unusual. `-0.0`

- Q4 (13/15)        
    
    - Q4.1 (5/5)
    
    - Q4.2 (8/10) There's not much pattern in gender. But some explanations are expected for anchor age: what are they and why the spike on the right.

      You did not mention that there is a peak at age 91 and guess why. Read MIMIC-IV documentation Dr. Zhou picked up in Q3.2. `-2.0`

- Q5 (30/30) Check the final number of rows and the first few rows of the final data frame.

- Q6 (30/30) Check the final number of rows and the first few rows of the final data frame.

- Q7 (25/30) Check the final number of rows and the first few rows of the final data frame.

    `Age at time` (diffrent from `anchor_age`) is not defined. `age_intime = anchor_age + (year(intime) - anchor_year`. `-5.0`

- Q8 (42/40) This question is open ended. Any graphical summaries are good. Since this question didn't explicitly ask for explanations, it's fine students don't give them. Students who give insights should be encouraged.

    No `marital status` result. `-3.0`
    
    I don't think using different colors in the boxplot is meaningful. `-0.0`
	    
    Again, use `age_intime`. `-0.0`

    You provided some insights. `+5.0`

### Usage of Git: 10/10

-   Are branches (`main` and `develop`) correctly set up? Is the hw submission put into the `main` branch?

-   Are there enough commits (>=5) in develop branch? Are commit messages clear? The commits should span out not clustered the day before deadline. 
          
-   Is the hw submission tagged? 

-   Are the folders (`hw1`, `hw2`, ...) created correctly? 
  
-   Do not put a lot auxiliary files into version control. 


### Reproducibility: 10/10

-   Are the materials (files and instructions) submitted to the `main` branch sufficient for reproducing all the results? Just click the `Render` button will produce the final `html`? 

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

### R code style: 6/20

For bash commands, only enforce the 80-character rule. Take 2 pts off for each violation. 

-   [Rule 2.5](https://style.tidyverse.org/syntax.html#long-lines) The maximum line length is 80 characters. Long URLs and strings are exceptions.  

-   [Rule 2.4.1](https://style.tidyverse.org/syntax.html#indenting) When indenting your code, use two spaces.  

    Lines 764-771 (788-795). `-2.0`

-   [Rule 2.2.4](https://style.tidyverse.org/syntax.html#infix-operators) Place spaces around all infix operators (=, +, -, &lt;-, etc.).  

    Lines 71 (93, 94 and others), 172 (173), 236, 406, 691 (and others), 692 (and others). `-12`

-   [Rule 2.2.1.](https://style.tidyverse.org/syntax.html#commas) Do not place a space before a comma, but always place one after a comma.  

-   [Rule 2.2.2](https://style.tidyverse.org/syntax.html#parentheses) Do not place spaces around code in parentheses or square brackets. Place a space before left parenthesis, except in a function call.
