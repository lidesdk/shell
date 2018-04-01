**Problem/Motivation**

*(Why the issue was filed, steps to reproduce the problem, etc.)*

A brief statement describing why the issue was filed, steps to reproduce the problem, and so on.

**Example:**

    The security team has seen an error in contributed modules, because 
    developers don't realize that you need to wrap the arguments with 
    lide.error.is_string() before passing them to classes, unlike other 
    areas of the API. So the app throw an regular lua error unlike TypeException
    this behavoiur make hard debug program.
    
    
**Details to include:**

- Why are we doing this? Above all, a summary should explain why a change is needed, in a few short sentences.
- For majors and criticals: Why is the issue major or critical? For criticals, how does it block release?
- For bugs: Steps to reproduce the issue on a fresh installation of HEAD.
- For blockers: What issues is this blocking, and why?

**Proposed resolution:**

*(Description of the proposed solution, the rationale behind it, and workarounds for people who cannot use the patch.)*

A brief description of the proposed fix, and the rationale behind it.

**Example:**

    Change if-else verification blocks with lide.error.is_string so that 
    it automatically Throws a correct exception with the same results. An 
    additional, optional message parameter is allowed to the function, to 
    show different error message. 


**Remaining tasks**

*(reviews needed, tests to be written or run, documentation to be written, etc.)*

This section should cover anything that would prove useful to someone coming in and hoping to help with the issue. 
Is there a demo app? Do automated tests need to be written? Is cross-platform testing required? 
Does documentation need to be written? Etc.

**Example:**

    1. The patch is ready for review.
    2. A demo app has been set up at http://github.com/dcanoh/shell-patch-33/ where the current incarnation of this functionality has been deployed, for your testing pleasure.
    3. Unit tests are needed for the following issue identified during testing:
       #1178288: Data loss of uploaded files when re-editing issue

**Details to include:**

- Use a numbered list.
- It helps reviewers to keep a list of all the tasks for an issue, and mark each off with a <del> tag once it has been completed.
- For issues marked "Needs work": What needs to be fixed?
- For postponed issues: What is the issue postponed on, and why?
- If a reviewer has provided feedback that needs to be addressed, add a list item identifying that feedback, with a link to the relevant comment.
