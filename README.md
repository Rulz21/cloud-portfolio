# Cloud Portfolio

My personal portfolio website, hosted on AWS and built the way a real cloud team would.

**Stack (planned):** AWS (S3, CloudFront, Route 53, Lambda, DynamoDB), Terraform, GitHub Actions

## Build Log

### Session 1: Account setup
- **Did:** Created AWS account, turned on MFA with an authenticator app, set a $5 monthly budget alert.
- **Confused by:** My account uses AWS's new "projects" experience, so there was no root user or Security credentials menu. Found MFA under AWS Settings → Manage security and sign-in.
- **Learned:** MFA protects against stolen passwords. Budgets warn you; spend limits stop spending.

### Session 2: First homepage + Git setup
- **Did:** Installed Git and VS Code, cloned the repo, created site/index.html, and pushed it to GitHub.
- **Confused by:** "git is not recognized" error (terminal needed restarting after installing Git); a typo in `user.name`; cloning with a file link instead of the repo link.
- **Learned:** Repo links end in `.git`. Workflow: clone once, then add → commit → push.

### Session 3: Create the cloudfront
- **Did:** Set up the cloudfront and configure the distribution's settings.
- **Confused by:** the choice of the origin type (need to make sure my website use the correct origin)
- **Learned:** Origin type is just different kind of storerooms. Security should match the risk. My site didnt need one yet.